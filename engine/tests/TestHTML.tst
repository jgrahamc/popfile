# ---------------------------------------------------------------------------------------------
#
# Tests for HTML.pm
#
# Copyright (c) 2003 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
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

# Set up the test corpus and use the Test msg and cls files
# to create a current history set

rmtree( 'corpus' );
test_assert( rec_cp( 'corpus.base', 'corpus' ) );
test_assert( rmtree( 'corpus/CVS' ) > 0 );
test_assert( rmtree( 'corpus/other/CVS' ) > 0 );
test_assert( rmtree( 'corpus/spam/CVS' ) > 0 );
test_assert( rmtree( 'corpus/personal/CVS' ) > 0 );
rmtree( 'messages' );
`rm -f __db.*`;  # todo: make tool independent
unlink 'popfile.cfg';
unlink 'popfile.db';

unlink( 'stopwords' );
test_assert( copy ( 'stopwords.base', 'stopwords' ) );

mkdir 'messages';
my @messages = glob '*.msg';

my $count = 0;
my $dl    = 0;
foreach my $msg (@messages) {
    next if ( $msg =~ /TestMailParse026/ );
    my $name = "messages/popfile$dl" . "=" . "$count";
    test_assert( (`cp $msg $name.msg` || 0) == 0 );
    $msg =~ s/\.msg$/\.cls/;
    test_assert( (`cp $msg $name.cls` || 0) == 0 );
    $count += 1;
    if ( rand(1) > 0.5 ) {
        $dl += 1;
    }
}

use POSIX ":sys_wait_h";

use HTML::Form;
my @forms;

# Helper function that finds a form in @forms with the
# named input element, returns the form object and input
# element if found or undef

