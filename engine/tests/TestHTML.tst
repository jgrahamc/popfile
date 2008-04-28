# ---------------------------------------------------------------------------------------------
#
# Tests for HTML.pm
#
# Copyright (c) 2003-2006 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
#
#   POPFile is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with POPFile; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
# ---------------------------------------------------------------------------------------------

use POSIX qw(locale_h);

if ( $^O eq 'MSWin32' && setlocale(LC_COLLATE) eq 'Japanese_Japan.932' ) {
    setlocale(LC_COLLATE,'C');
}
# Set up the test corpus and use the Test msg and cls files
# to create a current history set

rmtree( 'corpus' );
rec_cp( 'corpus.base', 'corpus' );
rmtree( 'corpus/CVS' );
rmtree( 'corpus/other/CVS' );
rmtree( 'corpus/spam/CVS' );
rmtree( 'corpus/personal/CVS' );
rmtree( 'messages' );

my @dbs = glob '__db.*';
foreach my $db (@dbs) {
	unlink $db;
}

my @err_html_list = glob 'testhtml_match*.html';
foreach my $err_html (@err_html_list) {
    unlink $err_html;
}

unlink 'popfile.cfg';
unlink 'popfile.db';
unlink 'popfile.pid';

unlink( 'stopwords' );
test_assert( copy ( 'stopwords.base', 'stopwords' ) );

mkdir 'messages';
my @messages = glob 'TestMails/TestMailParse*.msg';

my $count = 0;
my $dl    = 0;
foreach my $msg (@messages) {
    my $name = "messages/popfile$dl" . "=" . "$count";
    test_assert( copy ( $msg, "$name.msg") );
    $msg =~ s/\.msg$/\.cls/;
    test_assert( copy ( $msg, "$name.cls") );
    $count += 1;
    if ( rand(1) > 0.5 ) {
        $dl += 1;
    }
}


use POSIX ":sys_wait_h";

use HTML::Form;
my @forms;

my $hidden = 0;


use UI::HTML;
my $h = new UI::HTML;

test_assert_equal( $h->url_encode_( ']'     ), '%5d'       );
test_assert_equal( $h->url_encode_( '['     ), '%5b'       );
test_assert_equal( $h->url_encode_( '[]'    ), '%5b%5d'    );
test_assert_equal( $h->url_encode_( '[foo]' ), '%5bfoo%5d' );

$h->{language__}{global}{Locale_Thousands} = ',';
test_assert_equal( $h->pretty_number( 1234 ), '1,234'      );
$h->{language__}{global}{Locale_Thousands} = '&nbsp;';
test_assert_equal( $h->pretty_number( 1234 ), '1&nbsp;234' );
$h->{language__}{global}{Locale_Thousands} = '';


our $port = 9001 + int(rand(1000));
pipe my $dreader, my $dwriter;
pipe my $ureader, my $uwriter;
my $pid = fork();

