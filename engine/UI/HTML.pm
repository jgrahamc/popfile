# POPFILE LOADABLE MODULE 5
package UI::HTML;

#----------------------------------------------------------------------------
#
# This package contains an HTML UI for POPFile
#
# Copyright (c) 2001-2005 John Graham-Cumming
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
#----------------------------------------------------------------------------

use UI::HTTP;
@ISA = ("UI::HTTP");

use strict;
use warnings;
use locale;

use IO::Socket;
use IO::Select;
use Digest::MD5 qw( md5_hex );
use HTML::Template;
use Date::Format;
use Date::Parse;

# Needed for cookie handling

use MIME::Base64;
use Crypt::CBC;
use Crypt::Random qw( makerandom_octet );
use Digest::MD5 qw( md5_hex );

# This is used to get the hostname of the current machine
# in a cross platform way to return in cookies

use Sys::Hostname;

# A handy variable containing the value of an EOL for the network

my $eol = "\015\012";

# Constant used by the history deletion code

my $seconds_per_day = 60 * 60 * 24;

# These are used for Japanese support

# ASCII characters
my $ascii = '[\x00-\x7F]';

# EUC-JP 2 byte characters
my $two_bytes_euc_jp = '(?:[\x8E\xA1-\xFE][\xA1-\xFE])';

# EUC-JP 3 byte characters
my $three_bytes_euc_jp = '(?:\x8F[\xA1-\xFE][\xA1-\xFE])';

# EUC-JP characters
my $euc_jp = "(?:$ascii|$two_bytes_euc_jp|$three_bytes_euc_jp)";

my %headers_table = ( 'from',       'From',            # PROFILE BLOCK START
                      'to',         'To',
                      'cc',         'Cc',
                      'subject',    'Subject',
                      'date',       'Date',
                      'inserted',   'Arrived',
                      'size',       'Size',
                      'bucket',     'Classification',
                      'id',         'ID',
                      'reclassify', 'Reclassify' ); # PROFILE BLOCK STOP

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;
    my $self = UI::HTTP->new();

    # The available skins

    $self->{skins__}           = ();

    # A hash containing a mapping between alphanumeric identifiers and
    # appropriate strings used for localization.  The string may
    # contain sprintf patterns for use in creating grammatically
    # correct strings, or simply be a string

    $self->{language__}        = {};

    # This is the list of available languages

    $self->{languages__} = ();

    # The last user to login via a proxy

    $self->{last_login__}      = '';

    # Used to determine whether the cache needs to be saved

    $self->{save_cache__}      = 0;

    # This stores the current UI sessions that are in progress.  It
    # maps an API session to the last time this entry was used.
    #
    # lastused                  When this cookie was last read or written
    # user                      The database user id
    # search/sort/filter/negate History page options

    $self->{sessions__} = ();

    # Must call bless before attempting to call any methods

    bless $self, $type;

    # This is the HTML module which we know as the HTML module

    $self->name( 'html' );

    return $self;
}

#----------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the interface
#
#----------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    # The default listen port for the UI

    $self->config_( 'port', 8080 );

    # Only accept connections from the local machine for the UI

    $self->config_( 'local', 1 );

    # Controls whether to cache templates or not

    $self->config_( 'cache_templates', 0 );

    # Controls whether or not we die if a template variable is missing
    # when we try to set it.  Setting it to 1 can be useful for
    # debugging purposes

    $self->config_( 'strict_templates', 0 );

    # Load skins

    $self->load_skins__();

    # Load the list of available user interface languages

    $self->load_languages__();

    # The parent needs a reference to the url handler function

    $self->{url_handler_} = \&url_handler__;

    # Finally register for the messages that we need to receive

    $self->mq_register_( 'UIREG', $self );
    $self->mq_register_( 'LOGIN', $self );

    $self->calculate_today();

    return 1;
}

#----------------------------------------------------------------------------
#
# start
#
# Called to start the HTML interface running
#
#----------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    # Get a query session with the History object

    $self->{q__} = $self->history_()->start_query();

    # Ensure that the messages subdirectory exists

    if ( !$self->history_()->make_directory__(
        $self->get_user_path_( $self->global_config_( 'msgdir' ) ) ) ) {
        print STDERR "Failed to create the messages subdirectory\n";
        return 0;
    }

    # Load the current configuration from disk and then load up the
    # appropriate language, note that we always load English first so
    # that any extensions to the user interface that have not yet been
    # translated will still appear

    $self->load_language( 'English' );
    if ( $self->user_config_( 1, 'language' ) ne 'English' ) {
        $self->load_language( $self->user_config_( 1, 'language' ) );
    }

    # Set the classifier option wmformat__ according to our
    # wordtable_format option.

    $self->classifier_()->wmformat( $self->user_config_( 1,
                                        'wordtable_format' ) );

    return $self->SUPER::start();
}

#----------------------------------------------------------------------------
#
# stop
#
# Called to stop the HTML interface running
#
#----------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;

    foreach my $session (keys %{$self->{sessions__}}) {
        $self->classifier_()->release_session_key( $session );
    }

    $self->history_()->stop_query( $self->{q__} );

    $self->SUPER::stop();
}

#----------------------------------------------------------------------------
#
# deliver
#
# Called by the message queue to deliver a message
#
# There is no return value from this method
#
#----------------------------------------------------------------------------
sub deliver
{
    my ( $self, $type, @message ) = @_;

    # Handle registration of UI components

    if ( $type eq 'UIREG' ) {
        $self->register_configuration_item__( @message );
    }

    if ( $type eq 'LOGIN' ) {
        $self->{last_login__} = $message[0];
    }
}

#----------------------------------------------------------------------------
#
# handle_cookie__
#
# Called with a decrypted cookie to extract the session ID from it if
# that session is already in the sessions__ hash then we just return
# the session, if not then we check the session for validity.  If it
# is valid then make an entry in the sessions hash.
#
# $cookie        The decrypted cookie string
# $client        The client from which we received the cookie
#
# Returns undef for a bad cookie, or bad session.
#
#----------------------------------------------------------------------------
sub handle_cookie__
{
    my ( $self, $cookie, $client ) = @_;

    $cookie =~ /^([^ ]+) (\d+) ([^ ]+) ([^ ]+) ([^ ]+)$/;
    my ( $garbage, $timeset, $session, $client_name, $checksum ) = ( $1, $2, $3, $4, $5 );

    if ( !defined( $checksum ) ) {
        return undef;
    }

    $self->log_( 2, "Received cookie: [$cookie] [$garbage] [$timeset] [$session] [$client_name] [$checksum]" );

    # First check that the checksum is valid.  This will check the
    # cookie has not been tampered with and the decryption worked

    if ( md5_hex( "$garbage $timeset $session $client_name " ) ne $checksum ) {
        $self->log_( 0, "Invalid cookie received, checksum failed" );
        return undef;
    }

    # Check that the cookie came from the peer that we expect it from
    # to prevent someone from being able to steal a cookie and reuse
    # it

    my $peer = $client->peername;
    my ($peer_port, $peer_addr) = sockaddr_in($peer);
    my $peer_name = inet_ntoa($peer_addr);

    if ( $client_name ne $peer_name ) {
        $self->log_( 0, "Rejecting cookie because of invalid client $client_name for $peer_name" );
        return undef;
    }

    # Now see if this cookie is just old and should be rejected anyway
    # (more than two weeks old)

    if ( $timeset < time - 2*7*24*60*60 ) {
        $self->log_( 0, "Rejecting old cookie" );
        return undef;
    }

    # Now see if this session has been recorded in the current
    # sessions, if so then return it, because we can assume that it is
    # valid

    if ( exists( $self->{sessions__}{$session} ) ) {
        $self->{sessions__}{$session}{lastused} = time;
        return $session;
    }

    # Let's see if the session key is the magic string LOGGED-OUT
    # in which case there's no session

    if ( $session eq 'LOGGED-OUT' ) {
        return undef;
    }

    # Otherwise check that the session ID is still valid in the API.

    my $user = $self->classifier_()->valid_session_key__( $session );

    if ( defined( $user ) ) {
        $self->{sessions__}{$session}{lastused} = time;
        $self->{sessions__}{$session}{user} = $user;
        $self->{sessions__}{$session}{sort} = '';
        $self->{sessions__}{$session}{filter} = '';
        $self->{sessions__}{$session}{search} = '';
        $self->{sessions__}{$session}{negate} = '';

        return $session;
    } else {
        return undef;
    }
}

#----------------------------------------------------------------------------
#
# set_cookie__
#
# $session       Valid session key
# $client        The client we are sending the cookie to
#
# Returns a Set-Cookie: header from a session
#
#----------------------------------------------------------------------------
sub set_cookie__
{
    my ( $self, $session, $client ) = @_;

    if ( !defined( $session ) ) {
        return '';
    } else {
        my $cookie_string;

        # The cookie consist of these things:
        #
        # Piece of random data, base64 encoded
        # Time this cookie is being set
        # Value of the $session variable
        # The IP address of the client that set the cookie
        # MD5 checksum of the data (hex encoded)

        $cookie_string =  encode_base64( makerandom_octet( Length => 16,
                                             Strength => 1 ),
                              '' );
        $cookie_string .= ' ';
        $cookie_string .= time;
        $cookie_string .= ' ';
        $cookie_string .= $session;
        $cookie_string .= ' ';
        my $peer = $client->peername;
        my ($peer_port, $peer_addr) = sockaddr_in($peer);
        my $peer_name = inet_ntoa($peer_addr);
        $cookie_string .= "$peer_name ";
        $cookie_string .= md5_hex( $cookie_string );

        $self->log_( 2, "Sending cookie: $cookie_string" );

        $cookie_string = $self->encrypt_cookie_( $cookie_string );

        my $http_header = "Set-Cookie: popfile=$cookie_string; ";
        $http_header   .= 'path=/; ';
        $http_header   .= 'expires=' . $self->zulu_offset_( 14, 0 );
        $http_header   .= "\r\n";

        $self->log_( 2, "Sending cookie header: $http_header" );

        return $http_header;
    }
}

#----------------------------------------------------------------------------
#
# url_handler__ - Handle a URL request
#
# $client     The web browser to send the results to
# $url        URL to process
# $command    The HTTP command used (GET or POST)
# $content    Any non-header data in the HTTP command
# $cookie     Decrypted cookie value (if any)
#
# Checks the session key and refuses access unless it matches.  Serves
# up a small set of specific urls that are the main UI pages and then
# any GIF file in the POPFile directory and CSS files in the skins
# subdirectory
#
#----------------------------------------------------------------------------
sub url_handler__
{
    my ( $self, $client, $url, $command, $content, $cookie ) = @_;

    # See if there's a cookie, see if the cookie is valid and if if it
    # is then update the session information.  The $session variable
    # will contain a valid session in the Classifer::Bayes interface
    # for the user, if the user is authenticated.

    my $session;

    if ( $cookie ne '' ) {
        $session = $self->handle_cookie__( $cookie, $client );
    }

    # See if there are any form parameters and if there are parse them
    # into the %form hash

    delete $self->{form_};

    # Remove a # element

    $url =~ s/#.*//;

    # If the URL was passed in through a GET then it may contain form
    # arguments separated by & signs, which we parse out into the
    # $self->{form_} where the key is the argument name and the value
    # the argument value, for example if you have foo=bar in the URL
    # then $self->{form_}{foo} is bar.

    if ( $command =~ /GET/i ) {
        if ( $url =~ s/\?(.*)// )  {
            $self->parse_form_( $1 );
        }
    }

    # If the URL was passed in through a POST then look for the POST data
    # and parse it filling the $self->{form_} in the same way as for GET
    # arguments

    if ( $command =~ /POST/i ) {
        $content =~ s/[\r\n]//g;
        $self->parse_form_( $content );
    }

    # files in the skins directory load from the current skin if they exist
    # if not, they load from the default skin. The skin name is removed
    # from the path if possible (including the skin name in the URL helps
    # prevent caching

    if ( $url =~ /skins\/(([^\/]+)\/(([^\/]+\/)+)?)?([^\/]+)$/ ) {
        my $user = 1;
        my $path = ( $1 || '');
        my $path_skin = ( $2 || '');
        my $path_not_skin = ( $3 || '' );
        my $filename = ( $5 || '' );

        if ( defined( $session ) ) {
            $user = $self->{sessions__}{$session}{user};
        }

        my $config_skin = $self->user_config_( $user, 'skin' );

        my %mime_extensions = qw( gif image/gif
                                  png image/png
                                  ico image/x-icon
                                  jpg image/jpeg
                                  jpeg image/jpeg
                                  css text/css
                                  html text/html );
        my $path_is_skin = 0;

        if ( $path_skin eq $config_skin ) {
            $path_is_skin = 1;
        }

        my $template_root = 'skins/' . $config_skin . '/';

        if ( $path_is_skin ) {
            $template_root .= $path_not_skin;
        } else {
            $template_root .= $path;
        }

        my $file = $self->get_root_path_( "$template_root$filename" );
        if ( !( -e $file ) ) {
                $template_root = 'skins/default/';

                if ( $path_is_skin ) {
                    $template_root .= $path_not_skin;
                } else {
                    $template_root .= $path;
                }

                $file = $self->get_root_path_( "$template_root$filename" );
        }

        $self->log_(2, "Skin file $url mapped to $file");

        # determine mime type from extension -- crude, but we only
        # expect a few mime types

        my $mime;

        if ( $file =~ /.*?([^\.]+)$/ ) {
            $mime = $mime_extensions{$1} if ( defined( $1 ) )
        }

        # only allow access to file types explicitly permitted by
        # inclusion in the %mime_extensions hash

        if ( defined($mime) ) {
            $self->http_file_( $client, $file, $mime );
        } else {
            $self->log_( 0,
                "Unknown mime type loaded from skins folder. $filename" );
            $self->http_error_( $client, 404 );
        }
        return 1;
    }

    if ( $url =~ /\/autogen_(.+)\.bmp/ ) {
        $self->bmp_file__( $client, $1 );
        return 1;
    }

    if ( $url =~ /\/(.+\.gif)/ ) {
        $self->http_file_( $client, $self->get_root_path_( $1 ), 'image/gif' );
        return 1;
    }

    if ( $url =~ /\/(.+\.png)/ ) {
        $self->http_file_( $client, $self->get_root_path_( $1 ), 'image/png' );
        return 1;
    }

    if ( $url =~ /\/(.+\.ico)/ ) {
        $self->http_file_( $client, $self->get_root_path_( $1 ),
             'image/x-icon' );
        return 1;
    }

    if ( $url =~ /(manual\/.+\.html)/ ) {
        $self->http_file_( $client, $self->get_root_path_( $1 ), 'text/html' );
        return 1;
    }

    if ( $url eq '/jump_to_message' )  {
        $self->{form_}{filter}    = '';
        $self->{form_}{negate}    = '';
        $self->{form_}{search}    = '';
        $self->{form_}{setsearch} = 1;

        my $slot = $self->{form_}{view};

        if ( ( $slot =~ /^\d+$/ ) &&
             ( $self->history_()->is_valid_slot( $slot ) ) ) {
            $self->http_redirect_( $client,
                 "/view?view=$slot", $session );
        } else {
            $self->http_redirect_( $client, "/history", $session );
        }

        return 1;
    }

    # If we don't have a valid session key, then insist that the user
    # log in, or check the username and password for validity, if they
    # are valid then create the session now

    if ( !defined( $session ) ) {
        $session = $self->password_page( $client );
        if ( defined( $session ) ) {
            $self->http_redirect_( $client, '/', $session );
        }
        return 1;
    }

    if ( $url =~ /(popfile.*\.log)/ ) {
        $self->http_file_( $client, $self->logger_()->debug_filename(),
            'text/plain' );
        return 1;
    }

    if ( $url eq '/logout' ) {
        $self->http_redirect_( $client, '/', 'LOGGED-OUT' );
        return 1;
    }

    if ( ( $url eq '/shutdown' ) &&
         ( $self->user_global_config_( $self->{sessions__}{$session}{user},
               'can_admin' ) ) )  {
        my $http_header = "HTTP/1.1 200 OK\r\n";
        $http_header .= "Connection: close\r\n";
        $http_header .= "Pragma: no-cache\r\n";
        $http_header .= "Expires: 0\r\n";
        $http_header .= "Cache-Control: no-cache\r\n";
        $http_header .= $self->set_cookie__( $session, $client );
        $http_header .= "Content-Type: text/html";
        $http_header .= "; charset=$self->{language__}{LanguageCharset}\r\n";
        $http_header .= "Content-Length: ";

        my $text = $self->shutdown_page__( $session );

        $http_header .= length($text);
        $http_header .= "$eol$eol";

        if ( $client->connected ) {
            print $client $http_header . $text;
        }
        return 0;
    }

    # Watch out for clicks on the "Don't show me this again." buttons.
    # If that button is clicked for the bucket-setup item, we turn on
    # the training help item. And if this one is clicked away, both
    # will no longer be shown.

    if ( exists $self->{form_}{nomore_bucket_help} &&
         $self->{form_}{nomore_bucket_help} ) {
        $self->user_config_( $self->{sessions__}{$session}{user}, 'show_bucket_help', 0 );
        $self->user_config_( $self->{sessions__}{$session}{user}, 'show_training_help', 1 );
    }

    if ( exists $self->{form_}{nomore_training_help} &&
         $self->{form_}{nomore_training_help} ) {
        $self->user_config_( $self->{sessions__}{$session}{user}, 'show_training_help', 0 );
    }

    # The url table maps URLs that we might receive to pages that we
    # display, the page table maps the pages to the functions that
    # handle them and the related template

    my %page_table = (
        'administration' => [ \&administration_page,
            'administration-page.thtml' ],
        'buckets'        => [ \&corpus_page,
            'corpus-page.thtml'        ],
        'magnets'        => [ \&magnet_page,
            'magnet-page.thtml'        ],
        'advanced'       => [ \&advanced_page,
            'advanced-page.thtml'      ],
        'users'          => [ \&users_page,
            'users-page.thtml'         ],
        'history'        => [ \&history_page,
            'history-page.thtml'       ],
        'view'           => [ \&view_page,
            'view-page.thtml'          ] );

    my %url_table = ( '/administration' => 'administration',
                      '/buckets'        => 'buckets',
                      '/magnets'        => 'magnets',
                      '/advanced'       => 'advanced',
                      '/users'          => 'users',
                      '/view'           => 'view',
                      '/history'        => 'history',
                      '/'               => 'history' );

    # Check to see if this user has administration rights, if they do
    # not then remove the administration and advanced URLs

    if ( !$self->user_global_config_( $self->{sessions__}{$session}{user}, 'can_admin' ) ) {
        delete $url_table{administration};
        delete $url_table{advanced};
        delete $url_table{users};
    }

    # Any of the standard pages can be found in the url_table, the
    # other pages are probably files on disk

    if ( defined($url_table{$url}) )  {
        my ( $method, $template ) = @{$page_table{$url_table{$url}}};

        if ( !defined( $session ) ) {
            $self->http_error_( $client, 500 );
            return;
        }

        &{$method}( $self, $client,
                    $self->load_template__( $template, $url, $session ),
                    $template, $url, $session );
        return 1;
    }

    $self->http_error_( $client, 404 );
    return 1;
}

