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

test_assert( (`rm -rf corpus` || 0) == 0 );
test_assert( (`cp -R corpus.base corpus` || 0) == 0 );
test_assert( (`rm -rf corpus/CVS` || 0) == 0 );
test_assert( (`rm -rf corpus/other/CVS` || 0) == 0 );
test_assert( (`rm -rf corpus/spam/CVS` || 0) == 0 );
test_assert( (`rm -rf corpus/personal/CVS` || 0) == 0 );
test_assert( (`rm -rf messages` || 0) == 0 );
`rm -f __db.*`;
unlink 'popfile.cfg';

unlink( 'stopwords' );
test_assert( (`cp stopwords.base stopwords` || 0 ) == 0 );

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

use Classifier::Bayes;
use Classifier::WordMangle;
use UI::HTML;
use POPFile::Configuration;
use POPFile::MQ;
use POPFile::Logger;
use Proxy::POP3;

my $c = new POPFile::Configuration;
my $mq = new POPFile::MQ;
my $l = new POPFile::Logger;
my $b = new Classifier::Bayes;
my $w = new Classifier::WordMangle;

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

$mq->configuration( $c );
$mq->mq( $mq );
$mq->logger( $l );

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

test_assert(1);

$b->initialize();
test_assert( $b->start() );

our $h = new UI::HTML;

test_assert(1);

$h->classifier( $b );
$h->configuration( $c );
$h->mq( $mq );
$h->logger( $l );
test_assert(1);
$h->initialize();
test_assert(1);
$h->version( 'vtest.suite.ver' );
my $lang = $h->language();
test_assert_equal( $lang, 'English' );
our $version = $h->version();

test_assert(1);

our $sk = $h->session_key();

test_assert( defined( $sk ) );
test_assert( $sk ne '' );

$mq->service();

$h->global_config_( 'ecount', 1 );

test_assert_equal( $h->url_encode_( ']' ), '%5d' );
test_assert_equal( $h->url_encode_( '[' ), '%5b' );
test_assert_equal( $h->url_encode_( '[]' ), '%5b%5d' );
test_assert_equal( $h->url_encode_( '[foo]' ), '%5bfoo%5d' );

our $port = 9001 + int(rand(1000));
pipe my $dreader, my $dwriter;
pipe my $ureader, my $uwriter;
$b->prefork();
my $pid = fork();

if ( $pid == 0 ) {

    $b->postfork();

    # CHILD THAT WILL RUN THE HTML INTERFACE

    close $dwriter;
    close $ureader;

    $uwriter->autoflush(1);

    $h->config_( 'port', $port );
    $h->start();

    while ( 1 ) {
        $h->service();

        if ( pipeready( $dreader ) ) {
            my $command = <$dreader>;

            if ( $command =~ /^__QUIT/ ) {
                $h->stop();

                # Test the history disk caching function

                open TEMP, ">messages/popfile1=1.msg";
                print TEMP "From: John\n\nBody\n";
                close TEMP;

                $h->start();
                $h->stop();

                $h->start();
                $h->stop();

                unlink( 'messages/popfile1=1.msg' );

                $h->start();
                $h->stop();

                open TEMP, ">messages/popfile1=1.msg";
                print TEMP "From: John\n\nBody\n";
                close TEMP;
                open TEMP, ">messages/popfile1=1.cls";
                print TEMP "spam\n";
                close TEMP;
                open TEMP, ">messages/popfile1_1.msg";
                print TEMP "From: John\n\nBody\n";
                close TEMP;

                $h->config_( 'archive', 1 );
                $h->config_( 'archive_dir', 'archive' );
                $h->config_( 'archive_classes', 1 );

                `date --set='3 days'`;
                $h->remove_mail_files();
                `date --set='3 days ago'`;
                test_assert( !( -e 'messages/popfile1=1.msg' ) );
                test_assert( !( -e 'messages/popfile1_1.msg' ) );
                test_assert( -e 'archive/spam/0/popfile1=1.msg' );

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
                my $value = $b->get_bucket_parameter( $1, $2 );
                print $uwriter "OK $value\n";
                next;
	    }

            if ( $command =~ /^__SENDMESSAGE ([^ ]+) (.+)/ ) {
                $b->mq_post_( $1, $2, '' );
                $mq->service();
                print $uwriter "OK\n";
                next;
	    }

            if ( $command =~ /^__CHECKMAGNET ([^ ]+) ([^ ]+) ([^\r\n]+)/ ) {
                my $found = 0;
                for my $magnet ($b->get_magnets( $1, $2 ) ) {
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

    $b->postfork();

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
            $url = url( "http://127.0.0.1:$port$1" );
            $content = get($url);
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
            $reply =~ /^OK ([^\r\n]+)/;
            test_assert_equal( $1, $expected, "From script line $line_number" );
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

        if ( $line =~ /[^ \t\r\n]/ ) {
            test_assert( 0, "Don't understand line $line_number" );
	}
    }

    close SCRIPT;

    # TODO Validate every page in the interface against the W3C HTML 4.01
    # validation service

    print $dwriter "__QUIT\n";
    $content = <$ureader>;
    test_assert_equal( $content, "OK\n" );
    close $dwriter;
    close $ureader;

    $p->stop();

    while ( waitpid( $pid, &WNOHANG ) != $pid ) {
    }

    $b->stop();
}

1;
