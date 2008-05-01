#----------------------------------------------------------------------------
#
# This package contains an HTTP server used as a base class for other
# modules that service requests over HTTP (e.g. the UI)
#
# Copyright (c) 2001-2006 John Graham-Cumming
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
#----------------------------------------------------------------------------
package UI::HTTP;

use POPFile::Module;
@ISA = ("POPFile::Module");

use strict;
use warnings;
use locale;

use IO::Socket::INET qw(:DEFAULT :crlf);
use IO::Select;

# We use crypto to secure the contents of POPFile's cookies

use Crypt::CBC;
use MIME::Base64;

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

    # Crypto object used to encode/decode cookies

    $self->{crypto__} = '';

    bless $self;

    return $self;
}

# ---------------------------------------------------------------------------
#
# start
#
# Called to start the HTTP interface running
#
# ---------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    if ( $self->config_( 'https_enabled' ) ) {
        require IO::Socket::SSL;

        $self->{server_}{https} = IO::Socket::SSL->new( Proto     => 'tcp',   # PROFILE BLOCK START
                                    $self->config_( 'local' )  == 1 ? (LocalAddr => 'localhost') : (),
                                     LocalPort => $self->config_( 'https_port' ),
                                     Listen    => SOMAXCONN,
                                     SSL_cert_file => $self->get_user_path_( $self->global_config_( 'cert_file' ) ),
                                     SSL_key_file => $self->get_user_path_( $self->global_config_( 'key_file' ) ),
                                     SSL_ca_file => $self->get_user_path_( $self->global_config_( 'ca_file' ) ),
                                     Reuse     => 1 );                        # PROFILE BLOCK STOP
    }

    $self->{server_}{http} = IO::Socket::INET->new( Proto     => 'tcp',       # PROFILE BLOCK START
                                    $self->config_( 'local' )  == 1 ? (LocalAddr => 'localhost') : (),
                                     LocalPort => $self->config_( 'port' ),
                                     Listen    => SOMAXCONN,
                                     Reuse     => 1 );                        # PROFILE BLOCK STOP

    if ( !defined( $self->{server_}{http} ) ||       # PROFILE BLOCK START
         ( $self->config_( 'https_enabled' ) &&
           !defined( $self->{server_}{https} ) ) ) { # PROFILE BLOCK STOP
        my ( $port, $protocol );

        if ( !defined( $self->{server_}{http} ) ) {
            $port = $self->config_( 'port' );
            $protocol = 'HTTP';
        } else {
            $port = $self->config_( 'https_port' );
            $protocol = 'HTTPS';
        }
        my $name = $self->name();
        print STDERR <<EOM;                                                   # PROFILE BLOCK START

\nCouldn't start the $name $protocol interface because POPFile could not bind to the
$protocol port $port. This could be because there is another service
using that port or because you do not have the right privileges on
your system (On Unix systems this can happen if you are not root
and the port you specified is less than 1024).

EOM
# PROFILE BLOCK STOP

        return 0;
    }

    foreach my $protocol ( keys %{$self->{server_}} ) {
        $self->{selector_}{$protocol} = new IO::Select( $self->{server_}{$protocol} );
    }

    # Think of an encryption key for encrypting cookies using Blowfish

    my $cipher = $self->config_( 'cookie_cipher' );
    my $key_length = 8;

    if ( $cipher =~ /(Crypt::)?Blowfish/i ) {
        $key_length = 56;
    }
    if ( $cipher =~ /(Crypt::)?DES/i ) {
        $key_length = 8;
    }

    my $key = $self->random_()->generate_random_string( # PROFILE BLOCK START
                $key_length,
                $self->global_config_( 'crypt_strength' ),
                $self->global_config_( 'crypt_devide' )
              );                                         # PROFILE BLOCK STOP
    $self->{crypto__} = new Crypt::CBC( { 'key'            => $key, # PROFILE BLOCK START
                                          'cipher'         => $cipher,
                                          'padding'        => 'standard',
                                          'prepend_iv'     => 0,
                                          'regenerate_key' => 0,
                                          'salt'           => 1,
                                          'header'         => 'salt', } ); # PROFILE BLOCK STOP

    return 1;
}