#---------------------------------------------------------------------------
#
# bmp_file__ - Sends a 1x1 bitmap of a specific color to the browser
#
# $client    The web browser to send result to
# $color     An HTML color (hex or named)
#
#----------------------------------------------------------------------------
sub bmp_file__
{
    my ( $self, $client, $color ) = @_;

    $color = lc($color);

    # TODO: this is dirty something higher up (HTTP) should be
    # decoding the URL

    $color =~ s/^%23//; # if we have an prefixed hex color value,
                        # just dump the encoded hash-mark (#)

    # If the color contains something other than hex then do a map
    # on it first and then get the hex color, from the hex color
    # create a BMP file and return it

    if ( $color !~ /^[0-9a-f]{6}$/ ) {
        $color = $self->classifier_()->{parser__}->map_color( $color );
    }

    if ( $color =~ /^([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/ ) {
        my $bmp = '424d3a0000000000000036000000280000000100000001000000010018000000000004000000eb0a0000eb0a00000000000000000000' . "$3$2$1" . '00';
        my $file = '';
        for my $i (0..length($bmp)/2-1) {
            $file .= chr(hex(substr($bmp,$i*2,2)));
        }
        my $http_header = "HTTP/1.1 200 OK\r\n";
        $http_header .= "Connection: close\r\n";
        $http_header .= "Pragma: no-cache\r\n";
        $http_header .= "Expires: 0\r\n";
        $http_header .= "Cache-Control: no-cache\r\n";
        $http_header .= "Content-Type: image/bmp\r\n";
        $http_header .= "Content-Length: ";
        $http_header .= length($file);
        $http_header .= "$eol$eol";

        if ( $client->connected ) {
            print $client $http_header . $file;
        }
        return 0;
    } else {
        return $self->http_error_( $client, 404 );
    }
}

#---------------------------------------------------------------------------
#
# http_ok - Output a standard HTTP 200 message with a body of data
# from a template
#
# $client    The web browser to send result to
# $templ     The template for the page to return
# $selected  Which tab is to be selected
# $session   The session key
#
#----------------------------------------------------------------------------
sub http_ok
{
    my ( $self, $client, $templ, $selected, $session ) = @_;

    $selected = -1 if ( !defined( $selected ) );

    my @tab = ( 'menuStandard', 'menuStandard', 'menuStandard', 'menuStandard', 'menuStandard', 'menuStandard', 'menuStandard' );
    $tab[$selected] = 'menuSelected' if ( ( $selected <= $#tab ) && ( $selected >= 0 ) );

    for my $i (0..$#tab) {
        $templ->param( "Common_Middle_Tab$i" => $tab[$i] );
    }

    my $update_check = '';

    # Check to see if we've checked for updates today.  If we have not
    # then insert a reference to an image that is generated through a
    # CGI.  Also send stats to the same site if that is allowed.

    if ( defined( $session ) && ( $self->{today__} ne $self->user_config_( $self->{sessions__}{$session}{user}, 'last_update_check' ) ) ) {
        $self->calculate_today();

        if ( $self->user_config_( $self->{sessions__}{$session}{user}, 'update_check' ) ) {
            my ( $major_version, $minor_version, $build_version ) =
                $self->version() =~ /^v([^.]*)\.([^.]*)\.(.*)$/;
            $templ->param( 'Common_Middle_If_UpdateCheck' => 1 );
            $templ->param( 'Common_Middle_Major_Version' => $major_version );
            $templ->param( 'Common_Middle_Minor_Version' => $minor_version );
            $templ->param( 'Common_Middle_Build_Version' => $build_version );
        }

        if ( defined( $session ) && ( $self->user_config_( $self->{sessions__}{$session}{user}, 'send_stats' ) ) ) {
            $templ->param( 'Common_Middle_If_SendStats' => 1 );
            my @buckets = $self->classifier_()->get_buckets(
                $session );
            my $bc      = $#buckets + 1;
            $templ->param( 'Common_Middle_Buckets'  => $bc );
            $templ->param( 'Common_Middle_Messages' => $self->mcount__( $session ) );
            $templ->param( 'Common_Middle_Errors'   => $self->ecount__( $session ) );
        }

        $self->user_config_( $self->{sessions__}{$session}{user}, 'last_update_check', $self->{today__}, 1 );
    }

    # Build an HTTP header for standard HTML

    my $http_header = "HTTP/1.1 200 OK\r\n";
    $http_header .= "Connection: close\r\n";
    $http_header .= "Pragma: no-cache\r\n";
    $http_header .= "Expires: 0\r\n";
    $http_header .= "Cache-Control: no-cache\r\n";

    # Make the cookie to be returned for this session, if there's no
    # session then clear the cookie

    $http_header .= $self->set_cookie__( $session, $client );
    $http_header .= "Content-Type: text/html";
    $http_header .= "; charset=$self->{language__}{LanguageCharset}\r\n";
    $http_header .= "Content-Length: ";

    my $text = $templ->output;

    $http_header .= length($text);
    $http_header .= "$eol$eol";

    if ( $client->connected ) {
        $client->print( $http_header . $text );
    }
}

#----------------------------------------------------------------------------
#
# handle_history_bar__ - handle the bar at the bottom of the page
# that allows selection of the history configuration items
#
# $client     The web browser to send the results to
# $templ      The loaded page template
# $template   Name of the loaded page template
# $page       URL of the page requested
# $session    API session
#
#----------------------------------------------------------------------------
sub handle_history_bar__
{
    my ( $self, $client, $templ, $template, $page, $session ) = @_;

    if ( defined($self->{form_}{page_size}) ) {
        if ( ( $self->{form_}{page_size} >= 1 ) &&
             ( $self->{form_}{page_size} <= 1000 ) ) {
            $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size', $self->{form_}{page_size} );
        } else {
            $self->error_message__( $templ,
                $self->{language__}{Configuration_Error4} );
            delete $self->{form_}{page_size};
        }
    }

    $templ->param( 'Configuration_Page_Size' =>
        $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) );

    if ( defined($self->{form_}{history_days}) ) {
        if ( ( $self->{form_}{history_days} >= 1 ) &&
             ( $self->{form_}{history_days} <= 366 ) ) {
            $self->user_module_config_( $self->{sessions__}{$session}{user}, 'history', 'history_days',
                $self->{form_}{history_days} );
        } else {
            $self->error_message__( $templ,
                $self->{language__}{Configuration_Error5} );
            $templ->param( 'Configuration_If_History_Days_Error' => 1 );
            delete $self->{form_}{history_days};
        }

        if ( defined( $self->{form_}{purge_history} ) ) {
             $self->history_()->cleanup_history();
        }
    }

    if ( defined( $self->{form_}{removecolumn} ) ) {
        my $columns = $self->user_config_( $self->{sessions__}{$session}{user}, 'columns' );
        $columns =~ s/\+$self->{form_}{removecolumn}/-$self->{form_}{removecolumn}/;
        $self->user_config_( $self->{sessions__}{$session}{user}, 'columns', $columns );
    }

    $templ->param( 'Configuration_History_Days' => $self->user_module_config_( $self->{sessions__}{$session}{user}, 'history', 'history_days' ) );
    if ( defined( $self->{form_}{update_fields} ) ) {
        my @columns = split(',', $self->user_config_( $self->{sessions__}{$session}{user}, 'columns' ));
        my $new_columns = '';
        foreach my $column (@columns) {
            $column =~ s/^(\+|\-)//;
            if ( defined($self->{form_}{$column})) {
                $new_columns .= '+';
            } else {
                $new_columns .= '-';
            }
            $new_columns .= $column;
            $new_columns .= ',';
        }
        $self->user_config_( $self->{sessions__}{$session}{user}, 'columns', $new_columns );
    }

    my @columns = split(',', $self->user_config_( $self->{sessions__}{$session}{user}, 'columns' ));
    my @column_data;
    foreach my $column (@columns) {
        my %row;
        $column =~ /(\+|\-)/;
        $row{Configuration_Field_Visible} = ( $1 eq '-' );
        my $selected = ($1 eq '+')?'checked':'';
        $column =~ s/^.//;
        $row{Configuration_Field_Name} = $column;
        $row{Configuration_Localized_Field_Name} =
           $self->{language__}{$headers_table{$column}};
        push ( @column_data, \%row );
    }
    $templ->param( 'Configuration_Loop_History_Columns' => \@column_data );

    # Handle move left or right of columns

    if ( defined( $self->{form_}{moveleft} ) ) {
        my $col = '+' . $self->{form_}{moveleft};
        my @cols = split( ',', $self->user_config_( $self->{sessions__}{$session}{user}, 'columns' ) );

        for my $i (1..$#cols) {
            if ( $cols[$i] eq $col ) {
                my $t = $cols[$i];
                $cols[$i] = $cols[$i-1];
                $cols[$i-1] = $t;
                last;
            }
        }
        $self->user_config_( $self->{sessions__}{$session}{user}, 'columns', join( ',', @cols ) );
    }
    if ( defined( $self->{form_}{moveright} ) ) {
        my $col = '+' . $self->{form_}{moveright};
        my @cols = split( ',', $self->user_config_( $self->{sessions__}{$session}{user}, 'columns' ) );

        for my $i (0..$#cols-1) {
            if ( $cols[$i] eq $col ) {
                my $t = $cols[$i];
                $cols[$i] = $cols[$i+1];
                $cols[$i+1] = $t;
                last;
            }
        }
        $self->user_config_( $self->{sessions__}{$session}{user}, 'columns', join( ',', @cols ) );
    }
}

#----------------------------------------------------------------------------
#
# handle_configuration_bar__ - handle the bar at the bottom of the page
# that allows selection of the skin and language
#
# $client     The web browser to send the results to
# $templ      The loaded page template
# $template   Name of the loaded page template
# $page       URL of the page requested
# $session    API session
#
# Return the template
#
#----------------------------------------------------------------------------
sub handle_configuration_bar__
{
    my ( $self, $client, $templ, $template, $page, $session ) = @_;

    if ( defined($self->{form_}{skin}) ) {
        $self->user_config_( $self->{sessions__}{$session}{user}, 'skin', $self->{form_}{skin} );
        $templ = $self->load_template__( $template, $page, $session );
    }

    if ( defined($self->{form_}{language}) ) {
        if ( $self->user_config_( $self->{sessions__}{$session}{user}, 'language' ) ne
                 $self->{form_}{language} ) {
            $self->user_config_( $self->{sessions__}{$session}{user}, 'language', $self->{form_}{language} );
            if ( $self->user_config_( $self->{sessions__}{$session}{user}, 'language' ) ne 'English' ) {
                $self->load_language( 'English', $session );
            }
            $self->load_language( $self->user_config_( $self->{sessions__}{$session}{user}, 'language' ), $session );

            # Force a template relocalization because the language has been
            # changed which changes the localization of the template

            $self->localize_template__( $templ );
        }
    }

    my ( @general_skins, @small_skins, @tiny_skins );
    for my $i (0..$#{$self->{skins__}}) {
        my %row_data;
        my $type = 'General';
        my $list = \@general_skins;
        my $name = $self->{skins__}[$i];
        $name =~ /\/([^\/]+)\/$/;
        $name = $1;
        my $selected = ( $name eq $self->user_config_( $self->{sessions__}{$session}{user}, 'skin' ) )?'selected':'';

        if ( $name =~ /tiny/ ) {
            $type = 'Tiny';
            $list = \@tiny_skins;
        } else {
            if ( $name =~ /small/ ) {
                $type = 'Small';
                $list = \@small_skins;
            }
        }

        $row_data{"Configuration_$type" . '_Skin'}     = $name;
        $row_data{"Configuration_$type" . '_Selected'} = $selected;

        push ( @$list, \%row_data );
    }
    $templ->param( "Configuration_Loop_General_Skins", \@general_skins );
    $templ->param( "Configuration_Loop_Small_Skins",   \@small_skins   );
    $templ->param( "Configuration_Loop_Tiny_Skins",    \@tiny_skins    );

    my @language_loop;
    foreach my $lang (@{$self->{languages__}}) {
        my %row_data;
        $row_data{Configuration_Language} = $lang;
        $row_data{Configuration_Selected_Language} = ( $lang eq $self->user_config_( $self->{sessions__}{$session}{user}, 'language' ) )?'selected':'';
        push ( @language_loop, \%row_data );
    }
    $templ->param( 'Configuration_Loop_Languages' => \@language_loop );

    if ( defined($self->{form_}{hide_configbar}) ) {
        $self->user_config_( $self->{sessions__}{$session}{user}, 'show_configbars', 0 );
        $templ->param( 'If_Show_Config_Bars' => 0 );
    }

    if ( defined ($self->{form_}{show_configbar}) ) {
        $self->user_config_( $self->{sessions__}{$session}{user}, 'show_configbars', 1 );
        $templ->param( 'If_Show_Config_Bars' => 1 );
    }

    return $templ;
}

#----------------------------------------------------------------------------
#
# administration_page - get the administration page
#
# $client     The web browser to send the results to
# $templ      The loaded page template
# $template   Name of the loaded page template
# $page       URL of the page requested
# $session    API session
#
#----------------------------------------------------------------------------
sub administration_page
{
    my ( $self, $client, $templ, $template, $page, $session ) = @_;

    $templ = $self->handle_configuration_bar__( $client, $templ, $template,
                                                    $page, $session );

    my $server_error = '';
    my $port_error   = '';

    $self->config_( 'local', $self->{form_}{localui}-1 )      if ( defined($self->{form_}{localui}) );
    $self->user_config_( $self->{sessions__}{$session}{user}, 'update_check', $self->{form_}{update_check}-1 ) if ( defined($self->{form_}{update_check}) );
    $self->user_config_( $self->{sessions__}{$session}{user}, 'send_stats', $self->{form_}{send_stats}-1 )   if ( defined($self->{form_}{send_stats}) );

    $templ->param( 'Security_If_Local' => ( $self->config_( 'local' ) == 1 ) );
    $templ->param( 'Security_If_Password_Updated' => ( defined($self->{form_}{password} ) ) );
    $templ->param( 'Security_If_Update_Check' => ( $self->user_config_( $self->{sessions__}{$session}{user}, 'update_check' ) == 1 ) );
    $templ->param( 'Security_If_Send_Stats' => ( $self->user_config_( $self->{sessions__}{$session}{user}, 'send_stats' ) == 1 ) );

    my ($status_message, $error_message);
    my %security_templates;

    for my $name (keys %{$self->{dynamic_ui__}{security}}) {
        $security_templates{$name} = $self->load_template__( $self->{dynamic_ui__}{security}{$name}{template}, $page, $session );
        ($status_message, $error_message) = $self->{dynamic_ui__}{security}{$name}{object}->validate_item( $name,
                                                                       $security_templates{$name},
                                                                       \%{$self->{language__}},
                                                                       \%{$self->{form_}} );

        # Tell the user anything the dynamic UI was interested in sharing
        $self->status_message__($templ,$status_message) if ( defined( $status_message ));
        $self->error_message__($templ, $error_message)  if ( defined( $error_message ));
    }

    my %chain_templates;

    for my $name (keys %{$self->{dynamic_ui__}{chain}}) {
        $chain_templates{$name} = $self->load_template__( $self->{dynamic_ui__}{chain}{$name}{template}, $page, $session );
        ($status_message, $error_message) = $self->{dynamic_ui__}{chain}{$name}{object}->validate_item( $name,
                                                                    $chain_templates{$name},
                                                                    \%{$self->{language__}},
                                                                    \%{$self->{form_}} );

        # Tell the user anything the dynamic UI was interested in sharing
        $self->status_message__($templ,$status_message) if ( defined( $status_message ));
        $self->error_message__($templ, $error_message)  if ( defined( $error_message ));

    }

    my $security_html = '';

    for my $name (sort keys %{$self->{dynamic_ui__}{security}}) {
        $self->{dynamic_ui__}{security}{$name}{object}->configure_item(
            $name, $security_templates{$name}, \%{$self->{language__}} );
        $security_html .= $security_templates{$name}->output;
    }

    my $chain_html = '';

    for my $name (sort keys %{$self->{dynamic_ui__}{chain}}) {
        $self->{dynamic_ui__}{chain}{$name}{object}->configure_item(
            $name, $chain_templates{$name}, \%{$self->{language__}} );
        $chain_html .= $chain_templates{$name}->output;
    }

    $templ->param( 'Security_Dynamic_Security' => $security_html );
    $templ->param( 'Security_Dynamic_Chain'    => $chain_html    );

   if ( ( defined($self->{form_}{debug}) ) &&
        ( ( $self->{form_}{debug} >= 1 ) &&
        ( $self->{form_}{debug} <= 4 ) ) ) {
       $self->global_config_( 'debug', $self->{form_}{debug}-1 );
   }

    # Load all of the templates that are needed for the dynamic parts of
    # the configuration page, and for each one call its validation interface
    # so that any error messages or informational messages are fixed up
    # first

    my %dynamic_templates;
    for my $name (keys %{$self->{dynamic_ui__}{configuration}}) {
        $dynamic_templates{$name} = $self->load_template__(
            $self->{dynamic_ui__}{configuration}{$name}{template}, $page,
            $session );
        ($status_message, $error_message) = $self->{dynamic_ui__}{configuration}{$name}{object}->validate_item(
            $name,
            $dynamic_templates{$name},
            \%{$self->{language__}},
            \%{$self->{form_}} );

        # Tell the user anything the dynamic UI was interested in sharing
        $self->status_message__($templ,$status_message) if ( defined( $status_message ));
        $self->error_message__($templ, $error_message)  if ( defined( $error_message ));
    }

    if ( defined($self->{form_}{ui_port}) ) {
        if ( ( $self->{form_}{ui_port} >= 1 ) &&
             ( $self->{form_}{ui_port} < 65536 ) ) {
            $self->config_( 'port', $self->{form_}{ui_port} );
        } else {
            $self->error_message__( $templ, $self->{language__}{Configuration_Error2} );
            delete $self->{form_}{ui_port};
        }
    }

    if ( defined($self->{form_}{ui_port} ) ) {
        $self->status_message__( $templ, sprintf( $self->{language__}{Configuration_UIUpdate},
                $self->config_( 'port' ) ) );
    }
    $templ->param( 'Configuration_UI_Port' => $self->config_( 'port' ) );

    if ( defined($self->{form_}{timeout}) ) {
        if ( ( $self->{form_}{timeout} >= 10 ) && ( $self->{form_}{timeout} <= 300 ) ) {
            $self->global_config_( 'timeout', $self->{form_}{timeout} );
        } else {
            $self->error_message__( $self->{language__}{Configuration_Error6} );
            delete $self->{form_}{timeout};
        }
    }

    $self->status_message__( sprintf( $self->{language__}{Configuration_TCPTimeoutUpdate}, $self->global_config_( 'timeout' ) ) ) if ( defined($self->{form_}{timeout} ) );
    $templ->param( 'Configuration_TCP_Timeout' => $self->global_config_( 'timeout' ) );

    # Insert all the items that are dynamically created from the
    # modules that are loaded

    my $configuration_html = '';
    my $last_module = '';
    for my $name (sort keys %{$self->{dynamic_ui__}{configuration}}) {
        $name =~ /^([^_]+)_/;
        my $module = $1;
        if ( $last_module ne $module ) {
            $last_module = $module;
            $configuration_html .= "<hr>\n<h2 class=\"configuration\">";
            $configuration_html .= uc($module);
            $configuration_html .= "</h2>\n";
        }
        $self->{dynamic_ui__}{configuration}{$name}{object}->configure_item(
            $name, $dynamic_templates{$name}, \%{$self->{language__}} );
        $configuration_html .= $dynamic_templates{$name}->output;
    }

    $templ->param( 'Configuration_Dynamic' => $configuration_html );
    $templ->param( 'Configuration_Debug_' . ( $self->global_config_( 'debug' ) + 1 ) . '_Selected' => 'selected' );

    if ( $self->global_config_( 'debug' ) & 1 ) {
        $templ->param( 'Configuration_If_Show_Log' => 1 );
    }

    $self->http_ok( $client,$templ, 4, $session );
}

#----------------------------------------------------------------------------
#
# pretty_number - format a number with ,s every 1000
#
# $number       The number to format
#
#----------------------------------------------------------------------------
sub pretty_number
{
    my ( $self, $number ) = @_;

    my $c = reverse $self->{language__}{Locale_Thousands};

    $number = reverse $number;
    $number =~ s/(\d{3})/$1$c/g;
    $number = reverse $number;
    $c =~ s/\./\\./g;
    $number =~ s/^$c(.*)/$1/;

    return $number;
}

#----------------------------------------------------------------------------
#
# pretty_date__ - format a date as the user wants to see it
#
# $date           Epoch seconds
# $long           Set to 1 if you want only the long date option
#
#----------------------------------------------------------------------------
sub pretty_date__
{
    my ( $self, $date, $long, $session ) = @_;

    my $user = 1;

    if ( defined( $session ) ) {
        $user = $self->{sessions__}{$session}{user};
    }

    $long = 0 if ( !defined( $long ) );
    my $format = $self->user_config_( $user, 'date_format' );

    if ( $format eq '' ) {
        $format = $self->{language__}{Locale_Date};
    }

    if ( $format =~ /[\t ]*(.+)[\t ]*\|[\t ]*(.+)/ ) {
        if ( ( $date < time ) &&
             ( $date > ( time - ( 7 * 24 * 60 * 60 ) ) ) ) {
            if ( $long ) {
                return time2str( $2, $date );
            } else {
                return time2str( $1, $date );
            }
        } else {
            return time2str( $2, $date );
        }
    } else {
        return time2str( $format, $date );
    }
}

#----------------------------------------------------------------------------
#
# users_page - Handle user creation, deletion, etc.
#
# $client     The web browser to send the results to
# $templ      The loaded page template
# $template   Name of the loaded page template
# $page       URL of the page requested
# $session    API session
#
#----------------------------------------------------------------------------
sub users_page
{
    my ( $self, $client, $templ, $template, $page, $session ) = @_;

    $templ = $self->handle_configuration_bar__( $client, $templ, $template,
                                                    $page, $session );

    # Handle user creation

    if ( exists( $self->{form_}{create} ) && ( $self->{form_}{newuser} ne '' ) ) {
        my $result = $self->classifier_()->create_user( $session, $self->{form_}{newuser}, $self->{form_}{clone} );
        if ( $result == 0 ) {
            if ( $self->{form_}{clone} ne '' ) {
                 $self->status_message__( $templ, sprintf( $self->{language__}{Users_Created_And_Cloned}, $self->{form_}{newuser}, $self->{form_}{clone} ) );
            } else {
                $self->status_message__( $templ, sprintf( $self->{language__}{Users_Created}, $self->{form_}{newuser} ) );
            }
        }
        if ( $result == 1 ) {
            $self->error_message__( $templ, sprintf( $self->{language__}{Users_Not_Created_Exists}, $self->{form_}{newuser} ) );
        }
        if ( $result == 2 ) {
            $self->error_message__( $templ, sprintf( $self->{language__}{Users_Not_Created}, $self->{form_}{newuser} ) );
        }
        if ( $result == 3 ) {
            $self->error_message__( $templ, sprintf( $self->{language__}{Users_Created_Not_Cloned}, $self->{form_}{newuser}, $self->{form_}{clone} ) );
        }
    }

    # Handle user removal

    if ( exists( $self->{form_}{remove} ) && ( $self->{form_}{toremove} ne '' ) ) {
        my $result = $self->classifier_()->remove_user( $session, $self->{form_}{toremove} );
        if ( $result == 0 ) {
            $self->status_message__( $templ, sprintf( $self->{language__}{Users_Removed}, $self->{form_}{toremove} ) );
        }
        if ( $result == 1 ) {
            $self->error_message__( $templ, sprintf( $self->{language__}{Users_Removed_Failed}, $self->{form_}{toremove} ) );
        }
        if ( $result == 2 ) {
            $self->error_message__( $templ, sprintf( $self->{language__}{Users_Removed_Failed_Admin}, $self->{form_}{toremove} ) );
        }
    }

    # Handle editing the parameters of a user

    if ( defined( $self->{form_}{update_params} ) ) {
        my $id = $self->classifier_()->get_user_id( $session, $self->{form_}{editname} );
        foreach my $param (sort keys %{$self->{form_}}) {
            if ( $param =~ /parameter_(.*)/ ) {
                $self->classifier_()->set_user_parameter_from_id( $id,
                    $1, $self->{form_}{$param} );
            }
        }
    }

    my $users = $self->classifier_()->get_user_list( $session );

    my @user_loop;
    my @remove_user_loop;
    foreach my $user (@$users) {
        my %row_data;
        $row_data{Users_Name} = $user;
        push ( @user_loop, \%row_data);
        if ( $user ne 'admin' ) {
            push ( @remove_user_loop, \%row_data);
        }
    }
    if ( $#remove_user_loop != -1 ) {
        $templ->param( 'Users_Loop_Remove' => \@remove_user_loop );
        $templ->param( 'Users_If_Remove' => 1 );
    }
    $templ->param( 'Users_Loop_Edit' => \@user_loop );
    $templ->param( 'Users_Loop_Copy' => \@user_loop );

    if ( exists( $self->{form_}{edituser} ) ) {
        my $id = $self->classifier_()->get_user_id( $session, $self->{form_}{editname} );
        my @parameters = $self->classifier_()->get_user_parameter_list( $session );

        my @parameter_list;
        my $last = '';
        foreach my $param (sort @parameters) {
            my %row_data;
            $param =~ /^([^_]+)_/;
            if ( ( $last ne '' ) && ( $last ne $1 ) ) {
                $row_data{Users_If_New_Module} = 1;
            } else {
                $row_data{Users_If_New_Module} = 0;
            }
            $last = $1;
            $row_data{Users_Parameter} = $param;
            my ( $val, $default ) = $self->classifier_()->get_user_parameter_from_id( $id, $param );
            $row_data{Users_Value} = $val;
            $row_data{Users_If_Changed} = !$default;
            push ( @parameter_list, \%row_data );
        }
        $templ->param( 'Users_Loop_Parameter' => \@parameter_list );
        $templ->param( 'Users_If_Editing_User' => 1 );
        $templ->param( 'Users_Edit_User_Name' => $self->{form_}{editname} );
    }

    $self->http_ok( $client, $templ, 5, $session );
}

#----------------------------------------------------------------------------
#
# advanced_page - very advanced configuration options
#
# $client     The web browser to send the results to
# $templ      The loaded page template
# $template   Name of the loaded page template
# $page       URL of the page requested
# $session    API session
#
#----------------------------------------------------------------------------
sub advanced_page
{
    my ( $self, $client, $templ, $template, $page, $session ) = @_;

    $templ = $self->handle_configuration_bar__( $client, $templ, $template,
                                                    $page, $session );

    # Handle updating the parameter table

    if ( defined( $self->{form_}{update_params} ) ) {
        foreach my $param (sort keys %{$self->{form_}}) {
            if ( $param =~ /parameter_(.*)/ ) {
                $self->configuration_()->parameter( $1,
                    $self->{form_}{$param} );
            }
        }

        $self->configuration_()->save_configuration();
    }

    if ( defined($self->{form_}{newword}) ) {
        my $result = $self->classifier_()->add_stopword( $session,
                         $self->{form_}{newword} );
        if ( $result == 0 ) {
            $templ->param( 'Advanced_If_Add_Message' => 1 );
        }
    }

    if ( defined($self->{form_}{word}) ) {
        my $result = $self->classifier_()->remove_stopword( $session,
                         $self->{form_}{word} );
        if ( $result == 0 ) {
            $templ->param( 'Advanced_If_Delete_Message' => 1 );
        }
    }

    # the word census
    my $last = '';
    my $need_comma = 0;
    my $groupCounter = 0;
    my $groupSize = 5;
    my @words = $self->classifier_()->get_stopword_list( $session );
    my $commas;

    my @word_loop;
    my $c;
    @words = sort @words;
    push ( @words, ' ' );
    for my $word (@words) {
        if ( $self->user_config_( $self->{sessions__}{$session}{user}, 'language' ) =~ /^Korean$/ ) {
            no locale;
            $word =~ /^(.)/;
            $c = $1;
        } else {
                if ( $self->user_config_( $self->{sessions__}{$session}{user}, 'language' ) =~ /^Nihongo$/ ) {
               no locale;
               $word =~ /^($euc_jp)/;
               $c = $1;
            } else {
               $word =~ /^(.)/;
               $c = $1;
            }
        }

        $last = $c if ( $last eq '' );

        if ( $c ne $last ) {
            my %row_data;
            $row_data{Advanced_Words} = $commas;
            $commas = '';

            if ( $groupCounter == $groupSize ) {
                $row_data{Advanced_Row_Class} = 'advancedAlphabetGroupSpacing';
            } else {
                $row_data{Advanced_Row_Class} = 'advancedAlphabet';
            }
            $row_data{Advanced_Character} = $last;

            if ( $groupCounter == $groupSize ) {
                $row_data{Advanced_Word_Class} = 'advancedWordsGroupSpacing';
                $groupCounter = 0;
            } else {
                $row_data{Advanced_Word_Class} = 'advancedWords';
            }
            $last = $c;
            $need_comma = 0;
            $groupCounter += 1;
            push ( @word_loop, \%row_data );
        }

        if ( $need_comma == 1 ) {
            $commas .= ", $word";
        } else {
            $commas .= $word;
            $need_comma = 1;
        }
    }

    $templ->param( 'Advanced_Loop_Word' => \@word_loop );

    $templ->param( 'Advanced_POPFILE_CFG' =>
        $self->get_user_path_( 'popfile.cfg' ) );

    my $last_module = '';

    my @param_loop;
    foreach my $param ($self->configuration_()->configuration_parameters()) {
        my $value = $self->configuration_()->parameter( $param );
        $param =~ /^([^_]+)_/;

        my %row_data;

        if ( ( $last_module ne '' ) && ( $last_module ne $1 ) ) {
            $row_data{Advanced_If_New_Module} = 1;
        } else {
            $row_data{Advanced_If_New_Module} = 0;
        }

        $last_module = $1;

        $row_data{Advanced_Parameter}   = $param;
        $row_data{Advanced_Value}       = $value;
        $row_data{Advanced_If_Changed}  =
            !$self->configuration_()->is_default( $param );
        $row_data{Advanced_If_Password} =
            ( $param =~ /_password/ ) ? 1 : 0;


        push ( @param_loop, \%row_data);
    }

    $templ->param( 'Advanced_Loop_Parameter' => \@param_loop );

    $self->http_ok( $client, $templ, 6, $session );
}

sub max
{
    my ( $a, $b ) = @_;

    return ( $a > $b )?$a:$b;
}

#----------------------------------------------------------------------------
#
# magnet_page - the list of bucket magnets
#
# $client     The web browser to send the results to
# $templ      The loaded page template
# $template   Name of the loaded page template
# $page       URL of the page requested
# $session    API session
#
#----------------------------------------------------------------------------
sub magnet_page
{
    my ( $self, $client, $templ, $template, $page, $session ) = @_;

    $templ = $self->handle_configuration_bar__( $client, $templ, $template,
                                                    $page, $session );

    my $magnet_message = '';

    if ( defined( $self->{form_}{delete} ) ) {
        for my $i ( 1 .. $self->{form_}{count} ) {
            if ( defined( $self->{form_}{"remove$i"} ) &&
               ( $self->{form_}{"remove$i"} ) ) {
                my $mtype   = $self->{form_}{"type$i"};
                my $mtext   = $self->{form_}{"text$i"};
                my $mbucket = $self->{form_}{"bucket$i"};

                $self->classifier_()->delete_magnet( $session, $mbucket, $mtype, $mtext );
            }
        }
    }

    if ( defined( $self->{form_}{count} ) &&
       ( defined( $self->{form_}{update} ) ||
         defined( $self->{form_}{create} ) ) ) {
        for my $i ( 0 .. $self->{form_}{count} ) {
            my $mtype   = $self->{form_}{"type$i"};
            my $mtext   = $self->{form_}{"text$i"};
            my $mbucket = $self->{form_}{"bucket$i"};

            if ( defined( $self->{form_}{update} ) ) {
                my $otype   = $self->{form_}{"otype$i"};
                my $otext   = $self->{form_}{"otext$i"};
                my $obucket = $self->{form_}{"obucket$i"};

                if ( defined( $otype ) ) {
                    $self->classifier_()->delete_magnet( $session,
                        $obucket, $otype, $otext );
                }
            }

            if ( ( defined($mbucket) ) &&
                 ( $mbucket ne '' ) &&
                 ( $mtext ne '' ) ) {

                # Support for feature request 77646 - import function.
                # goal is a method of creating multiple magnets all
                # with the same target bucket quickly.
                #
                # If we have multiple lines in $mtext, each line will
                # actually be used to create a new magnet all with the
                # same target.  We loop through all of the requested
                # magnets, check to make sure they are all valid (not
                # already existing, etc...) and then loop through them
                # again to create them.  this way, if even one isn't
                # valid, none will be created.
                #
                # We also get rid of an \r's that may have been passed
                # in.  We also and ignore lines containing, only white
                # space and if a line is repeated we add just one
                # bucket for it.

                $mtext =~ s/\r\n/\n/g;

                my @all_mtexts = split(/\n/,$mtext);
                my %mtext_hash;
                @mtext_hash{@all_mtexts} = ();
                my @mtexts = keys %mtext_hash;
                my $found = 0;

                foreach my $current_mtext (@mtexts) {
                    for my $bucket ($self->classifier_()->get_buckets_with_magnets(
                                        $session )) {
                        my %magnets;
                        @magnets{ $self->classifier_()->get_magnets(
                                      $session,
                                          $bucket, $mtype )} = ();

                        if ( exists( $magnets{$current_mtext} ) ) {
                            $found  = 1;
                            $magnet_message .= sprintf( $self->{language__}{Magnet_Error1}, "$mtype: $current_mtext", $bucket ) . '<br>';
                            last;
                        }
                    }

                    if ( $found == 0 )  {
                        for my $bucket ($self->classifier_()->get_buckets_with_magnets( $session )) {
                            my %magnets;
                            @magnets{ $self->classifier_()->get_magnets( $session, $bucket, $mtype )} = ();

                            for my $from (keys %magnets)  {
                                if ( ( $mtext =~ /\Q$from\E/ ) || ( $from =~ /\Q$mtext\E/ ) )  {
                                    $found = 1;
                                    $magnet_message .= sprintf( $self->{language__}{Magnet_Error2}, "$mtype: $current_mtext", "$mtype: $from", $bucket ) . '<br>';
                                    last;
                                }
                            }
                        }
                    }
                }

                if ( $found == 0 ) {
                    foreach my $current_mtext (@mtexts) {

                    # Skip magnet definition if it consists only of
                    # white spaces

                    if ( $current_mtext =~ /^[ \t]*$/ ) {
                        next;
                    }

                    # It is possible to type leading or trailing white
                    # space in a magnet definition which can later
                    # cause mysterious failures because the whitespace
                    # is eaten by the browser when the magnet is
                    # displayed but is matched in the regular
                    # expression that does the magnet matching and
                    # will cause failures... so strip off the
                    # whitespace

                    $current_mtext =~ s/^[ \t]+//;
                    $current_mtext =~ s/[ \t]+$//;

                    $self->classifier_()->create_magnet( $session, $mbucket, $mtype, $current_mtext );
                    if ( !defined( $self->{form_}{update} ) ) {
                        $magnet_message .= sprintf( $self->{language__}{Magnet_Error3}, "$mtype: $current_mtext", $mbucket )  . '<br>';
                    }
                }
            }
            }
        }
    }

    if ( $magnet_message ne '' ) {
        $templ->param( 'Magnet_If_Message' => 1 );
        $templ->param( 'Magnet_Message'    => $magnet_message );
    }

    # Current Magnets panel

    my $start_magnet = $self->{form_}{start_magnet};
    my $stop_magnet  = $self->{form_}{stop_magnet};
    my $magnet_count = $self->classifier_()->magnet_count( $session );
    my $navigator = '';

    if ( !defined( $start_magnet ) ) {
        $start_magnet = 0;
    }

    if ( !defined( $stop_magnet ) ) {
        $stop_magnet = $start_magnet + $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) - 1;
    }

    if ( $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) < $magnet_count ) {
        $self->set_magnet_navigator__( $templ, $start_magnet,
            $stop_magnet, $magnet_count, $session );
    }

    $templ->param( 'Magnet_Start_Magnet' => $start_magnet );

    my %magnet_types = $self->classifier_()->get_magnet_types( $session );
    my $i = 0;
    my $count = -1;

    my @magnet_type_loop;
    foreach my $type (keys %magnet_types) {
        my %row_data;
        $row_data{Magnet_Type} = $type;
        $row_data{Magnet_Type_Name} = $magnet_types{$type};
        push ( @magnet_type_loop, \%row_data );
    }
    $templ->param( 'Magnet_Loop_Types' => \@magnet_type_loop );

    my @buckets = $self->classifier_()->get_buckets( $session );
    my @magnet_bucket_loop;
    foreach my $bucket (@buckets) {
        my %row_data;
        my $bcolor = $self->classifier_()->get_bucket_color( $session, $bucket );
        $row_data{Magnet_Bucket} = $bucket;
        $row_data{Magnet_Bucket_Color} = $bcolor;
        push ( @magnet_bucket_loop, \%row_data );
    }
    $templ->param( 'Magnet_Loop_Buckets' => \@magnet_bucket_loop );

    # magnet listing

    my @magnet_loop;
    for my $bucket ($self->classifier_()->get_buckets_with_magnets( $session )) {
        for my $type ($self->classifier_()->get_magnet_types_in_bucket( $session, $bucket )) {
            for my $magnet ($self->classifier_()->get_magnets( $session, $bucket, $type ))  {
                my %row_data;
                $count += 1;
                if ( ( $count < $start_magnet ) || ( $count > $stop_magnet ) ) {
                    next;
                }

                $i += 1;

                # to validate, must replace & with &amp; stan todo
                # note: come up with a smarter regex, this one's a
                # bludgeon another todo: Move this stuff into a
                # function to make text safe for inclusion in a form
                # field

                my $validatingMagnet = $magnet;
                $validatingMagnet =~ s/&/&amp;/g;
                $validatingMagnet =~ s/</&lt;/g;
                $validatingMagnet =~ s/>/&gt;/g;

                # escape quotation characters to avoid orphan data
                # within tags todo: function to make arbitrary data
                # safe for inclusion within a html tag attribute
                # (inside double-quotes)

                $validatingMagnet =~ s/\"/\&quot\;/g;

                $row_data{Magnet_Row_ID}     = $i;
                $row_data{Magnet_Bucket}     = $bucket;
                $row_data{Magnet_MType}      = $type;
                $row_data{Magnet_Validating} = $validatingMagnet;
                $row_data{Magnet_Size}       = max(length($magnet),50);

                my @type_loop;
                for my $mtype (keys %magnet_types) {
                    my %type_data;
                    my $selected = ( $mtype eq $type )?"selected":"";
                    $type_data{Magnet_Type_Name} = $mtype;
                    $type_data{Magnet_Type_Localized} = $self->{language__}{$magnet_types{$mtype}};
                    $type_data{Magnet_Type_Selected} = $selected;
                    push ( @type_loop, \%type_data );
                }
                $row_data{Magnet_Loop_Loop_Types} = \@type_loop;

                my @bucket_loop;
                my @buckets = $self->classifier_()->get_buckets( $session );
                foreach my $mbucket (@buckets) {
                    my %bucket_data;
                    my $selected = ( $bucket eq $mbucket )?"selected":"";
                    my $bcolor   = $self->classifier_()->get_bucket_color( $session, $mbucket );
                    $bucket_data{Magnet_Bucket_Bucket}   = $mbucket;
                    $bucket_data{Magnet_Bucket_Color}    = $bcolor;
                    $bucket_data{Magnet_Bucket_Selected} = $selected;
                    push ( @bucket_loop, \%bucket_data );

                }
                $row_data{Magnet_Loop_Loop_Buckets} = \@bucket_loop;
                push ( @magnet_loop, \%row_data );
            }
        }
    }

    $templ->param( 'Magnet_Loop_Magnets' => \@magnet_loop );
    $templ->param( 'Magnet_Count_Magnet' => $i );

    $self->http_ok( $client, $templ, 2, $session );
}

#----------------------------------------------------------------------------
#
# bucket_page - information about a specific bucket
#
# $client     The web browser to send the results to
# $templ      The loaded page template
# $template   Name of the loaded page template
# $page       URL of the page requested
# $session    API session
#
#----------------------------------------------------------------------------
sub bucket_page
{
    my ( $self, $client, $templ, $template, $page, $session ) = @_;
    my $bucket = $self->{form_}{showbucket};

    $templ = $self->load_template__( 'bucket-page.thtml', $page, $session );

    $templ = $self->handle_configuration_bar__( $client, $templ, $template,
                                                    $page, $session );

    my $color = $self->classifier_()->get_bucket_color( $session, $bucket );
    $templ->param( 'Bucket_Main_Title' => sprintf( $self->{language__}{SingleBucket_Title}, "<font color=\"$color\">$bucket</font>" ) );

    my $bucket_count = $self->classifier_()->get_bucket_word_count( $session, $bucket );
    $templ->param( 'Bucket_Word_Count'   => $self->pretty_number( $bucket_count ) );
    $templ->param( 'Bucket_Unique_Count' => sprintf( $self->{language__}{SingleBucket_Unique}, $self->pretty_number( $self->classifier_()->get_bucket_unique_count( $session, $bucket ) ) ) );
    $templ->param( 'Bucket_Total_Word_Count' => $self->pretty_number( $self->classifier_()->get_word_count( $session ) ) );
    $templ->param( 'Bucket_Bucket' => $bucket );

    my $percent = '0%';
    if ( $self->classifier_()->get_word_count( $session ) > 0 )  {
        $percent = sprintf( '%6.2f%%', int( 10000 * $bucket_count / $self->classifier_()->get_word_count( $session ) ) / 100 );
    }
    $templ->param( 'Bucket_Percentage' => $percent );

    if ( $self->classifier_()->get_bucket_word_count( $session, $bucket ) > 0 ) {
        $templ->param( 'Bucket_If_Has_Words' => 1 );
        my @letter_data;
        for my $i ($self->classifier_()->get_bucket_word_prefixes( $session, $bucket )) {
            my %row_data;
            $row_data{Bucket_Letter} = $i;
            $row_data{Bucket_Bucket} = $bucket;
            if ( defined( $self->{form_}{showletter} ) && ( $i eq $self->{form_}{showletter} ) ) {
                $row_data{Bucket_If_Show_Letter} = 1;
                }
            push ( @letter_data, \%row_data );
                    }
        $templ->param( 'Bucket_Loop_Letters' => \@letter_data );

        if ( defined( $self->{form_}{showletter} ) ) {
            my $letter = $self->{form_}{showletter};

            $templ->param( 'Bucket_If_Show_Letter'   => 1 );
            $templ->param( 'Bucket_Word_Table_Title' => sprintf( $self->{language__}{SingleBucket_WordTable}, $bucket ) );
            $templ->param( 'Bucket_Letter'           => $letter );

            my %word_count;

            for my $j ( $self->classifier_()->get_bucket_word_list( $session, $bucket, $letter ) ) {
                $word_count{$j} = $self->classifier_()->get_count_for_word( $session, $bucket, $j );
                }

            my @words = sort { $word_count{$b} <=> $word_count{$a} || $a cmp $b } keys %word_count;

            my @rows;
            while ( @words ) {
                my %row_data;
                my @cols;
                for ( 1 .. 6 ) {
                    my %cell_data;
                    my $word = shift @words;

                    $cell_data{'Bucket_Word'}       = $word;
                    $cell_data{'Bucket_Word_Count'} = $word_count{$word};

                    push @cols, \%cell_data;
                    last unless @words;
                }
                $row_data{'Bucket_Loop_Column'} = \@cols;
                push @rows, \%row_data;
            }
            $templ->param( 'Bucket_Loop_Row' => \@rows );
       }
    }

    $self->http_ok( $client, $templ, 1, $session );
}

#----------------------------------------------------------------------------
#
# bar_chart_100 - Output an HTML bar chart
#
# %values       A hash of bucket names with values in series 0, 1, 2, ...
#
#----------------------------------------------------------------------------
sub bar_chart_100
{
    my ( $self, $session, %values ) = @_;

    my $templ = $self->load_template__( 'bar-chart-widget.thtml','',$session );
    my $total_count = 0;
    my @xaxis = sort {
        if ( $self->classifier_()->is_pseudo_bucket( $session, $a ) == $self->classifier_()->is_pseudo_bucket( $session, $b ) ) {
            $a cmp $b;
        } else {
            $self->classifier_()->is_pseudo_bucket( $session, $a ) <=> $self->classifier_()->is_pseudo_bucket( $session, $b );
        }
    } keys %values;

    return '' if ( $#xaxis < 0 );

    my @series = sort keys %{$values{$xaxis[0]}};

    for my $bucket (@xaxis)  {
        $total_count += $values{$bucket}{0};
    }

    my @bucket_data;
    for my $bucket (@xaxis)  {
        my %bucket_row_data;

        $bucket_row_data{bar_bucket_color} = $self->classifier_()->get_bucket_color( $session, $bucket );
        $bucket_row_data{bar_bucket_name}  = $bucket;

        my @series_data;
        for my $s (@series) {
            my %series_row_data;
            my $value = $values{$bucket}{$s} || 0;
            my $count   = $self->pretty_number( $value );
            my $percent = '';

            if ( $s == 0 ) {
                my $d = $self->{language__}{Locale_Decimal};
                if ( $total_count == 0 ) {
                    $percent = " (  0$d" . "00%)";
                } else {
                   $percent = sprintf( " (%.2f%%)", int( $value * 10000 / $total_count ) / 100 );
                   $percent =~ s/\./$d/;
                }
            }

            if ( ( $s == 2 ) &&
                 ( $self->classifier_()->is_pseudo_bucket( $session, $bucket ) ) ) {
                $count = '';
                $percent = '';
            }

            $series_row_data{bar_count}   = $count;
            $series_row_data{bar_percent} = $percent;

            push @series_data, \%series_row_data;
        }
        $bucket_row_data{bar_loop_series} = \@series_data;
        push @bucket_data, \%bucket_row_data;
    }

    $templ->param( 'bar_loop_xaxis' => \@bucket_data );

    $templ->param( 'bar_colspan' => 3 + $#series );

    if ( $total_count != 0 ) {
        $templ->param( 'bar_if_total_count' => 1 );
        @bucket_data = ();

        foreach my $bucket (@xaxis) {
            my %bucket_row_data;
            my $percent = sprintf "%.2f", ( $values{$bucket}{0} * 10000 / $total_count ) / 100;
            if ( $percent != 0 )  {
                $bucket_row_data{bar_if_percent}   = 1;
                $bucket_row_data{bar_bucket_color} = $self->classifier_()->get_bucket_color( $session, $bucket );
                $bucket_row_data{bar_bucket_name2} = $bucket;
                $bucket_row_data{bar_width}        = $percent;
                $bucket_row_data{Skin_Root}        = $self->{skin_root};
            }
            else {
                $bucket_row_data{bar_if_percent} = 0;
            }
            push @bucket_data, \%bucket_row_data;
        }
        $templ->param( 'bar_loop_total_xaxis' => \@bucket_data );
    }
    else {
        $templ->param( 'bar_if_total_count' => 0 );
    }

    return $templ->output();
}

#----------------------------------------------------------------------------
#
# corpus_page - the corpus management page
#
# $client     The web browser to send the results to
# $templ      The loaded page template
# $template   Name of the loaded page template
# $page       URL of the page requested
# $session    API session
#
#----------------------------------------------------------------------------
sub corpus_page
{
    my ( $self, $client, $templ, $template, $page, $session ) = @_;

    $templ = $self->handle_configuration_bar__( $client, $templ, $template,
                                                    $page, $session );

    if ( defined( $self->{form_}{clearbucket} ) ) {
        $self->classifier_()->clear_bucket( $session,
                                  $self->{form_}{showbucket} );
    }

    if ( defined($self->{form_}{reset_stats}) ) {
        foreach my $bucket ($self->classifier_()->get_all_buckets($session)) {
            $self->set_bucket_parameter__( $session, $bucket, 'count', 0 );
            $self->set_bucket_parameter__( $session, $bucket, 'fpcount', 0 );
            $self->set_bucket_parameter__( $session, $bucket, 'fncount', 0 );
        }
        my $lasttime = localtime;
        $self->user_config_( $self->{sessions__}{$session}{user}, 'last_reset', $lasttime );
        $self->configuration_()->save_configuration();
    }

    if ( defined($self->{form_}{showbucket}) )  {
        $self->bucket_page( $client, $templ, $template, $page, $session );
        return;
    }

    # This regular expression defines the characters that are NOT valid
    # within a bucket name

    my $invalid_bucket_chars = '[^[:lower:]\-_0-9]';

    if ( ( defined($self->{form_}{cname}) ) && ( $self->{form_}{cname} ne '' ) ) {
        if ( $self->{form_}{cname} =~ /$invalid_bucket_chars/ )  {
            $templ->param( 'Corpus_If_Create_Error' => 1 );
        } else {
            if ( $self->classifier_()->is_bucket( $session, $self->{form_}{cname} ) ||
                $self->classifier_()->is_pseudo_bucket( $session, $self->{form_}{cname} ) ) {
                $templ->param( 'Corpus_If_Create_Message' => 1 );
                $templ->param( 'Corpus_Create_Message' => sprintf( $self->{language__}{Bucket_Error2}, $self->{form_}{cname} ) );
            } else {
                $self->classifier_()->create_bucket( $session, $self->{form_}{cname} );
                $templ->param( 'Corpus_If_Create_Message' => 1 );
                $templ->param( 'Corpus_Create_Message' => sprintf( $self->{language__}{Bucket_Error3}, $self->{form_}{cname} ) );
            }
       }
    }

    if ( ( defined($self->{form_}{delete}) ) && ( $self->{form_}{name} ne '' ) ) {
        $self->{form_}{name} = lc($self->{form_}{name});
        $self->classifier_()->delete_bucket( $session, $self->{form_}{name} );
        $templ->param( 'Corpus_If_Delete_Message' => 1 );
        $templ->param( 'Corpus_Delete_Message' => sprintf( $self->{language__}{Bucket_Error6}, $self->{form_}{name} ) );
    }

    if ( ( defined($self->{form_}{newname}) ) &&
         ( $self->{form_}{oname} ne '' ) ) {
        if ( ( $self->{form_}{newname} eq '' ) ||
             ( $self->{form_}{newname} =~ /$invalid_bucket_chars/ ) )  {
            $templ->param( 'Corpus_If_Rename_Error' => 1 );
        } else {
            $self->{form_}{oname} = lc($self->{form_}{oname});
            $self->{form_}{newname} = lc($self->{form_}{newname});
            if ( $self->classifier_()->rename_bucket( $session, $self->{form_}{oname}, $self->{form_}{newname} ) == 1 ) {
                $templ->param( 'Corpus_If_Rename_Message' => 1 );
                $templ->param( 'Corpus_Rename_Message' => sprintf( $self->{language__}{Bucket_Error5}, $self->{form_}{oname}, $self->{form_}{newname} ) );
            } else {
                $templ->param( 'Corpus_If_Rename_Message' => 1 );
                $templ->param( 'Corpus_Rename_Message' => 'Internal error: rename failed' );
            }
        }
    }

    my @buckets = $self->classifier_()->get_buckets( $session );

    my $total_count = 0;
    my @delete_data;
    my @rename_data;
    foreach my $bucket (@buckets) {
        my %delete_row;
        my %rename_row;
        $delete_row{Corpus_Delete_Bucket} = $bucket;
        $delete_row{Corpus_Delete_Bucket_Color} = $self->get_bucket_parameter__( $session, $bucket, 'color' );
        $rename_row{Corpus_Rename_Bucket} = $bucket;
        $rename_row{Corpus_Rename_Bucket_Color} = $self->get_bucket_parameter__( $session, $bucket, 'color' );
        $total_count += $self->get_bucket_parameter__( $session, $bucket, 'count' );
        push ( @delete_data, \%delete_row );
        push ( @rename_data, \%rename_row );
    }
    $templ->param( 'Corpus_Loop_Delete_Buckets' => \@delete_data );
    $templ->param( 'Corpus_Loop_Rename_Buckets' => \@rename_data );

    my @pseudos = $self->classifier_()->get_pseudo_buckets( $session );
    push @buckets, @pseudos;

    # Check whether the user requested any changes to the per-bucket settings

    if ( defined($self->{form_}{bucket_settings}) ) {
        my @parameters = qw/subject xtc xpl quarantine/;
        foreach my $bucket ( @buckets ) {
            foreach my $variable ( @parameters ) {
                my $bucket_param = $self->get_bucket_parameter__( $session, $bucket, $variable );
                my $form_param = ( $self->{form_}{"${bucket}_$variable"} ) ? 1 : 0;

                if ( $form_param ne $bucket_param ) {
                    $self->set_bucket_parameter__( $session, $bucket, $variable, $form_param );
                }
            }

            # Since color isn't coded binary and only used for
            # non-pseudo buckets, we have to handle it separately

            unless ( $self->classifier_()->is_pseudo_bucket( $session, $bucket ) ) {
                my $bucket_color = $self->get_bucket_parameter__( $session, $bucket, 'color' );
                my $form_color = $self->{form_}{"${bucket}_color"};

                if ( $form_color ne $bucket_color ) {
                    $self->set_bucket_parameter__( $session, $bucket, 'color', $form_color );
                }
            }
        }
    }

    my @corpus_data;
    foreach my $bucket ( @buckets ) {
        my %row_data;
        $row_data{Corpus_Bucket}        = $bucket;
        $row_data{Corpus_Bucket_Color}  = $self->get_bucket_parameter__( $session, $bucket, 'color' );
        $row_data{Corpus_Bucket_Unique} = $self->pretty_number(  $self->classifier_()->get_bucket_unique_count( $session, $bucket ) );
        $row_data{Corpus_If_Bucket_Not_Pseudo} = !$self->classifier_()->is_pseudo_bucket( $session, $bucket );
        $row_data{Corpus_If_Subject}    = $self->get_bucket_parameter__( $session, $bucket, 'subject' );
        $row_data{Corpus_If_XTC}        = $self->get_bucket_parameter__( $session, $bucket, 'xtc' );
        $row_data{Corpus_If_XPL}        = $self->get_bucket_parameter__( $session, $bucket, 'xpl' );
        $row_data{Corpus_If_Quarantine} = $self->get_bucket_parameter__( $session, $bucket, 'quarantine' );
        my @color_data;
        foreach my $color (@{$self->classifier_()->{possible_colors__}} ) {
            my %color_row;
            $color_row{Corpus_Available_Color} = $color;
            $color_row{Corpus_Color_Selected}  = ( $row_data{Corpus_Bucket_Color} eq $color )?'selected':'';
            push ( @color_data, \%color_row );
        }
        $row_data{Localize_Apply}          = $self->{language__}{Apply};
        $row_data{Corpus_Loop_Loop_Colors} = \@color_data;
        push ( @corpus_data, \%row_data );
    }
    $templ->param( 'Corpus_Loop_Buckets' => \@corpus_data );

    my %bar_values;
    for my $bucket (@buckets)  {
        $bar_values{$bucket}{0} = $self->get_bucket_parameter__( $session, $bucket, 'count' );
        $bar_values{$bucket}{1} = $self->get_bucket_parameter__( $session, $bucket, 'fpcount' );
        $bar_values{$bucket}{2} = $self->get_bucket_parameter__( $session, $bucket, 'fncount' );
    }

    $templ->param( 'Corpus_Bar_Chart_Classification' => $self->bar_chart_100( $session, %bar_values ) );

    @buckets = $self->classifier_()->get_buckets( $session );

    delete $bar_values{unclassified};

    for my $bucket (@buckets)  {
        $bar_values{$bucket}{0} = $self->classifier_()->get_bucket_word_count( $session, $bucket );
        delete $bar_values{$bucket}{1};
        delete $bar_values{$bucket}{2};
    }

    $templ->param( 'Corpus_Bar_Chart_Word_Counts' => $self->bar_chart_100( $session, %bar_values ) );

    my $number = $self->pretty_number(  $self->classifier_()->get_unique_word_count( $session ) );
    $templ->param( 'Corpus_Total_Unique' => $number );

    my $pmcount = $self->pretty_number(  $self->mcount__( $session ) );
    $templ->param( 'Corpus_Message_Count' => $pmcount );

    my $pecount = $self->pretty_number(  $self->ecount__( $session ) );
    $templ->param( 'Corpus_Error_Count' => $pecount );

    my $accuracy = $self->{language__}{Bucket_NotEnoughData};
    my $percent = 0;
    if ( $self->mcount__( $session ) > $self->ecount__( $session ) ) {
        $percent = int( 10000 * ( $self->mcount__( $session ) - $self->ecount__( $session ) ) / $self->mcount__( $session ) ) / 100;
        $accuracy = "$percent%";
    }
    $templ->param( 'Corpus_Accuracy' => $accuracy );
    $templ->param( 'Corpus_If_Last_Reset' => 1 );
    $templ->param( 'Corpus_Last_Reset' => $self->user_config_( $self->{sessions__}{$session}{user}, 'last_reset' ) );
    my $now = localtime;
    my $days = ( str2time( $now ) - str2time( $self->user_config_( $self->{sessions__}{$session}{user}, 'last_reset' ) ) ) / ( 60 * 60 * 24 );

    if ( ( $self->mcount__( $session ) > 0 ) && ( $days > 0 ) ) {
        $templ->param( 'Corpus_PerDay_Count' => int( $self->mcount__( $session ) / $days ) );
    } else {
        $templ->param( 'Corpus_PerDay_Count' => 'N/A' );
    }

    if ( ( defined($self->{form_}{lookup}) ) || ( defined($self->{form_}{word}) ) ) {
        $templ->param( 'Corpus_If_Looked_Up' => 1 );
        $templ->param( 'Corpus_Word' => $self->{form_}{word} );
        my $word = $self->{form_}{word};

        if ( !( $word =~ /^[A-Za-z0-9\-_]+:/ ) ) {
            $word = $self->classifier_()->{parser__}->{mangle__}->mangle($word, 1);
        }

        if ( $self->{form_}{word} ne '' ) {
            my $max = 0;
                my $max_bucket = '';
            my $total = 0;
            foreach my $bucket (@buckets) {
                my $val = $self->classifier_()->get_value_( $session, $bucket, $word );
                if ( $val != 0 ) {
                    my $prob = exp( $val );
                    $total += $prob;
                    if ( $prob > $max ) {
                        $max = $prob;
                        $max_bucket = $bucket;
                    }
                } else {

                    # Take into account the probability the Bayes
                    # calculation applies for the buckets in which the
                    # word is not found.

                    $total += exp( $self->classifier_()->get_not_likely_( $session ) );
                }
            }

            my @lookup_data;
            foreach my $bucket (@buckets) {
                my $val = $self->classifier_()->get_value_( $session, $bucket, $word );

                if ( $val != 0 ) {
                    my %row_data;
                    my $prob    = exp( $val );
                      my $n       = ($total > 0)?$prob / $total:0;
                    my $score   = ($#buckets >= 0)?($val - $self->classifier_()->get_not_likely_( $session ) )/log(10.0):0;
                    my $d = $self->{language__}{Locale_Decimal};
                    my $normal  = sprintf("%.10f", $n);
                    $normal =~ s/\./$d/;
                    $score      = sprintf("%.10f", $score);
                    $score =~ s/\./$d/;
                    my $probf   = sprintf("%.10f", $prob);
                    $probf =~ s/\./$d/;
                    my $bold    = '';
                    my $endbold = '';
                    if ( $score =~ /^[^\-]/ ) {
                        $score = "&nbsp;$score";
                    }
                    $row_data{Corpus_If_Most_Likely} = ( $max == $prob );
                    $row_data{Corpus_Bucket}         = $bucket;
                    $row_data{Corpus_Bucket_Color}   = $self->get_bucket_parameter__( $session, $bucket, 'color' );
                    $row_data{Corpus_Probability}    = $probf;
                    $row_data{Corpus_Normal}         = $normal;
                    $row_data{Corpus_Score}          = $score;
                    push ( @lookup_data, \%row_data );
                }
            }
            $templ->param( 'Corpus_Loop_Lookup' => \@lookup_data );

            if ( $max_bucket ne '' ) {
                $templ->param( 'Corpus_Lookup_Message' => sprintf( $self->{language__}{Bucket_LookupMostLikely}, $word, $self->classifier_()->get_bucket_color( $session, $max_bucket ), $max_bucket ) );
            } else {
                $templ->param( 'Corpus_Lookup_Message' => sprintf( $self->{language__}{Bucket_DoesNotAppear}, $word ) );
            }
        }
    }

    $self->http_ok( $client, $templ, 1, $session );
}

#----------------------------------------------------------------------------
#
# compare_mf - Compares two mailfiles, used for sorting mail into order
#
#----------------------------------------------------------------------------
sub compare_mf
{
    $a =~ /popfile(\d+)=(\d+)\.msg/;
    my ( $ad, $am ) = ( $1, $2 );

    $b =~ /popfile(\d+)=(\d+)\.msg/;
    my ( $bd, $bm ) = ( $1, $2 );

    if ( $ad == $bd ) {
        return ( $bm <=> $am );
    } else {
        return ( $bd <=> $ad );
    }
}

#----------------------------------------------------------------------------
#
# set_history_navigator__
#
# Fix up the history-navigator-widget.thtml template
#
# $templ                - The template to fix up
# $start_message        - The number of the first message displayed
# $stop_message         - The number of the last message displayed
# $session              - API session
#
#----------------------------------------------------------------------------
sub set_history_navigator__
{
    my ( $self, $templ, $start_message, $stop_message, $session ) = @_;

    $templ->param( 'History_Navigator_Fields' => $self->print_form_fields_(0,1,('session','filter','search','sort','negate' ) ) );

    if ( $start_message != 0 )  {
        $templ->param( 'History_Navigator_If_Previous' => 1 );
        $templ->param( 'History_Navigator_Previous'    => $start_message - $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) );
    }

    # Only show two pages either side of the current page, the first
    # page and the last page
    #
    # e.g. [1] ... [4] [5] [6] [7] [8] ... [24]

    my $i = 0;
    my $p = 1;
    my $dots = 0;
    my @nav_data;
    while ( $i < $self->history_()->get_query_size( $self->{q__} ) ) {
        my %row_data;
        if ( ( $i == 0 ) ||
             ( ( $i + $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) ) >= $self->history_()->get_query_size( $self->{q__} ) ) ||
             ( ( ( $i - 2 * $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) ) <= $start_message ) &&
               ( ( $i + 2 * $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) ) >= $start_message ) ) ) {
            $row_data{History_Navigator_Page} = $p;
            $row_data{History_Navigator_I} = $i;
            if ( $i == $start_message ) {
                $row_data{History_Navigator_If_This_Page} = 1;
            } else {
                $row_data{History_Navigator_Fields} = $self->print_form_fields_(0,1,('session','filter','search','sort','negate'));
            }

            $dots = 1;
        } else {
            $row_data{History_Navigator_If_Spacer} = 1;
            if ( $dots ) {
                $row_data{History_Navigator_If_Dots} = 1;
            }
            $dots = 0;
        }

        $i += $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' );
        $p++;
        push ( @nav_data, \%row_data );
    }
    $templ->param( 'History_Navigator_Loop' => \@nav_data );

    if ( $start_message < ( $self->history_()->get_query_size( $self->{q__} ) - $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) ) )  {
        $templ->param( 'History_Navigator_If_Next' => 1 );
        $templ->param( 'History_Navigator_Next'    => $start_message + $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) );
    }
}

