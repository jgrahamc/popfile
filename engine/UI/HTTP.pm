#----------------------------------------------------------------------------
#
# This package contains an HTTP server used as a base class for other
# modules that service requests over HTTP (e.g. the UI)
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
#----------------------------------------------------------------------------
package UI::HTTP;

use POPFile::Module;
@ISA = ("POPFile::Module");

use strict;
use warnings;
use locale;

use IO::Socket::INET qw(:DEFAULT :crlf);
use IO::Select;

# A handy variable containing the value of an EOL for the network

my $eol = "\015\012";

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;
    my $self = POPFile::Module->new();

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# start
#
# Called to start the HTTP interface running
#
# ---------------------------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    $self->{server_} = IO::Socket::INET->new( Proto     => 'tcp',
                                    $self->config_( 'local' )  == 1 ? (LocalAddr => 'localhost') : (),
                                     LocalPort => $self->config_( 'port' ),
                                     Listen    => SOMAXCONN,
                                     Reuse     => 1 );

    if ( !defined( $self->{server_} ) ) {
        my $port = $self->config_( 'port' );
        my $name = $self->name();
        print <<EOM;

\nCouldn't start the $name HTTP interface because POPFile could not bind to the
HTTP port $port. This could be because there is another service
using that port or because you do not have the right privileges on
your system (On Unix systems this can happen if you are not root
and the port you specified is less than 1024).

EOM

        return 0;
    }

    $self->{selector_} = new IO::Select( $self->{server_} );

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# stop
#
# Called when the interface must shutdown
#
# ---------------------------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;

    close $self->{server_} if ( defined( $self->{server_} ) );
}

# ---------------------------------------------------------------------------------------------
#
# service
#
# Called to handle interface requests
#
# ---------------------------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;

    my $code = 1;

    # See if there's a connection waiting for us, if there is we accept it handle a single
    # request and then exit
    my ( $ready ) = $self->{selector_}->can_read(0);

    # Handle HTTP requests for the UI
    if ( ( defined( $ready ) ) && ( $ready == $self->{server_} ) ) {

        if ( my $client = $self->{server_}->accept() ) {

            # Check that this is a connection from the local machine, if it's not then we drop it immediately
            # without any further processing.  We don't want to allow remote users to admin POPFile

            my ( $remote_port, $remote_host ) = sockaddr_in( $client->peername() );

            if ( ( $self->config_( 'local' ) == 0 ) ||
                 ( $remote_host eq inet_aton( "127.0.0.1" ) ) ) {

                # Read the request line (GET or POST) from the client and if we manage to do that
                # then read the rest of the HTTP headers grabbing the Content-Length and using
                # it to read any form POST content into $content

                $client->autoflush(1);

                if ( ( defined( $client ) ) && ( my $request = <$client> ) ) {
                    my $content_length = 0;
                    my $content;

                    while ( <$client> )  {
                        $content_length = $1 if ( /Content-Length: (\d+)/i );
                        last                 if ( !/[A-Z]/i );
                    }

                    if ( $content_length > 0 ) {
                        $content = '';
                        $client->read( $content, $content_length, length( $content ) );
                    }

                    if ( $request =~ /^(GET|POST) (.*) HTTP\/1\./i ) {
                        $code = $self->handle_url( $client, $2, $1, $content );
                    } else {
                        http_error_( $self, $client, 500 );
                    }
                }
            }

            close $client;
        }
    }

    return $code;
}

# ---------------------------------------------------------------------------------------------
#
# forked
#
# Called when someone forks POPFile
#
# ---------------------------------------------------------------------------------------------
sub forked
{
    my ( $self ) = @_;

    close $self->{server_};
}

# ---------------------------------------------------------------------------------------------
#
# handle_url - Handle a URL request
#
# $client     The web browser to send the results to
# $url        URL to process
# $command    The HTTP command used (GET or POST)
# $content    Any non-header data in the HTTP command
#
# Takes a URL and splits it into the URL portion and form arguments specified in the command
# filling out the %form hash with the form elements and their values.  Checks the session
# key and refuses access unless it matches.  Serves up a small set of specific urls that are
# the main UI pages and then any GIF file in the POPFile directory and CSS files in the skins
# subdirectory
#
# ---------------------------------------------------------------------------------------------
sub handle_url
{
    my ( $self, $client, $url, $command, $content ) = @_;

    return $self->{url_handler_}( $self, $client, $url, $command, $content );
}