# ----------------------------------------------------------------------------
#
# stop
#
# Called when the interface must shutdown
#
# ----------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;

    if ( defined( $self->{server_} ) ) {
        foreach my $protocol ( keys %{$self->{server_}} ) {
            close $self->{server_}{$protocol} if ( defined( $self->{server_}{$protocol} ) );
        }
    }

    $self->SUPER::stop();
}

# ----------------------------------------------------------------------------
#
# service
#
# Called to handle interface requests
#
# ----------------------------------------------------------------------------
sub service
{
    my ( $self ) = @_;

    my $code = 1;

    # See if there's a connection waiting for us, if there is we
    # accept it handle a single request and then exit

    foreach my $protocol ( keys %{$self->{server_}} ) {

        my ( $ready ) = $self->{selector_}{$protocol}->can_read(0);

        # Handle HTTP requests for the UI

        if ( ( defined( $ready ) ) && ( $ready == $self->{server_}{$protocol} ) ) {

            if ( my $client = $self->{server_}{$protocol}->accept() ) {

                # Check that this is a connection from the local machine,
                # if it's not then we drop it immediately without any
                # further processing.  We don't want to allow remote users
                # to admin POPFile

                my ( $remote_port, $remote_host ) = sockaddr_in( $client->peername() );

                if ( ( $self->config_( 'local' ) == 0 ) ||                # PROFILE BLOCK START
                     ( $remote_host eq inet_aton( "127.0.0.1" ) ) ) {     # PROFILE BLOCK STOP

                    # Read the request line (GET or POST) from the client
                    # and if we manage to do that then read the rest of
                    # the HTTP headers grabbing the Content-Length and
                    # using it to read any form POST content into $content

                    $client->autoflush(1);

                    if ( ( defined( $client ) ) &&                      # PROFILE BLOCK START
                         ( my $request = $self->slurp_( $client ) ) ) { # PROFILE BLOCK STOP
                        my $content_length = 0;
                        my $content;
                        my $cookie = '';

                        $self->log_( 2, $request );

                        while ( my $line = $self->slurp_( $client ) )  {
                            $cookie = $1 if ( $line =~ /Cookie: (.+)/ );
                            $content_length = $1 if ( $line =~ /Content-Length: (\d+)/i );
                            # Discovered that Norton Internet Security was
                            # adding HTTP headers of the form
                            #
                            # ~~~~~~~~~~~~~~: ~~~~~~~~~~~~~
                            #
                            # which we were not recognizing as valid
                            # (surprise, surprise) and this was messing
                            # about our handling of POST data.  Changed
                            # the end of header identification to any line
                            # that does not contain a :

                            last                 if ( $line !~ /:/ );
                        }

                        if ( $content_length > 0 ) {
                            $content = $self->slurp_buffer_( $client, # PROFILE BLOCK START
                                $content_length );                    # PROFILE BLOCK STOP
                            $self->log_( 2, $content );
                        }

                        # Handle decryption of a cookie header

                        $cookie = $self->decrypt_cookie__( $cookie );

                        if ( $request =~ /^(GET|POST) (.*) HTTP\/1\./i ) {
                            $code = $self->handle_url( $client, $2, $1, # PROFILE BLOCK START
                                        $content, $cookie );            # PROFILE BLOCK STOP
                            $self->log_( 2,                                # PROFILE BLOCK START
                                "HTTP handle_url returned code $code\n" ); # PROFILE BLOCK STOP
                        } else {
                            $self->http_error_( $client, 500 );
                        }
                    }
                }

                $self->log_( 2, "Close HTTP connection on $client\n" );
                $self->done_slurp_( $client );
                close $client;
            }
        }

    }

    return $code;
}

# ----------------------------------------------------------------------------
#
# forked
#
# Called when someone forks POPFile
#
# ----------------------------------------------------------------------------
sub forked
{
    my ( $self, $writer ) = @_;

    $self->SUPER::forked( $writer );

    foreach my $protocol ( keys %{$self->{server_}} ) {
        close $self->{server_}{$protocol};
    }
}