#----------------------------------------------------------------------------
#
# set_magnet_navigator__
#
# Sets the magnet navigator up in a template
#
# $templ         - The loaded Magnet page template
# $start_magnet  - The number of the first magnet
# $stop_magnet   - The number of the last magnet
# $magnet_count  - Total number of magnets
# $session       - API session
#
#----------------------------------------------------------------------------
sub set_magnet_navigator__
{
    my ( $self, $templ, $start_magnet, $stop_magnet, $magnet_count, $session ) = @_;

    if ( $start_magnet != 0 )  {
        $templ->param( 'Magnet_Navigator_If_Previous' => 1 );
        $templ->param( 'Magnet_Navigator_Previous'    => $start_magnet - $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) );
    }

    my $i = 0;
    my $count = 0;
    my @page_loop;
    while ( $i < $magnet_count ) {
        $templ->param( 'Magnet_Navigator_Enabled' => 1 );
        my %row_data;
        $count += 1;
        $row_data{Magnet_Navigator_Count} = $count;
        if ( $i == $start_magnet )  {
            $row_data{Magnet_Navigator_If_This_Page} = 1;
        } else {
            $row_data{Magnet_Navigator_If_This_Page} = 0;
            $row_data{Magnet_Navigator_Start_Magnet} = $i;
        }

        $i += $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' );
        push ( @page_loop, \%row_data );
    }
    $templ->param( 'Magnet_Navigator_Loop_Pages' => \@page_loop );

    if ( $start_magnet < ( $magnet_count - $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) ) )  {
        $templ->param( 'Magnet_Navigator_If_Next' => 1 );
        $templ->param( 'Magnet_Navigator_Next'    => $start_magnet + $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) );
    }
}