sub find_form
{
    my ( $name, $nth ) = @_;

    foreach my $form (@forms) {
        my $input = $form->find_input( $name, undef, $nth );

        if ( defined( $input ) ) {
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
        $input->value( $value ) if defined( $value );
        return $input->value();
    }

    return undef;
}

sub pipeready
{
    my ( $self, $pipe ) = @_;

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

use Classifier::Bayes;
use Classifier::WordMangle;
use UI::HTML;
use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use POPFile::History;
use Proxy::POP3;

my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $b = new Classifier::Bayes;
my $w = new Classifier::WordMangle;
my $hi = new POPFile::History;

$b->configuration( $c );
$b->mq( $mq );
$b->logger( $l );

$w->configuration( $c );
$w->mq( $mq );
$w->logger( $l );

$b->{parser__}->mangle( $w );

$c->configuration( $c );
$c->mq( $mq );
$c->logger( $l );
$c->initialize();

$l->configuration( $c );
$l->mq( $mq );
$l->logger( $l );

$l->initialize();
$l->config_( 'level', 2 );
$mq->configuration( $c );
$mq->mq( $mq );
$mq->logger( $l );
$mq->pipeready( \&pipeready );
$w->initialize();
$w->start();

my $p = new Proxy::POP3;

$p->configuration( $c );
$p->mq( $mq );
$p->classifier( $b );
$p->logger( $l );
$p->version( 'vtest.suite.ver' );
$p->initialize();
$p->config_( 'port', 9110 );
$p->config_( 'force_fork', 0 );
$p->start();

test_assert( $p->config_( 'secure_server' ) eq '' );

$b->initialize();
$hi->configuration( $c );
$hi->mq( $mq );
$hi->logger( $l );

$b->history( $hi );
$hi->classifier( $b );

$hi->initialize();
test_assert( $b->start() );
test_assert( $hi->start() );
$hi->service();

our $h = new UI::HTML;

test_assert(1);

$h->classifier( $b );
$h->configuration( $c );
$h->history( $hi );
$h->mq( $mq );
$h->logger( $l );
test_assert(1);
$h->initialize();
test_assert(1);
$h->version( 'vtest.suite.ver' );
our $version = $h->version();

test_assert(1);

our $sk = $h->session_key();

test_assert( defined( $sk ) );
test_assert( $sk ne '' );

$mq->service();

test_assert_equal( $h->url_encode_( ']' ), '%5d' );
test_assert_equal( $h->url_encode_( '[' ), '%5b' );
test_assert_equal( $h->url_encode_( '[]' ), '%5b%5d' );
test_assert_equal( $h->url_encode_( '[foo]' ), '%5bfoo%5d' );

sub forker
{
    pipe my $reader, my $writer;
    $b->prefork();
    $mq->prefork();
    my $pid = fork();

    if ( !defined( $pid ) ) {
        close $reader;
        close $writer;
        return (undef, undef);
    }

    if ( $pid == 0 ) {
        $b->forked( $writer );
        $mq->forked( $writer );
        $hi->forked( $writer );
        close $reader;

        use IO::Handle;
        $writer->autoflush(1);

        return (0, $writer);
    }

    $b->postfork( $pid, $reader );
    $mq->postfork( $pid, $reader );
    close $writer;
    return ($pid, $reader);
}

my $session = $b->get_session_key( 'admin', '' );

our $port = 9001 + int(rand(1000));
pipe my $dreader, my $dwriter;
pipe my $ureader, my $uwriter;
my ( $pid, $pipe ) = forker();

if ( $pid == 0 ) {

    # CHILD THAT WILL RUN THE HTML INTERFACE

    close $dwriter;
    close $ureader;

    $uwriter->autoflush(1);

    $h->config_( 'port', $port );
    $h->start();

    my %lang = $h->language();
    test_assert_equal( $lang{LanguageCode}, 'en' );

    while ( 1 ) {
        $h->service();

        if ( pipeready( 0, $dreader ) ) {
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

            if ( $command =~ /^__GETPARAMETER ([^ ]+) (.+)/ ) {
                my $value = $b->get_bucket_parameter( $session, $1, $2 );
                print $uwriter "OK $value\n";
                next;
            }

            if ( $command =~ /^__SENDMESSAGE ([^ ]+) (.+)/ ) {
                $b->mq_post_( $1, $2, '' );
                print $uwriter "OK\n";
                next;
            }

            if ( $command =~ /^__NEWMESSAGE (\d+)/ ) {
                my ( $slot, $file ) = $hi->reserve_slot();
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

    $h->stop();

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

    my $in = new String::Interpolate { sk => \$sk, port => \$port, version => \$version };

    # Wait for the UI to become available

    my $now = time;
    while ( time < ( $now + 5 ) ) {
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
        $line =~ s/^[\t ]+//g;
        $line =~ s/[\r\n\t ]+$//g;

        if ( $line =~ /^#/ ) {
            next;
        }

        $in->( $line );
        $line = "$in";

        if ( $line =~ /^GET +(.+)$/ ) {
            my $request = HTTP::Request->new('GET', "http://127.0.0.1:$port$1" );
            my $response = $ua->request($request);
            test_assert_equal( $response->code, 200 );
            $content = $response->content;
            $content =~ s/^[\t ]+//gm;
            $content =~ s/[\t ]+$//gm;
            while ( ( $content =~ s/\n\n/\n/gs ) > 0 ) {
            }
            @forms   = HTML::Form->parse( $content, "http://127.0.0.1:$port" );
            next;
        }

        if ( $line =~ /^CLICK +(.+)$/ ) {
            my $name = $1;
            my ( $form, $input ) = find_form( $name );
            my $request = undef;
            $request = $form->click( $name ) if ( defined( $form ) );
            if ( defined( $request ) ) {
                my $response = $ua->request( $request );
                if ( $response->code == 302 ) {
                    $content = get(url("http://127.0.0.1:$port" . $response->headers->header('Location')));
                } else {
                    test_assert_equal( $response->code, 200, "From script line $line_number" );
                    $content = $response->content;
                }
                @forms   = HTML::Form->parse( $content, "http://127.0.0.1:$port" );
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

        if ( $line =~ /^SENDMSG +([^ ]+) (.+)$/ ) {
            my ( $msg, $param ) = ( $1, $2 );
            print $dwriter "__SENDMESSAGE $msg $param\n";
            my $reply = <$ureader>;

            if ( !( $reply =~ /^OK/ ) ) {
                test_assert( 0, "From script line $line_number" );
            }
            $mq->service();
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
                @forms   = HTML::Form->parse( $content, "http://127.0.0.1:$port" );
            }
            next;
        }

        if ( $line =~ /^MATCH +(.+)$/ ) {
            test_assert_regexp( $content, "\Q$1\E", "From script line $line_number" );
            next;
        }

        if ( $line =~ /^NOTMATCH +(.+)$/ ) {
            test_assert_not_regexp( $content, "\Q$1\E", "From script line $line_number" );
            next;
        }

        if ( $line =~ /^MATCH$/ ) {
            my $block;

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

            test_assert_regexp( $content, "\Q$block\E", "From script line $line_number" );
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

        if ( $line =~ /^NEWMSG (\d+)$/ ) {
            my ( $msg ) = ( $1 );
            print $dwriter "__NEWMESSAGE $msg\n";
            my $reply = <$ureader>;

            if ( !( $reply =~ /^OK/ ) ) {
                test_assert( 0, "From script line $line_number" );
            }
            $mq->service();
            $hi->service();

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

    $p->stop();

print "PID: $pid\n";

    while ( waitpid( $pid, &WNOHANG ) != $pid ) {
    }

    $mq->reaper();
    $mq->stop();
    $hi->stop();
    $b->release_session_key( $session );
    $b->stop();
}

1;