# ----------------------------------------------------------------------------
#
# handle_url - Handle a URL request
#
# $client     The web browser to send the results to
# $url        URL to process
# $command    The HTTP command used (GET or POST)
# $content    Any non-header data in the HTTP command
# $cookie     Decrypted cookie value (or null)
#
# ----------------------------------------------------------------------------
sub handle_url
{
    my ( $self, $client, $url, $command, $content, $cookie ) = @_;

    return $self->{url_handler_}( $self, $client, $url, $command, # PROFILE BLOCK START
                                  $content, $cookie ); # PROFILE BLOCK STOP
}

# ----------------------------------------------------------------------------
#
# decrypt_cookie__
#
# $cookie            The cookie value to decrypt
#
# ----------------------------------------------------------------------------
sub decrypt_cookie__
{
    my ( $self, $cookie ) = @_;

    $self->log_( 2, "Decrypt cookie: $cookie" );

    $cookie =~ /popfile=([^\r\n]+)/;
    if ( defined( $1 ) ) {
        my $decoded_cookie = decode_base64( $1 );
        my $result = '';

        # Workaround to avoid crash when a wrong cookie is sent

        eval {
            $result = $self->{crypto__}->decrypt( $decoded_cookie );
        };

        return $result;
    }

    return '';
}

# ----------------------------------------------------------------------------
#
# encrypt_cookie_
#
# $cookie            The cookie value to encrypt
#
# ----------------------------------------------------------------------------
sub encrypt_cookie_
{
    my ( $self, $cookie ) = @_;

    $self->log_( 2, "Encrypting cookie $cookie" );
    return encode_base64( $self->{crypto__}->encrypt( $cookie ), '' );
}

# ----------------------------------------------------------------------------
#
# parse_form_    - parse form data and fill in $self->{form_}
#
# $arguments         The text of the form arguments (e.g. foo=bar&baz=fou) or separated by
#                    CR/LF
#
# ----------------------------------------------------------------------------
sub parse_form_
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
        my $arg = $self->url_decode_( $1 );

        my $need_array = defined( $self->{form_}{$arg} );

        if ( $need_array ) {
            if ( $#{ $self->{form_}{$arg . "_array"} } == -1 ) {
                push( @{ $self->{form_}{$arg . "_array"} }, $self->{form_}{$arg} );
            }
        }

        $self->{form_}{$arg} = $2;
        $self->{form_}{$arg} =~ s/\+/ /g;

        # Expand hex escapes in the form data

        $self->{form_}{$arg} =~ s/%([0-9A-F][0-9A-F])/chr hex $1/gie;

        # Push the value onto an array to allow for multiple values of
        # the same name

        if ( $need_array ) {
            push( @{ $self->{form_}{$arg . "_array"} }, $self->{form_}{$arg} );
        }
    }
}