#----------------------------------------------------------------------------
#
# history_reclassify - handle the reclassification of messages on the
# history page
#
#----------------------------------------------------------------------------
sub history_reclassify
{
    my ( $self, $session ) = @_;

    if ( defined( $self->{form_}{change} ) ) {

        # Look for all entries in the form of the form reclassify_X
        # and see if they have values, those that have values indicate
        # a reclassification

        # Set up %messages to map a slot ID to the new bucket

        my %messages;

        foreach my $key (keys %{$self->{form_}}) {
            if ( $key =~ /^reclassify_([0-9]+)$/ ) {
                if ( defined( $self->{form_}{$key} ) &&
                     ( $self->{form_}{$key} ne '' ) ) {
                    $messages{$1} = $self->{form_}{$key};
                }
            }
        }

        $self->classifier_()->reclassify( $session, %messages );

        while ( my ( $slot, $newbucket ) = each %messages ) {
            $self->{feedback}{$slot} = sprintf(
                 $self->{language__}{History_ChangedTo},
                 $self->classifier_()->get_bucket_color(
                     $session, $newbucket ), $newbucket );
        }
    }
}

#----------------------------------------------------------------------------
#
# history_undo - handle undoing of reclassifications of messages on
# the history page
#
#----------------------------------------------------------------------------
sub history_undo
{
    my( $self, $session ) = @_;

    # Look for all entries in the form of the form undo_X and see if
    # they have values, those that have values indicate a
    # reclassification

    foreach my $key (keys %{$self->{form_}}) {
        if ( $key =~ /^undo_([0-9]+)$/ ) {
            my $slot = $1;
            my @fields = $self->history_()->get_slot_fields( $slot );
            my $bucket = $fields[8];
            my $newbucket = $self->classifier_()->get_bucket_name(
                                $session,
                                $fields[9] );
            $self->classifier_()->reclassified(
                $session, $newbucket, $bucket, 1 );
            $self->history_()->change_slot_classification(
                 $slot, $newbucket, $session, 1 );
            $self->classifier_()->remove_message_from_bucket(
                $session, $bucket,
                $self->history_()->get_slot_file( $slot ) );
        }
    }
}