if ( $pid == 0 ) {

    use POPFile::Loader;
    my $POPFile = POPFile::Loader->new();
#    $POPFile->{debug__} = 1;
    $POPFile->CORE_loader_init();
    $POPFile->CORE_signals();

    my %valid = ( 'POPFile/Database'       => 1,
                  'POPFile/Logger'         => 1,
                  'POPFile/MQ'             => 1,
                  'POPFile/History'        => 1,
                  'Classifier/Bayes'       => 1,
                  'Classifier/WordMangle'  => 1,
                  'POPFile/Configuration'  => 1,
                  'UI/HTML'                => 1,
                  'Proxy/POP3'             => 1 );

    $POPFile->CORE_load( 0, \%valid );

    $h->loader( $POPFile );

    $POPFile->CORE_initialize();
    $POPFile->CORE_config( 1 );

    my $c  = $POPFile->get_module( 'POPFile/Configuration' );
    my $mq = $POPFile->get_module( 'POPFile/MQ'            );
    my $l  = $POPFile->get_module( 'POPFile/Logger'        );
    my $b  = $POPFile->get_module( 'Classifier/Bayes'      );
    my $w  = $POPFile->get_module( 'Classifier/WordMangle' );
    my $hi = $POPFile->get_module( 'POPFile/History'       );

    $l->config_( 'level', 0 );
    $mq->pipeready( \&pipeready );

    $c->module_config_( 'pop3', 'enabled',       1 );
    $c->module_config_( 'pop3', 'port',       9110 );
    $c->module_config_( 'pop3', 'force_fork',    0 );

    $c->module_config_( 'html', 'port', $port + 1 );
    $POPFile->CORE_start();

    $hi->service();

    my $session = $b->get_session_key( 'admin', '' );

    # CHILD THAT WILL RUN THE HTML INTERFACE

    close $dwriter;
    close $ureader;

    $uwriter->autoflush(1);

    $h->initialize();

    $h->config_( 'port',  $port );
    $h->config_( 'local',     1 );
    $h->version( '?.?.?' );

    $h->start();

    $mq->{pid__} = $$;

    $mq->service();

    my $lang = $h->language();
    test_assert_equal( $lang->{LanguageCode}, 'en' );

    while ( 1 ) {
        $h->service();

        if ( pipeready( $dreader ) ) {
            my $command = <$dreader>;

            if ( $command =~ /^__QUIT/ ) {
                $h->stop();
                print $uwriter "OK\n";
                last;
            }

            if ( $command =~ /^__GETCONFIG (.+)/ ) {
                my $value = $c->parameter( $1 );
                print $uwriter "OK $value\n";
                next;
            }

            if ( $command =~ /^__SETCONFIG (.+) (.+)?/ ) {
                $c->parameter( $1, defined($2)?$2:'' );
                print $uwriter "OK\n";
                next;
            }

            if ( $command =~ /^__GETUSERCONFIG ([^_]+)_(.+)/ ) {
                my $value = $h->user_module_config_( 1, $1, $2 );
                print $uwriter "OK $value\n";
                next;
            }

            if ( $command =~ /^__SETUSERCONFIG ([^_]+)_(.+) (.+)?/ ) {
                my $value = $h->user_module_config_( 1, $1, $2, $3 );
                print $uwriter "OK\n";
                next;
            }

            if ( $command =~ /^__GETPARAMETER ([^ ]+) (.+)/ ) {
                my $value = $b->get_bucket_parameter( $session, $1, $2 );
                print $uwriter "OK $value\n";
                next;
            }

            if ( $command =~ /^__ISVALIDPASSWORD (.*)/ ) {
                my $password = $1 || '';
                my $result = $b->validate_password( $session, $password );
                if ( $result eq 1 ) {
                    print $uwriter "OK\n";
                } else {
                    print $uwriter "ERR\n";
                }
                next;
            }

            if ( $command =~ /^__SENDMESSAGE ([^ ]+) (.+)/ ) {
                $b->mq_post_( $1, $2, '' );
                print $uwriter "OK\n";
                next;
            }

            if ( $command =~ /^__NEWMESSAGE (\d+)/ ) {
                my ( $slot, $file ) = $hi->reserve_slot( $session, 1 );
                open FILE, ">$file";
                my ( $bucket, $magnet );
                if ( $1 == 1 ) {
                    print FILE <<EOM;
From: John
Subject: Testing Refresh

Body would go here

EOM
                    $bucket = 'personal';
                    $magnet = 0;
                }

                if ( $1 == 2 ) {
                    print FILE <<EOM;
From: foo-magnet\@magnetmania.com
Subject: Magnetic Attraction for Ferrous Females

Align your pole to magnetic north
EOM
                    $bucket = 'personal';
                    $magnet = 3;
                }
                close FILE;

                $hi->commit_slot( $session, $slot, $bucket, $magnet );
                my $cd = 10;
                while ( $cd-- ) {
                    select( undef, undef, undef, 0.1 );
                    $mq->service();
                    $hi->service();
                }
                print $uwriter "OK\n";
                next;
            }

            if ( $command =~ /^__CHECKMAGNET ([^ ]+) ([^ ]+) ([^\r\n]+)/ ) {
                my $found = 0;
                for my $magnet ($b->get_magnets( $session, $1, $2 ) ) {
                    if ( $magnet eq $3 ) {
                        print $uwriter "OK\n";
                        $found = 1;
                        last;
                    }
                }

                print $uwriter "ERR\n" if ( !$found );
                next;
            }
        }
    }

    close $dreader;
    close $uwriter;

    $POPFile->CORE_stop();

    exit(0);
} else {

    # PARENT THAT WILL SEND COMMANDS TO THE WEB INTERFACE

    close $dreader;
    close $uwriter;
    $dwriter->autoflush(1);

    use LWP::Simple;
    use LWP::UserAgent;
    use URI::URL;
    use String::Interpolate;

    my $ua = new LWP::UserAgent;
    my $line_number = 0;
    my %h = ( port => \$port );

    my $in = new String::Interpolate %h;

    # Wait for the UI to become available

    my $now = time;
    while ( time < ( $now + 500 ) ) {
        my $request = HTTP::Request->new('GET', "http://127.0.0.1:$port/" );
        my $response = $ua->request($request);
        if ( $response->code == 200 ) {
            last;
        }
    }

    our $url;
    our $content;
    open SCRIPT, "<TestHTML.script";

    # The commands in this loop are documented in TestHTML.script

    while ( my $line = <SCRIPT> ) {
        $line_number += 1;
#        print "line $line_number\n";
        $line =~ s/^[\t ]+//g;
        $line =~ s/[\r\n\t ]+$//g;

        if ( $line =~ /^#/ ) {
            next;
        }

        $in->( $line );
        $line = "$in";

        if ( $line =~ /^GET +(.+)$/ ) {
#            print "  GET $1\n";
            my $request = HTTP::Request->new('GET', "http://127.0.0.1:$port$1" );
            my $response = $ua->request($request);
            @forms   = HTML::Form->parse( $response );
            $content = $response->content;
            $content =~ s/^[\t ]+//gm;
            $content =~ s/[\t ]+$//gm;
            while ( ( $content =~ s/\n\n/\n/gs ) > 0 ) {
            }
            next;
        }

        if ( $line =~ /^CLICK +(.+)$/ ) {
            my $name = $1;
            my ( $form, $input ) = find_form( $name );
            my $request = undef;
            $request = $form->click( $name ) if ( defined( $form ) );
            if ( defined( $request ) ) {
                my $response = $ua->request( $request );
                @forms = HTML::Form->parse( $response );
                if ( $response->code == 302 ) {
                    $content = get(url("http://127.0.0.1:$port" . $response->headers->header('Location')));
                    @forms = HTML::Form->parse( $content, "http://127.0.0.1:$port" );
                } else {
                    test_assert_equal( $response->code, 200, "From script line $line_number" );
                    $content = $response->content;
                }
                $content =~ s/^[\t ]+//gm;
                $content =~ s/[\t ]+$//gm;
                while ( ( $content =~ s/\n\n/\n/gs ) > 0 ) {
                }
            } else {
                test_assert( 0, "Failed to create request form at script line $line_number" );
            }
            next;
        }

        if ( $line =~ /^PARAMETERIS +([^ ]+) ([^ ]+) ?(.+)?$/ ) {
            my ( $bucket, $param, $expected ) = ( $1, $2, $3 );
            $expected = '' if ( !defined( $expected ) );
            print $dwriter "__GETPARAMETER $bucket $param\n";
            my $reply = <$ureader>;
            $reply =~ /^OK ([^\r\n]+)/;
            test_assert_equal( $1, $expected, "From script line $line_number" );
            next;
        }

        if ( $line =~ /^CONFIGIS +([^ ]+) ?(.+)?$/ ) {
            my ( $option, $expected ) = ( $1, $2 );
            $expected = '' if ( !defined( $expected ) );
            print $dwriter "__GETCONFIG $option\n";
            my $reply = <$ureader>;
            if ( $reply =~ /^OK ([^\r\n]+)/ ) {
                $reply = $1;
            } else {
                $reply = '';
            }
            test_assert_equal( $reply, $expected, "From script line $line_number asking for $option and got reply $reply" );
            next;
        }

        if ( $line =~ /^USERCONFIGIS +([^ ]+) ?(.+)?$/ ) {
            my ( $option, $expected ) = ( $1, $2 );
            $expected = '' if ( !defined( $expected ) );
            print $dwriter "__GETUSERCONFIG $option\n";
            my $reply = <$ureader>;
            if ( $reply =~ /^OK ([^\r\n]+)/ ) {
                $reply = $1;
            } else {
                $reply = '';
            }
            test_assert_equal( $reply, $expected, "From script line $line_number asking for $option and got reply $reply" );
            next;
        }

        if ( $line =~ /^SETCONFIG +([^ ]+) ?(.+)?$/ ) {
            my ( $option, $value ) = ( $1, $2 );
            $value = '' if ( !defined( $value ) );
            print $dwriter "__SETCONFIG $option $value\n";
            my $reply = <$ureader>;

            if ( !( $reply =~ /^OK/ ) ) {
                test_assert( 0, "From script line $line_number" );
            }
            next;
        }

        if ( $line =~ /^SETUSERCONFIG +([^ ]+) ?(.+)?$/ ) {
            my ( $option, $value ) = ( $1, $2 );
            $value = '' if ( !defined( $value ) );
            print $dwriter "__SETUSERCONFIG $option $value\n";
            my $reply = <$ureader>;

            if ( !( $reply =~ /^OK/ ) ) {
                test_assert( 0, "From script line $line_number" );
            }
            next;
        }

        if ( $line =~ /^SENDMSG +([^ ]+) (.+)$/ ) {
            my ( $msg, $param ) = ( $1, $2 );
            print $dwriter "__SENDMESSAGE $msg $param\n";
            my $reply = <$ureader>;

            if ( !( $reply =~ /^OK/ ) ) {
                test_assert( 0, "From script line $line_number" );
            }
            next;
        }

        if ( $line =~ /^MAGNETIS +([^ ]+) ([^ ]+) (.+)$/ ) {
            my ( $bucket, $type, $magnet ) = ( $1, $2, $3 );
            print $dwriter "__CHECKMAGNET $bucket $type $magnet\n";
            my $reply = <$ureader>;

            if ( !( $reply =~ /^OK/ ) ) {
                test_assert( 0, "From script line $line_number" );
            }
            next;
        }

        if ( $line =~ /^INPUTIS +([^ ]+) ?(.+)?$/ ) {
            my ( $name, $expected ) = ( $1, $2 );
            $expected = '' if ( !defined( $expected ) );
            test_assert_equal( form_input( $name ), $expected, "From script line $line_number" );
            next;
        }

        if ( $line =~ /^SETINPUTN +([^ ]+) +(\d+) ?(.+)?$/ ) {
            my ( $name, $nth, $value ) = ( $1, $2, $3 );
            $value = '' if ( !defined( $value ) );
            form_input( $name, $value, $nth );
            next;
        }

        if ( $line =~ /^(SETINPUT|SETSUBMIT) +([^ ]+) ?(.+)?$/ ) {
            my ( $name, $value ) = ( $2, $3 );
            $value = '' if ( !defined( $value ) );
            form_input( $name, $value );
            next if ( $line =~ /^SETINPUT/ );
        }

        # Note drop through here from previous if

        if ( $line =~ /^(SET)?SUBMIT +([^ ]+)/ ) {
            my $request = form_submit( $2 );
            if ( defined( $request ) ) {
                my $response = $ua->request( $request );
                $content = $response->content;
                $content =~ s/^[\t ]+//gm;
                $content =~ s/[\t ]+$//gm;
                while ( ( $content =~ s/\n\n/\n/gs ) > 0 ) {
                }
                @forms   = HTML::Form->parse( $response );
            }
            next;
        }

        if ( $line =~ /^MATCH +(.+)$/ ) {
            my $string = $1;
            $content =~ s/([0-9]\.[0-9]+e[-\+])0([0-9]{2})/$1$2/ if ( $^O eq 'MSWin32' );
            my $result = test_assert_regexp( $content, "\Q$string\E", "From script line $line_number" );
            if ( !$result ) {
                open HTML, ">testhtml_match$line_number.html";
                print HTML $content;
                close HTML;
            }
            next;
        }

        if ( $line =~ /^NOTMATCH +(.+)$/ ) {
            my $result = test_assert_not_regexp( $content, "\Q$1\E", "From script line $line_number" );
            if ( !$result ) {
                open HTML, ">testhtml_match$line_number.html";
                print HTML $content;
                close HTML;
            }
            next;
        }

        if ( $line =~ /^MATCH$/ ) {
            my $block = '';

            while ( $line = <SCRIPT> ) {
                $line_number += 1;
                $line =~ s/^[\t ]+//g;
                $line =~ s/[\r\n\t ]+$//g;

                $in->( $line );
                $line = "$in";

                if ( $line =~ /^ENDMATCH$/ ) {
                    last;
                }

                $block .= "\n" unless ( $block eq '' );
                $block .= $line;
            }

            my $result = test_assert_regexp( $content, "\Q$block\E", "From script line $line_number" );
            if ( !$result ) {
                open HTML, ">testhtml_match$line_number.html";
                print HTML $content;
                close HTML;
            }
            next;
        }

        if ( $line =~ /^CODE$/ ) {
            my $block;

            while ( $line = <SCRIPT> ) {
                $line_number += 1;
                $line =~ s/^[\t ]+//g;
                $line =~ s/[\r\n\t ]+$//g;

                if ( $line =~ /^ENDCODE$/ ) {
                    last;
                }

                $block .= $line;
                $block .= "\n";
            }

            eval( $block );
            next;
        }

        if ( $line =~ /^STOP$/ ) {
            last;
        }

        if ( $line =~ /^HIDDEN (0|1)$/ ) {
            $hidden = $1;
            next;
        }

        if ( $line =~ /^ISVALIDPASSWORD ?(.*)?$/ ) {
            my $password = $1 || '';
            print $dwriter "__ISVALIDPASSWORD $password\n";
            my $reply = <$ureader>;

            test_assert( ( $reply =~ /^OK/ ), "From script line $line_number" );
            next;
        }

        if ( $line =~ /^NEWMSG (\d+)$/ ) {
            my ( $msg ) = ( $1 );
            print $dwriter "__NEWMESSAGE $msg\n";
            my $reply = <$ureader>;

            if ( !( $reply =~ /^OK/ ) ) {
                test_assert( 0, "From script line $line_number" );
            }
            my $cd = 10;
            while ( $cd-- ) {
                select( undef, undef, undef, 0.1 );
            }

            next;
        }

        if ( $line =~ /[^ \t\r\n]/ ) {
            test_assert( 0, "Don't understand line $line_number" );
        }
    }
skip:
    close SCRIPT;

    # TODO Validate every page in the interface against the W3C HTML 4.01
    # validation service

    print $dwriter "__QUIT\n";
    $content = <$ureader>;
    test_assert_equal( $content, "OK\n" );
    close $dwriter;
    close $ureader;

    while ( waitpid( $pid, &WNOHANG ) != $pid ) {
    }
}