# ----------------------------------------------------------------------------
#
# url_encode_
#
# $text     Text to encode for URL safety
#
# Encode a URL so that it can be safely passed in a URL as per RFC2396
#
# ----------------------------------------------------------------------------
sub url_encode_
{
    my ( $self, $text ) = @_;

    $text =~ s/ /\+/;
    $text =~ s/([^a-zA-Z0-9_\-.\+\'!~*\(\)])/sprintf("%%%02x",ord($1))/eg;

    return $text;
}

# ----------------------------------------------------------------------------
#
# url_decode_
#
# $text     Text to decode from URL safety
#
# Decode text in a URL
#
# ----------------------------------------------------------------------------
sub url_decode_
{
    my ( $self, $text ) = @_;

    $text =~ s/\+/ /;
    $text =~ s/(%([A-F0-9][A-F0-9]))/chr(hex($2))/eg;

    return $text;
}

# ----------------------------------------------------------------------------
#
# escape_html_
#
# $text     Text to HTML-escaped
#
# Escape &, ", >, <, '
#
# ----------------------------------------------------------------------------
sub escape_html_
{
    my ( $self, $text ) = @_;

    $text =~ s/&/&amp;/g;
    $text =~ s/\"/&quot;/g;
    $text =~ s/>/&gt;/g;
    $text =~ s/</&lt;/g;
    $text =~ s/'/&#39;/g;

    return $text;
}

# ----------------------------------------------------------------------------
#
# http_error_ - Output a standard HTTP error message
#
# $client     The web browser to send the results to
# $error      The error number
#
# Return a simple HTTP error message in HTTP 1/0 format
#
# ----------------------------------------------------------------------------
sub http_error_
{
    my ( $self, $client, $error ) = @_;

    $self->log_( 0, "HTTP error $error returned" );

    my $text =      # PROFILE BLOCK START
            "<html><head><title>POPFile Web Server Error $error</title></head>
<body>
<h1>POPFile Web Server Error $error</h1>
An error has occurred which has caused POPFile to return the error $error.
<p>
Click <a href=\"/\">here</a> to continue.
</body>
</html>$eol";       # PROFILE BLOCK STOP

    $self->log_( 1, $text );

    my $error_code = 500;
    $error_code = $error if ( $error eq '404' );

    print $client "HTTP/1.0 $error_code Error$eol";
    print $client "Content-Type: text/html$eol";
    print $client "Content-Length: ";
    print $client length( $text );
    print $client "$eol$eol";
    print $client $text;
}

# ----------------------------------------------------------------------------
#
# http_file_ - Read a file from disk and send it to the other end
#
# $client     The web browser to send the results to
# $file       The file to read (always assumed to be a GIF right now)
# $type       Set this to the HTTP return type (e.g. text/html or image/gif)
#
# Returns the contents of a file formatted into an HTTP 200 message or
# an HTTP 404 if the file does not exist
#
# ----------------------------------------------------------------------------
sub http_file_
{
    my ( $self, $client, $file, $type ) = @_;
    my $contents = '';

    if ( defined( $file ) && ( open FILE, "<$file" ) ) {

        binmode FILE;
        while (<FILE>) {
            $contents .= $_;
        }
        close FILE;

        # To prevent the browser for continuously asking for file
        # handled in this way we calculate the current date and time
        # plus 1 hour to give the browser cache 1 hour to keep things
        # like graphics and style sheets in cache.

        my $expires = $self->zulu_offset_( 0, 1 );
        my $header = "HTTP/1.0 200 OK$eol";
        $header .= "Content-Type: $type$eol";
        if ( $file =~ /\.log$/ || $file =~ /\.msg$/ ) {
            # The log/message files should not been cached

            $header .= "Pragma: no-cache$eol";
            $header .= "Cache-Control: no-cache$eol";
            $header .= "Expires: 0$eol";
        } else {
            $header .= "Expires: $expires$eol";
        }
        $header .= "Content-Length: ";
        $header .= length($contents);
        $header .= "$eol$eol";
        print $client $header . $contents;
    } else {
        $self->http_error_( $client, 404 );
    }
}

# ----------------------------------------------------------------------------
#
# zulu_offset_
#
# $days       Number of days to move forward
# $hours      Number of hours to move forward
#
# Returns the current time in Zulu as a string suitable for passing to
# a web browser shifted forward $days or $hours.
#
# ----------------------------------------------------------------------------
sub zulu_offset_
{
    my ( $self, $days, $hours ) = @_;

    my @day   = ( 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' );
    my @month = ( 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', # PROFILE BLOCK START
                  'Sep', 'Oct', 'Nov', 'Dec' );                           # PROFILE BLOCK STOP
    my $zulu = time;
    $zulu += 60 * 60 * $hours;
    $zulu += 24 * 60 * 60 * $days;
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday ) = gmtime( $zulu );

    return sprintf( "%s, %02d %s %04d %02d:%02d:%02d GMT",# PROFILE BLOCK START
               $day[$wday], $mday, $month[$mon], $year+1900,
               $hour, 59, 0);                             # PROFILE BLOCK STOP
}

sub history
{
    my ( $self, $value ) = @_;

    if ( defined( $value ) ) {
        $self->{history__} = $value;
    }

    return $self->{history__};
}