#----------------------------------------------------------------------------
#
# history_page - get the message classification history page
#
# $client     The web browser to send the results to
# $templ      The loaded page template
# $template   Name of the loaded page template
# $page       URL of the page requested
# $session    API session
#
#----------------------------------------------------------------------------
sub history_page
{
    my ( $self, $client, $templ, $template, $page, $session ) = @_;

    # Handle the jump to page functionality

    if ( defined( $self->{form_}{gopage} ) ) {
        my $destination = ( $self->{form_}{jumptopage} - 1 ) * 
                     $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' );
        my $maximum = $self->history_()->get_query_size( $self->{q__} );
        
        if ( $destination <= $maximum && $destination > 0 ) {
            return $self->http_redirect_( $client, "/history?start_message=$destination&" 
                 . $self->print_form_fields_(1,0,('filter','search','sort','session','negate') ), $session );
        }
    }

    $templ = $self->handle_configuration_bar__( $client, $templ, $template,
                                                    $page, $session );
    $self->handle_history_bar__( $client, $templ, $template, $page, $session );

    # Set up default values for various form elements that have been
    # passed in or not so that we don't have to worry about undefined
    # values later on in the function

    $self->{form_}{sort}   = $self->{sessions__}{$session}{sort} || '-inserted' if ( !defined( $self->{form_}{sort}   ) );
    $self->{form_}{search} = (!defined($self->{form_}{setsearch})?$self->{sessions__}{$session}{search}:'') || '' if ( !defined( $self->{form_}{search} ) );
    $self->{form_}{filter} = (!defined($self->{form_}{setfilter})?$self->{sessions__}{$session}{filter}:'') || '' if ( !defined( $self->{form_}{filter} ) );

    # If the user hits the Reset button on a search then we need to
    # clear the search value but make it look as though they hit the
    # search button so that sort_filter_history will get called below
    # to get the right values in history_keys

    if ( defined( $self->{form_}{reset_filter_search} ) ) {
        $self->{form_}{filter}    = '';
        $self->{form_}{negate}    = '';
        delete $self->{form_}{negate_array};
        $self->{form_}{search}    = '';
        $self->{form_}{setsearch} = 1;
    }

    # If the user is asking for a new sort option then it needs to get
    # stored in the sort form variable so that it can be used for
    # subsequent page views of the History to keep the sort in place

    $self->{form_}{sort} = $self->{form_}{setsort} if ( defined( $self->{form_}{setsort} ) );

    # Cache some values to keep interface widgets updated if history
    # is re-accessed without parameters

    $self->{sessions__}{$session}{sort} = $self->{form_}{sort};

    # We are using a checkbox for negate, so we have to use an empty
    # hidden input of the same name and check for multiple occurences
    # or any of the name being defined

    if ( !defined( $self->{form_}{negate} ) ) {

        # if none of our negate inputs are active,
        # this is a "clean" access of the history

        $self->{form_}{negate} = $self->{sessions__}{$session}{negate} || '';

    } elsif ( defined( $self->{form_}{negate_array} ) ) {
        for ( @{$self->{form_}{negate_array}} ) {
            if ($_ ne '') {
                $self->{form_}{negate} = 'on';
                $self->{sessions__}{$session}{negate} = 'on';
                last;
            }
        }
    } else {

        # We have a negate form, but no array.. this is likely the
        # hidden input, so this is not a "clean" visit

        $self->{sessions__}{$session}{negate} = $self->{form_}{negate};
    }

    # Information from submit buttons isn't always preserved if the
    # buttons aren't pressed. This compares values in some fields and
    # sets the button-values as though they had been pressed

    # Set setsearch if search changed and setsearch is undefined

    $self->{form_}{setsearch} = 'on' if ( ( ( !defined($self->{sessions__}{$session}{search}) && ($self->{form_}{search} ne '') ) || ( defined($self->{sessions__}{$session}{search}) && ( $self->{sessions__}{$session}{search} ne $self->{form_}{search} ) ) ) && !defined($self->{form_}{setsearch} ) );
    $self->{sessions__}{$session}{search} = $self->{form_}{search};

    # Set setfilter if filter changed and setfilter is undefined

    $self->{form_}{setfilter} = 'Filter' if ( ( ( !defined($self->{sessions__}{$session}{filter}) && ($self->{form_}{filter} ne '') ) || ( defined($self->{sessions__}{$session}{filter}) && ( $self->{sessions__}{$session}{filter} ne $self->{form_}{filter} ) ) ) && !defined($self->{form_}{setfilter} ) );
    $self->{sessions__}{$session}{filter} = $self->{form_}{filter};

    # Set up the text that will appear at the top of the history page
    # indicating the current filter and search settings

    my $filter = $self->{form_}{filter};

    # Handle the reinsertion of a message file or the user hitting the
    # undo button

    $self->history_reclassify( $session );
    $self->history_undo( $session );

    # Handle removal of one or more items from the history page.  Two
    # important possibilities:
    #
    # clearpage is defined: this will delete everything on the page
    # which means we will call delete_slot in the history with the ID
    # of ever message displayed.  The IDs are encoded in the hidden
    # rowid_* form elements.
    #
    # clearchecked is defined: this will delete the messages that are
    # checked (i.e. the check box has been clicked).  The check box is
    # called remove_* in the form_ hash once we get here.
    #
    # The third possibility is clearall which is handled below and
    # uses the delete_query API of History.

    if ( defined( $self->{form_}{clearpage} ) ) {

        # Remove the list of marked messages using the array of
        # "remove" checkboxes

        $self->history_()->start_deleting();
        for my $i ( keys %{$self->{form_}} ) {
            if ( $i =~ /^rowid_(\d+)$/ ) {
                $self->log_( 1, "clearpage $i" );
                $self->history_()->delete_slot( $1 );
            }
        }
        $self->history_()->stop_deleting();
    }

    if ( defined( $self->{form_}{clearchecked} ) ) {

        # Remove the list of marked messages using the array of
        # "remove" checkboxes

        $self->history_()->start_deleting();
        for my $i ( keys %{$self->{form_}} ) {
            if ( $i =~ /^remove_(\d+)$/ ) {
                my $slot = $1;
                if ( $self->{form_}{$i} ne '' ) {
                    $self->log_( 1, "clearchecked $i" );
                    $self->history_()->delete_slot( $slot );
                }
            }
        }
        $self->history_()->stop_deleting();
    }

    # Handle clearing the history files, there are two options here,
    # clear the current page or clear all the files in the cache

    if ( defined( $self->{form_}{clearall} ) ) {
        $self->history_()->delete_query( $self->{q__} );
    }

    $self->history_()->set_query( $self->{q__},
                                   $self->{form_}{filter},
                                   $self->{form_}{search},
                                   $self->{form_}{sort},
                                   ( $self->{form_}{negate} ne '' ) );

    # Redirect somewhere safe if non-idempotent action has been taken

    if ( defined( $self->{form_}{deletemessage}  ) ||  # PROFILE BLOCK START
         defined( $self->{form_}{clearpage}      ) ||
         defined( $self->{form_}{undo}           ) ||
         defined( $self->{form_}{reclassify}     ) ) { # PROFILE BLOCK STOP
        return $self->http_redirect_( $client, "/history?" . $self->print_form_fields_(1,0,('start_message','filter','search','sort','session','negate') ), $session );
    }

    $templ->param( 'History_Field_Search'  => $self->{form_}{search} );
    $templ->param( 'History_Field_Not'  => $self->{form_}{negate} );
    $templ->param( 'History_If_Search'     => defined( $self->{form_}{search} ) );
    $templ->param( 'History_Field_Sort'    => $self->{form_}{sort} );
    $templ->param( 'History_Field_Filter'  => $self->{form_}{filter} );
    $templ->param( 'History_If_MultiPage'  => $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) <= $self->history_()->get_query_size( $self->{q__} ) );

    my @buckets = $self->classifier_()->get_buckets( $session );

    my @bucket_data;
    foreach my $bucket (@buckets) {
        my %row_data;
        $row_data{History_Bucket} = $bucket;
        $row_data{History_Bucket_Color}  = $self->classifier_()->get_bucket_parameter( $session,
                                                                      $bucket,
                                                                      'color' );
        push ( @bucket_data, \%row_data );
    }

    my @sf_bucket_data;
    foreach my $bucket (@buckets) {
        my %row_data;
        $row_data{History_Bucket} = $bucket;
        $row_data{History_Selected} = ( defined( $self->{form_}{filter} ) && ( $self->{form_}{filter} eq $bucket ) )?'selected':'';
        $row_data{History_Bucket_Color}  = $self->classifier_()->get_bucket_parameter( $session,
                                                                      $bucket,
                                                                      'color' );
        push ( @sf_bucket_data, \%row_data );
    }
    $templ->param( 'History_Loop_SF_Buckets' => \@sf_bucket_data );

    $templ->param( 'History_Filter_Magnet' => ($self->{form_}{filter} eq '__filter__magnet')?'selected':'' );
    $templ->param( 'History_Filter_Unclassified' => ($self->{form_}{filter} eq 'unclassified')?'selected':'' );
    $templ->param( 'History_Field_Not' => ($self->{form_}{negate} ne '')?'checked':'' );

    my $c = $self->history_()->get_query_size( $self->{q__} );
    if ( $c > 0 ) {
        $templ->param( 'History_If_Some_Messages' => 1 );
        $templ->param( 'History_Count' => $self->pretty_number( $c ) );

        my $start_message = 0;
        $start_message = $self->{form_}{start_message} if ( ( defined($self->{form_}{start_message}) ) && ($self->{form_}{start_message} > 0 ) );
        if ( $start_message >= $c ) {
            $start_message -= $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' );
        }
        if ( $start_message < 0 ) {
            $start_message = 0;
        }
        $self->{form_}{start_message} = $start_message;
        $templ->param( 'History_Start_Message' => $start_message );

        my $stop_message  = $start_message + $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ) - 1;
        $stop_message = $self->history_()->get_query_size( $self->{q__} ) - 1 if ( $stop_message >= $self->history_()->get_query_size( $self->{q__} ) );

        $self->set_history_navigator__( $templ, $start_message, $stop_message, $session );

        # Work out which columns to show by splitting the columns
        # parameter at commas keeping all the items that start with a
        # +, and then strip the +

        my @columns = split( ',', $self->user_config_( $self->{sessions__}{$session}{user}, 'columns' ) );
        my @header_data;
        my $colspan = 1;
        my $length = 90;

        foreach my $header (@columns) {
            my %row_data;
            $header =~ /^(.)/;
            next if ( $1 eq '-' );
            $colspan++;
            $header =~ s/^.//;
            $row_data{History_Fields} =
                $self->print_form_fields_(1,1,
                    ('filter','session','search','negate'));
            $row_data{History_Sort}   =
                ( $self->{form_}{sort} eq $header )?'-':'';
            $row_data{History_Header} = $header;

            my $label = '';
            if ( defined $self->{language__}{ $headers_table{$header} }) {
                $label = $self->{language__}{ $headers_table{$header} };
            } else {
                $label = $headers_table{$header};
            }
            $row_data{History_Label} = $label;
            $row_data{History_If_Sorted} =
                ( $self->{form_}{sort} =~ /^\-?\Q$header\E$/ );
            $row_data{History_If_Sorted_Ascending} =
                ( $self->{form_}{sort} !~ /^-/ );
            $row_data{History_If_MoveLeft} = ( $header ne $columns[0] );
            $row_data{History_If_MoveRight} = ( $header ne $columns[$#columns] );
            $row_data{Localize_History_RemoveColumn} = $self->{language__}{History_RemoveColumn};
            $row_data{Localize_History_Click_To_Sort} = $self->{language__}{History_Click_To_Sort};
            $row_data{Localize_History_MoveLeft} = $self->{language__}{History_MoveLeft};
            $row_data{Localize_History_MoveRight} = $self->{language__}{History_MoveRight};
            $row_data{Skin_Root} = $self->{skin_root};
            push ( @header_data, \%row_data );
            $length -= 10;
        }
        $templ->param( 'History_Loop_Headers' => \@header_data );
        $templ->param( 'History_Colspan' => $colspan );

        my @rows = $self->history_()->get_query_rows(
            $self->{q__}, $start_message+1,
            $stop_message - $start_message + 1 );

        my @history_data;
        my $i = $start_message;
        @columns = split( ',', $self->user_config_( $self->{sessions__}{$session}{user}, 'columns' ) );
        my $last = -1;
        if ( defined($self->{form_}{automatic}) ) {
            $self->user_config_( $self->{sessions__}{$session}{user}, 'column_characters', 0 );
        }
        if ( $self->user_config_( $self->{sessions__}{$session}{user}, 'column_characters' ) != 0 ) {
            $length = $self->user_config_( $self->{sessions__}{$session}{user}, 'column_characters' );
        }
        if ( defined($self->{form_}{increase}) ) {
            $length++;
            $self->user_config_( $self->{sessions__}{$session}{user}, 'column_characters', $length );
        }
        if ( defined($self->{form_}{decrease}) ) {
            $length--;
            if ( $length < 5 ) {
                $length = 5;
            }
            $self->user_config_( $self->{sessions__}{$session}{user}, 'column_characters', $length );
        }

        foreach my $row (@rows) {
            my %row_data;
            my $mail_file = $row_data{History_Mail_File} = $$row[0];
            my @column_data;
            my @cols = split(',', $self->user_config_( $self->{sessions__}{$session}{user}, 'columns' ));
            foreach my $header (@cols) {
                my %col_data;
                $header =~ /^(.)/;
                next if ( $1 eq '-' );
                $header =~ s/^.//;

                $col_data{History_If_Subject_Column} = 0;
                $col_data{History_If_Bucket_Column} = 0;

                my %dates = ( 'inserted' => 7, 'date' => 5 );

                if ( defined( $dates{$header} ) ) {
                    $col_data{History_Cell_Title} =
                        $self->pretty_date__( $$row[$dates{$header}], 1, $session );
                    $col_data{History_Cell_Value} =
                        $self->pretty_date__( $$row[$dates{$header}], undef, $session );
                    push ( @column_data, \%col_data );
                    next;
                }

                my %addresses = ( 'from' => 1, 'to' => 2 , 'cc' => 3 );

                 if ( defined( $addresses{$header} ) ) {
                     $col_data{History_Cell_Title} =$$row[$addresses{$header}];
                     $col_data{History_Cell_Value} =
                         $self->shorten__( $col_data{History_Cell_Title},
                                           $length );
                     push ( @column_data, \%col_data );
                     next;
                 }

                 if ($header eq 'subject') {
                     $col_data{History_If_Subject_Column} = 1;
                     $col_data{History_Cell_Title}    = $$row[4];
                     $col_data{History_Cell_Value} =
                         $self->shorten__( $$row[4], $length );
                     $col_data{History_Mail_File}     = $$row[0];
                     $col_data{History_Fields}        =
                         $self->print_form_fields_(0,1,
                           ('start_message','session','filter','search',
                            'sort','negate' ) );
                     push ( @column_data, \%col_data );
                     next;
                 }

                 if ($header eq 'size') {
                     my $size = $$row[12];
                     my $v = '?';
                     if ( defined $size ) {
                         if ( $size >= 1024 * 1024 ) {
                             $v = sprintf $self->{language__}{History_Size_MegaBytes}, $size / ( 1024 * 1024 );
                         } elsif ( $size >= 1024 ) {
                             $v = sprintf $self->{language__}{History_Size_KiloBytes}, $size / 1024;
                         } else {
                             $v =sprintf $self->{language__}{History_Size_Bytes}, $size;
                         }
                     }

                     # Replace any &nbsp; entities from the language
                     # files with the corresponding character
                     # (\xa0). Otherwise HTML::Template would escape
                     # the & with &amp;

                     $v =~ s/&nbsp;/\xA0/g;

                     $col_data{History_Cell_Value} = $v;
                     $col_data{History_Cell_Title} =
                         $col_data{History_Cell_Value};
                     push ( @column_data, \%col_data );
                     next;
                 }

                 if ($header eq 'bucket') {
                     $col_data{History_If_Bucket_Column} = 1;
                     my $bucket = $col_data{History_Bucket} = $$row[8];
                     $col_data{History_If_Magnetized} = ($$row[11] ne '');
                     $col_data{History_Magnet}        = $$row[11];
                     $col_data{Skin_Root} = $self->{skin_root};
                     $col_data{History_If_Not_Pseudo} =
                         !$self->classifier_()->is_pseudo_bucket(
                                          $session, $bucket );
                     $col_data{History_Bucket_Color}  =
                         $self->classifier_()->get_bucket_parameter(
                             $session, $bucket, 'color' );
                     push ( @column_data, \%col_data );
                     next;
                 }
            }

            $row_data{History_Loop_Loop_Cells} = \@column_data;
            $row_data{History_If_Reclassified} = ( $$row[9] != 0 );
            $row_data{History_I}             = $$row[0];
            $row_data{History_I1}            = $$row[0];
            $row_data{History_Loop_Loop_Buckets} = \@bucket_data;
            if ( defined $self->{feedback}{$mail_file} ) {
                $row_data{History_If_Feedback} = 1;
                $row_data{History_Feedback} = $self->{feedback}{$mail_file};
                delete $self->{feedback}{$mail_file};
            }

            if ( ( $last != -1 ) &&
                 ( $self->{form_}{sort} =~ /inserted/ ) &&
                 ( $self->user_config_( $self->{sessions__}{$session}{user}, 'session_dividers' ) ) ) {
                $row_data{History_If_Session} = ( abs( $$row[7] - $last ) >
                                                  300 );
                $row_data{History_Colspan} = $colspan+1;
            }

            $last = $$row[7];

            $row_data{Localize_History_Reclassified} =
                $self->{language__}{History_Reclassified};
            $row_data{Localize_Undo} = $self->{language__}{Undo};
            push ( @history_data, \%row_data );
        }
        $templ->param( 'History_Loop_Messages' => \@history_data );
    }

    $self->http_ok( $client, $templ, 0, $session );
}