# Helper function that finds a form in @forms with the
# named input element, returns the form object and input
# element if found or undef

sub find_form
{
    my ( $name, $nth ) = @_;

    foreach my $form (@forms) {
#        print "Checking form ", $form->dump, "\n";
        my $input = $form->find_input( $name, undef, $nth );

        if ( defined( $input ) &&
           ( ( $input->type ne 'hidden' ) || $hidden ) ) {
            return ( $form, $input );
        }
    }

    test_assert( 0, "Unable to find form element '$name'" );

    return ( undef, undef );
}

# Helper function that finds the form with a specific input
# by name and returns an HTTP::Request to submit the form

sub form_submit
{
    my ( $name ) = @_;

    my ( $form ) = find_form( $name );

    if ( defined( $form ) ) {
        return $form->click;
    } else {
        return undef;
    }
}

# Helper function that finds an input with a specific name
# in the @forms collection and returns or sets its value

sub form_input
{
    my ( $name, $value, $nth ) = @_;
    my ( $form, $input ) = find_form( $name, $nth );

    if ( defined( $form ) ) {
        $input->disabled( 0 ) if defined( $value ); # force enable
        $input->readonly( 0 ) if defined( $value ); # force writable
        $input->value( $value ) if defined( $value );
        return $input->value();
    }

    return undef;
}

sub pipeready
{
    my ( $pipe ) = @_;

    if ( !defined( $pipe ) ) {
        return 0;
    }

    if ( $^O eq 'MSWin32' ) {
        return ( ( -s $pipe ) > 0 );
    } else {
        my $rin = '';
        vec( $rin, fileno( $pipe ), 1 ) = 1;
        my $ready = select( $rin, undef, undef, 0.01 );
        return ( $ready > 0 );
    }
}

1;