# ---------------------------------------------------------------------------------------------
#
# parse_form__    - parse form data and fill in $self->{form_}
#
# $arguments         The text of the form arguments (e.g. foo=bar&baz=fou)
#
# ---------------------------------------------------------------------------------------------
sub parse_form__
{
    my ( $self, $arguments ) = @_;

    # Normally the browser should have done &amp; to & translation on
    # URIs being passed onto us, but there was a report that someone
    # was having a problem with form arguments coming through with
    # something like http://127.0.0.1/history?session=foo&amp;filter=bar
    # which would mess things up in the argument splitter so this code
    # just changes &amp; to & for safety

    $arguments =~ s/&amp;/&/g;

    while ( $arguments =~ m/\G(.*?)=(.*?)(&|\r|\n|$)/g ) {
        my $arg = $1;

        $self->{form_}{$arg} = $2;
        $self->{form_}{$arg} =~ s/\+/ /g;

        # Expand %7E (hex) escapes in the form data

        $self->{form_}{$arg} =~ s/%([0-9A-F][0-9A-F])/chr hex $1/gie;

        # Push the value onto an array to allow for multiple values of the same name

        push( @{ $self->{form_}{$arg . "_array"} }, $self->{form_}{$arg} );
    }
}

# ---------------------------------------------------------------------------------------------
#
# url_encode_
#
# $text     Text to encode for URL safety
#
# Encode a URL so that it can be safely passed in a URL as per RFC2396
#
# ---------------------------------------------------------------------------------------------

sub url_encode_
{
    my ( $self, $text ) = @_;

    $text =~ s/ /\+/;
    $text =~ s/([^a-zA-Z0-9_\-.+])/sprintf("%%%02x",ord($1))/eg;

    return $text;
}

# ---------------------------------------------------------------------------------------------
#
# http_redirect_ - tell the browser to redirect to a url
#
# $client   The web browser to send redirect to
# $url      Where to go
#
# Return a valid HTTP/1.0 header containing a 302 redirect message to the passed in URL
#
# ---------------------------------------------------------------------------------------------
sub http_redirect_
{
    my ( $self, $client, $url ) = @_;

    my $header = "HTTP/1.0 302 Found\r\nLocation: ";
    $header .= $url;
    $header .= "$eol$eol";
    print $client $header;
}

# ---------------------------------------------------------------------------------------------
#
# http_error_ - Output a standard HTTP error message
#
# $client     The web browser to send the results to
# $error      The error number
#
# Return a simple HTTP error message in HTTP 1/0 format
#
# ---------------------------------------------------------------------------------------------
sub http_error_
{
    my ( $self, $client, $error ) = @_;

    print $client "HTTP/1.0 $error Error$eol$eol";
}

# ---------------------------------------------------------------------------------------------
#
# http_file_ - Read a file from disk and send it to the other end
#
# $client     The web browser to send the results to
# $file       The file to read (always assumed to be a GIF right now)
# $type       Set this to the HTTP return type (e.g. text/html or image/gif)
#
# Returns the contents of a file formatted into an HTTP 200 message or an HTTP 404 if the
# file does not exist
#
# ---------------------------------------------------------------------------------------------
sub http_file_
{
    my ( $self, $client, $file, $type ) = @_;
    my $contents = '';

    if ( open FILE, "<$file" ) {

        binmode FILE;
        while (<FILE>) {
            $contents .= $_;
        }
        close FILE;

        # To prevent the browser for continuously asking for file handled in this way
        # we calculate the current date and time plus 1 hour to give the browser
        # cache 1 hour to keep things like graphics and style sheets in cache.

        my @day   = ( 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' );
        my @month = ( 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' );
        my $zulu = time;
        $zulu += 60 * 60; # 1 hour
        my ( $sec, $min, $hour, $mday, $mon, $year, $wday ) = gmtime( $zulu );

        my $expires = sprintf( "%s, %02d %s %04d %02d:%02d:%02d GMT",
	                       $day[$wday], $mday, $month[$mon], $year+1900,
	                       $hour, $min, $sec);

        my $header = "HTTP/1.0 200 OK\r\nContent-Type: $type\r\nExpires: $expires\r\nContent-Length: ";
        $header .= length($contents);
        $header .= "$eol$eol";
        print $client $header . $contents;
    } else {
        http_error_( $self, $client, 404 );
    }
}