sub shorten__
{
    my ( $self, $string, $length ) = @_;

    if ( length($string)>$length) {
       $string =~ /(.{$length})/;
       $string = "$1...";
    }

    return $string;
}

# ----------------------------------------------------------------------------
#
# http_redirect_ - tell the browser to redirect to a url
#
# $client   The web browser to send redirect to
# $url      Where to go
# $session  Possibly valid session ID
#
# Return a valid HTTP/1.0 header containing a 302 redirect message to
# the passed in URL
#
# ----------------------------------------------------------------------------
sub http_redirect_
{
    my ( $self, $client, $url, $session ) = @_;

    my $header = "HTTP/1.0 302 Found\r\n";
    $header .= "Location: $url\r\n";
    $header .= $self->set_cookie__( $session, $client );
    $header .= "\r\n";

    print $client $header;
}

#----------------------------------------------------------------------------
#
# view_page - Shows a single email
#
# $client     The web browser to send the results to
# $templ      The loaded page template
# $template   Name of the loaded page template
# $page       URL of the page requested
# $session    API session
#
#----------------------------------------------------------------------------
sub view_page
{
    my ( $self, $client, $templ, $template, $page, $session ) = @_;

    my $mail_file = $self->history_()->get_slot_file( $self->{form_}{view} );
    my $start_message = $self->{form_}{start_message} || 0;

    my ( $id, $from, $to, $cc, $subject, $date, $hash, $inserted,
        $bucket, $reclassified, $bucketid, $magnet ) =
        $self->history_()->get_slot_fields( $self->{form_}{view} );

    my $color = $self->classifier_()->get_bucket_color(
                    $session, $bucket );
    my $page_size = $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' );

    $self->{form_}{sort}   = '' if ( !defined( $self->{form_}{sort}   ) );
    $self->{form_}{search} = '' if ( !defined( $self->{form_}{search} ) );
    $self->{form_}{filter} = '' if ( !defined( $self->{form_}{filter} ) );
    if ( !defined( $self->{form_}{format} ) ) {
        $self->{form_}{format} = $self->user_config_( $self->{sessions__}{$session}{user}, 'wordtable_format' );
    }

    # If a format change was requested for the word matrix, record it
    # in the configuration and in the classifier options.

    $self->classifier_()->wmformat( $self->{form_}{format} );

    my $index = $self->{form_}{view};

    $templ->param( 'View_All_Fields'       => $self->print_form_fields_(1,1,('start_message','filter','session','search','sort','negate')));
    $templ->param( 'View_Field_Search'     => $self->{form_}{search} );
    $templ->param( 'View_Field_Negate'     => $self->{form_}{negate} );
    $templ->param( 'View_Field_Sort'       => $self->{form_}{sort}   );
    $templ->param( 'View_Field_Filter'     => $self->{form_}{filter} );

    $templ->param( 'View_From'             => $from );
    $templ->param( 'View_To'               => $to );
    $templ->param( 'View_Cc'               => $cc );
    $templ->param( 'View_Date'             => $self->pretty_date__( $date, 1, $session ) );
    $templ->param( 'View_Subject'          => $subject );
    $templ->param( 'View_Bucket'           => $bucket );
    $templ->param( 'View_Bucket_Color'     => $color );

    $templ->param( 'View_Index'            => $index );
    $templ->param( 'View_This'             => $index );
    $templ->param( 'View_This_Page'        => (( $index ) >= $start_message )?$start_message:($start_message - $self->user_config_( $self->{sessions__}{$session}{user}, 'page_size' ))); # TODO

    $templ->param( 'View_If_Reclassified'  => $reclassified );
    if ( $reclassified ) {
        $templ->param( 'View_Already' => sprintf( $self->{language__}{History_Already}, ($color || ''), ($bucket || '') ) );
    } else {
        $templ->param( 'View_If_Magnetized' => ( $magnet ne '' ) );
        if ( $magnet eq '' ) {
            my @bucket_data;
            foreach my $abucket ($self->classifier_()->get_buckets( $session )) {
                my %row_data;
                $row_data{View_Bucket_Color} = $self->classifier_()->get_bucket_color( $session, $abucket );
                $row_data{View_Bucket} = $abucket;
                push ( @bucket_data, \%row_data );
            }
            $templ->param( 'View_Loop_Buckets' => \@bucket_data );
        } else {
            $templ->param( 'View_Magnet' => $magnet );
        }
    }

    if ( $magnet eq '' ) {
        my %matrix;
        my %idmap;

        # Enable saving of word-scores

        $self->classifier_()->wordscores( 1 );

        # Build the scores by classifying the message, since
        # get_html_colored_message has parsed the message for us we do
        # not need to parse it again and hence we pass in undef for
        # the filename

        my $current_class = $self->classifier_()->classify(
            $session, $mail_file, $templ, \%matrix, \%idmap );

        # Check whether the original classfication is still valid.  If
        # not, add a note at the top of the page:

        if ( $current_class ne $bucket ) {
            my $new_color = $self->classifier_()->get_bucket_color(
                $session, $current_class );
            $templ->param( 'View_If_Class_Changed' => 1 );
            $templ->param( 'View_Class_Changed' => $current_class );
            $templ->param( 'View_Class_Changed_Color' => $new_color );
        }

        # Disable, print, and clear saved word-scores

        $self->classifier_()->wordscores( 0 );

        $templ->param( 'View_Message' =>
            $self->classifier_()->fast_get_html_colored_message(
                $session, $mail_file, \%matrix, \%idmap ) );

        # We want to insert a link to change the output format at the
        # start of the word matrix.  The classifier puts a comment in
        # the right place, which we can replace by the link.  (There's
        # probably a better way.)

        my $view = $self->{language__}{View_WordProbabilities};
        if ( $self->{form_}{format} eq 'freq' ) {
            $view = $self->{language__}{View_WordFrequencies};
        }
        if ( $self->{form_}{format} eq 'score' ) {
            $view = $self->{language__}{View_WordScores};
        }

        if ( $self->{form_}{format} ne '' ) {
            $templ->param( 'View_If_Format' => 1 );
            $templ->param( 'View_View' => $view );
        }
        if ($self->{form_}{format} ne 'freq' ) {
            $templ->param( 'View_If_Format_Freq' => 1 );
        }
        if ($self->{form_}{format} ne 'prob' ) {
            $templ->param( 'View_If_Format_Prob' => 1 );
        }
        if ($self->{form_}{format} ne 'score' ) {
            $templ->param( 'View_If_Format_Score' => 1 );
        }
    } else {

        # TODO: See comment below for details

        # $magnet =~ /(.+): ([^\r\n]+)/;
        # my $header = $1;
        # my $text   = $2;

        my $body = '<tt>';

        open MESSAGE, '<' . $mail_file;
        my $line;

        while ($line = <MESSAGE>) {
            $line =~ s/</&lt;/g;
            $line =~ s/>/&gt;/g;

            $line =~ s/([^\r\n]{100,150} )/$1<br \/>/g;
            $line =~ s/([^ \r\n]{150})/$1<br \/>/g;
            $line =~ s/[\r\n]+/<br \/>/g;

            # TODO: This code is now useless because the magnet itself
            # doesn't contain the information about which header we
            # are looking for.  Ultimately, we need to fix this but I
            # decided for v0.22.0 release to not make further changes
            # and leave this code as unfixed.

            # if ( $line =~ /^([A-Za-z-]+): ?([^\n\r]*)/ ) {
            #    my $head = $1;
            #    my $arg  = $2;
            #
            #    if ( $head =~ /\Q$header\E/i ) {
            #
            #        $text =~ s/</&lt;/g;
            #        $text =~ s/>/&gt;/g;
            #
            #        if ( $arg =~ /\Q$text\E/i ) {
            #            my $new_color = $self->classifier_()->get_bucket_color( $session, $bucket );
            #            $line =~ s/(\Q$text\E)/<b><font color=\"$new_color\">$1<\/font><\/b>/;
            #        }
            #    }
            # }

            $body .= $line;
        }
        close MESSAGE;
        $body .= '</tt>';
        $templ->param( 'View_Message' => $body );
    }

    if ($magnet ne '') {
        $templ->param( 'View_Magnet_Reason' => sprintf( $self->{language__}{History_MagnetBecause},  # PROFILE BLOCK START
                          $color, $bucket,
                          Classifier::MailParse::splitline($magnet,0)
            ) );                                                                                     # PROFILE BLOCK STOP
    }

    $self->http_ok( $client, $templ, 0, $session );
}

#----------------------------------------------------------------------------
#
# password_page - Simple page asking for the POPFile password
#
# $client     The web browser to send the results to
#
# Returns undef if login failed, or a session key value if it succeeded
#
#----------------------------------------------------------------------------
sub password_page
{
    my ( $self, $client ) = @_;

    my $session;
    my $templ = $self->load_template__( 'password-page.thtml' );

    $templ->param( 'Header_If_Password' => 1 );

    if ( exists( $self->{form_}{username} ) &&
         exists( $self->{form_}{password} ) ) {
        $session = $self->classifier_()->get_session_key(
                                              $self->{form_}{username},
                                              $self->{form_}{password} );

        if ( defined( $session ) ) {
            return $session;
        } else {
            $self->error_message__( $templ,
                       $self->{language__}{Password_Error1} );
        }
    }

    $self->http_ok( $client, $templ, 0, $session );

    return undef;
}

#----------------------------------------------------------------------------
#
# status_message__
#
# Called to cause the next page generated to show a status message
# (typically at the top)
#
# $templ             The current page template
# $message           The message to display
#
#----------------------------------------------------------------------------
sub status_message__
{
    my ( $self, $templ, $message ) = @_;

    my $old = $templ->param( 'Header_Message' ) || '';
    $templ->param( 'Header_If_Message' => 1 );
    $templ->param( 'Header_Message' =>($old ne '')?("$message<br />$old" ):$message);
}

#----------------------------------------------------------------------------
#
# error_message__
#
# Called to cause the next page generated to show a error message
# (typically at the top)
#
# $templ             The current page template
# $message           The message to display
#
#----------------------------------------------------------------------------
sub error_message__
{
    my ( $self, $templ, $message ) = @_;

    $message =~ s/\n/<br \/>/;

    my $old = $templ->param( 'Header_Error' ) || '';
    $templ->param( 'Header_If_Error' => 1 );
    $templ->param( 'Header_Error' => ($old ne '')?("$message<br />$old" ):$message);
}

#----------------------------------------------------------------------------
#
# load_template__
#
# Loads the named template and returns a new HTML::Template object
#
# $template          The name of the template to load from the current skin
# $page              Name of the page we are loading
# $session           The API session
#
#----------------------------------------------------------------------------
sub load_template__
{
    my ( $self, $template, $page, $session ) = @_;

    # First see if that template exists in the currently selected
    # skin, if it does not then load the template from the default.
    # This allows a skin author to change just a single part of
    # POPFile with duplicating that entire set of templates

    my $user = 1;

    if ( defined( $session ) ) {
        $user = $self->{sessions__}{$session}{user};
    }

    my $root = 'skins/' . $self->user_config_( $user, 'skin' ) . '/';
    my $template_root = $root;
    my $file = $self->get_root_path_( "$template_root$template" );
    if ( !( -e $file ) ) {
        $template_root = 'skins/default/';
        $file = $self->get_root_path_( "$template_root$template" );
    }

    my $css = $self->get_root_path_( $root . 'style.css' );
    if ( !( -e $css ) ) {
        $root = 'skins/default/';
    }

    my $templ = HTML::Template->new(
        filename          => $file,
        case_sensitive    => 1,
        loop_context_vars => 1,
        cache             => $self->config_( 'cache_templates' ),
        die_on_bad_params => $self->config_( 'strict_templates' ),
        search_path_on_include => 1,
        path => [$self->get_root_path_( "$root" ),
                 $self->get_root_path_( 'skins/default' ) ]
                                   );

    # Set a variety of common elements that are used repeatedly
    # throughout POPFile's pages

    my $now = time;
    my %fixups = ( 'Skin_Root'               => $root,
                   'Common_Bottom_Date'      => $self->pretty_date__( $now, undef, $session ),
                   'Common_Bottom_LastLogin' => $self->{last_login__},
                   'Common_Bottom_Version'   => $self->version(),
                   'If_Show_Bucket_Help'     =>
                       $self->user_config_( $user, 'show_bucket_help' ),
                   'If_Show_Training_Help'   =>
                       $self->user_config_( $user, 'show_training_help' ),
                   'If_Show_Config_Bars'     =>
                       $self->user_config_( $user, 'show_configbars' ),
                   'Common_Middle_If_CanAdmin' =>
                       $self->user_global_config_( $user, 'can_admin' ),
                   'Configuration_Action'      => $page );

    $self->{skin_root} = $root;

    foreach my $fixup (keys %fixups) {
        if ( $templ->query( name => $fixup ) ) {
            $templ->param( $fixup => $fixups{$fixup} );
        }
    }

    $self->localize_template__( $templ );

    return $templ;
}

#----------------------------------------------------------------------------
#
# localize_template__
#
# Localize a template by converting all the Localize_X variables to the
# appropriate variable X from the language__ hash.
#
#----------------------------------------------------------------------------
sub localize_template__
{
    my ( $self, $templ ) = @_;

    # Localize the template in use.
    #
    # Templates are automatically localized.  Any TMPL_VAR that begins
    # with Localize_ will be fixed up automatically with the
    # appropriate string for the language in use.  For example if you
    # write
    #
    #     <TMPL_VAR name="Localize_Foo_Bar">
    #
    # this will automatically be converted to the string associated
    # with Foo_Bar in the current language file.

    my @vars = $templ->param();

    foreach my $var (@vars) {
        if ( $var =~ /^Localize_(.*)/ ) {
            $templ->param( $var => $self->{language__}{$1} );
        }
    }
}

#----------------------------------------------------------------------------
#
# load_skins__
#
# Gets the names of all the directory in the skins subdirectory and
# loads them into the skins array.
#
#----------------------------------------------------------------------------
sub load_skins__
{
    my ( $self ) = @_;

    @{$self->{skins__}} = glob $self->get_root_path_( 'skins/*' );

    for my $i (0..$#{$self->{skins__}}) {
        $self->{skins__}[$i] =~ s/\/$//;
        $self->{skins__}[$i] .= '/';
    }
}

#----------------------------------------------------------------------------
#
# load_languages__
#
# Get the names of the available languages for the user interface
#
#----------------------------------------------------------------------------
sub load_languages__
{
    my ( $self ) = @_;

    @{$self->{languages__}} = glob $self->get_root_path_( 'languages/*.msg' );

    for my $i (0..$#{$self->{languages__}}) {
        $self->{languages__}[$i] =~ s/.*\/(.+)\.msg$/$1/;
    }
}

#----------------------------------------------------------------------------
#
# load_language
#
# Fill the language hash with the language strings that are from the
# named language file
#
# $lang    - The language to load (no .msg extension)
#
#----------------------------------------------------------------------------
sub load_language
{
    my ( $self, $lang, $session ) = @_;

    my $user = 1;

    if ( defined( $session ) ) {
        $user = $self->{sessions__}{$session}{user};
    }

    if ( open LANG, '<' . $self->get_root_path_( "languages/$lang.msg" ) ) {
        while ( <LANG> ) {
            next if ( /[ \t]*#/ );

            if ( /([^\t ]+)[ \t]+(.+)/ ) {
                my ( $id, $value )  = ( $1, $2 );
                if ( $value =~ /^\"(.+)\"$/ ) {
                    $value = $1;
                }
                my $msg = ($self->user_config_( $user, 'test_language' )) ? $id : $value;
                $msg =~ s/[\r\n]//g;

                $self->{language__}{$id} = $msg;
            }
        }
        close LANG;
    }
}

#----------------------------------------------------------------------------
#
# calculate_today - set the global $self->{today__} variable to the
# current day in seconds
#
#----------------------------------------------------------------------------
sub calculate_today
{
    my ( $self ) = @_;

    $self->{today__} = int( time / $seconds_per_day ) * $seconds_per_day;
}

#----------------------------------------------------------------------------
#
# print_form_fields_ - Returns a form string containing any presently
# defined form fields
#
# $first - 1 if the form field is at the beginning of a query, 0
#     otherwise
# $in_href - 1 if the form field is printing in a href, 0
#     otherwise (eg, for a 302 redirect)
# $include - a list of fields to
#     return
#
#----------------------------------------------------------------------------
sub print_form_fields_
{
    my ($self, $first, $in_href, @include) = @_;

    my $amp;
    if ($in_href) {
        $amp = '&amp;';
    } else {
        $amp = '&';
    }

    my $count = 0;
    my $formstring = '';

    $formstring = "$amp" if (!$first);

    foreach my $field ( @include ) {
        if ($field eq 'session') {
            $formstring .= "$amp" if ($count > 0);
            $count++;
            next;
            }
        unless ( !defined($self->{form_}{$field}) || ( $self->{form_}{$field} eq '' ) ) {
            $formstring .= "$amp" if ($count > 0);
            $formstring .= "$field=". $self->url_encode_($self->{form_}{$field});
            $count++;
        }
    }

    return ($count>0)?$formstring:'';
}

#----------------------------------------------------------------------------
# register_configuration_item__
#
#     $type            The type of item (configuration, security or chain)
#     $name            Unique name for this item
#     $template        The name of the template to load
#     $object          Reference to the object calling this method
#
# This seemingly innocent method disguises a lot.  It is called by
# modules that wish to register that they have specific elements of UI
# that need to be dynamically added to the Configuration and Security
# screens of POPFile.  This is done so that the HTML module does not
# need to know about the modules that are loaded, their individual
# configuration elements or how to do validation
#
# A module calls this method for each separate UI element (normally an
# HTML form that handles a single configuration option stored in a
# template) and passes in four pieces of information:
#
# The type is the position in the UI where the element is to be
# displayed. configuration means on the Configuration screen under
# "Module Options"; security means on the Security page and is used
# exclusively for stealth mode operation right now; chain is also on
# the security page and is used for identifying chain servers (in the
# case of SMTP the chained server and for POP3 the SPA server)
#
# A unique name for this configuration item
#
# The template (this is the name of a template file and must be unique
# for each call to this method)
#
# A reference to itself.
#
# When this module needs to display an element of UI it will call the
# object's configure_item public method passing in the name of the
# element required, a reference to the loaded template and
# configure_item must set whatever variables are required in the
# template.
#
# When the module needs to validate it will call the object's
# validate_item interface passing in the name of the element, a
# reference to the template and a reference to the form hash which has
# been parsed.
#
# Example the module foo has a configuration item called bar which it
# needs a UI for, and so it calls
#
#    register_configuration_item( 'configuration', 'foo', 'foo-bar.thtml',
#        $self )
#
# later it will receive a call to its
#
#    configure_item( 'foo', loaded foo-bar.thtml, language hash )
#
# and needs to fill the template variables.  Then it will receive a
# call to its
#
#    validate_item( 'foo', loaded foo-bar.thtml, language hash, form hash )
#
# and needs to check the form for information from any form it created
# and returned from the call to configure_item and update its own
# state.
#
#----------------------------------------------------------------------------
sub register_configuration_item__
{
   my ( $self, $type, $name, $templ, $object ) = @_;

   $self->{dynamic_ui__}{$type}{$name}{object}   = $object;
   $self->{dynamic_ui__}{$type}{$name}{template} = $templ;
}

#----------------------------------------------------------------------------
#
# mcount__, ecount__ get the total message count, or the total error count
#
#----------------------------------------------------------------------------

sub mcount__
{
    my ( $self, $session ) = @_;

    my $count = 0;

    my @buckets = $self->classifier_()->get_all_buckets( $session );

    foreach my $bucket (@buckets) {
        $count += $self->get_bucket_parameter__( $session, $bucket, 'count' );
    }

    return $count;
}

sub ecount__
{
    my ( $self, $session ) = @_;

    my $count = 0;

    my @buckets = $self->classifier_()->get_all_buckets( $session );

    foreach my $bucket (@buckets) {
        $count += $self->get_bucket_parameter__( $session, $bucket, 'fncount' );
    }

    return $count;
}

#----------------------------------------------------------------------------
#
# get_bucket_parameter__/set_bucket_parameter__
#
# Wrapper for Classifier::Bayes::get_bucket_parameter__ the eliminates
# the need for all our calls to mention $session
#
# See Classifier::Bayes::get_bucket_parameter for parameters and
# return values.
#
# (same thing for set_bucket_parameter__)
#
#----------------------------------------------------------------------------
sub get_bucket_parameter__
{

    # The first parameter is going to be a reference to this class,
    # the second will be the session key, the rest we leave untouched
    # in @_ and pass to the real API

    my $self = shift;

    return $self->classifier_()->get_bucket_parameter( @_ );
}
sub set_bucket_parameter__
{
    my $self = shift;

    return $self->classifier_()->set_bucket_parameter( @_ );
}

# GETTERS/SETTERS

sub language
{
    my ( $self ) = @_;

    return %{$self->{language__}};
}

#----------------------------------------------------------------------------
#
# shutdown_page__
#
#   Determines the text to send in response to a click on the shutdown
#   link.
#
#----------------------------------------------------------------------------
sub shutdown_page__
{
    my ( $self, $session ) = @_;

    # Figure out what style sheet we are using

    my $root = 'skins/' . $self->user_config_( $self->{sessions__}{$session}{user}, 'skin' ) . '/';
    my $css_file = $self->get_root_path_( $root . 'style.css' );
    if ( !( -e $css_file ) ) {
        $root = 'skins/default/';
        $css_file = $self->get_root_path_( $root . 'style.css' );
    }

    # Now load the style sheet

    my $css = '<style type="text/css">';
    open CSS, $css_file;
    while ( <CSS> ) {
        $css .= $_;
    }
    close CSS;
    $css .= ".headShutdown { display: none; } \n</style>";

    # Load the template, set the class of the menu tabs, and send the
    # output to $text

    my $templ = $self->load_template__( 'shutdown-page.thtml','',$session );

    for my $i ( 0..6 ) {
        $templ->param( "Common_Middle_Tab$i" => "menuStandard" );
    }

    my $text = $templ->output();

    # Replace the reference to the favicon, we won't be able to handle
    # that request

    $text =~ s/<link rel="icon" href="favicon\.ico">//;

    # Replace the link to the style sheet with the style sheet itself

    $text =~ s/\Q<link rel="stylesheet" type="text\/css" href="${root}style.css" title="POPFile-Style">\E/$css/;

    # Remove the session key from the menu links:

    $text =~ s/href="(.+?)\?session=.+?"/href="$1"/g;

    return $text;
}

1;
