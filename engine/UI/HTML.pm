# POPFILE LOADABLE MODULE
package UI::HTML;

#----------------------------------------------------------------------------
#
# This package contains an HTML UI for POPFile
#
# Copyright (c) 2001-2003 John Graham-Cumming
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

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;
    my $self = UI::HTTP->new();

    # The classifier (Classifier::Bayes)

    $self->{classifier__}      = 0;

    # Session key to make the UI safer

    $self->{session_key__}     = '';

    # The available skins

    $self->{skins__}           = ();

    # Used to keep the history information around so that we don't have to reglob every time we hit the
    # history page
    #
    # The history hash contains information about ALL the files stored in the history
    # folder (by default messages/) and is updated by the load_history_cache__ method
    #
    # Access to the history cache is formatted $self->{history__}{file}{subkey} where
    # the file is the name of the file that is related to this history entry.
    #
    # The subkeys are
    #
    #   cull            Used internally by load_history_cache__ (see there for details)
    #   from            The address the email was from
    #   short_from      Version of from with max 40 characters
    #   subject         The subject of the email
    #   short_subject   Version of subject with max 40 characters
    #   magnet          If a magnet was used to classify the mail contains the magnet string
    #   bucket          The classification of the mail
    #   reclassified    1 if the mail has already been reclassified
    #
    # The history_keys array stores the list of keys in the history hash and are a
    # (perhaps strict) subset of the keys of $self->{history__} set by calls to
    # sory_filter_history.  history_keys references the elements on history that are
    # in the current filter, sort or search set.
    #
    # If new items have been added to the history the set need_resort__ to 1 to ensure
    # that the next time a history page is being displayed the appropriate sort, search
    # and filter is applied

    $self->{history__}         = {};
    $self->{history_keys__}    = ();
    $self->{need_resort__}     = 0;

    # Hash containing pre-cached messages loaded upon receipt of NEWFL message. Moved to
    # $self->{history_keys__} on each invocation of the history page.
    # Structure is identical to $self->{history_keys__}

    $self->{history_pre_cache__} = {};

    # A hash containing a mapping between alphanumeric identifiers and appropriate strings used
    # for localization.  The string may contain sprintf patterns for use in creating grammatically
    # correct strings, or simply be a string

    $self->{language__}        = {};

    # This is the list of available languages

    $self->{languages__}       = ();

    # The last user to login via a proxy

    $self->{last_login__}      = '';

    # Used to determine whehter the cache needs to be saved

    $self->{save_cache__}      = 0;

    # Stores a Classifier::Bayes session and is set up on the first UI connection

    $self->{api_session__}     = '';

    # Must call bless before attempting to call any methods

    bless $self, $type;

    # This is the HTML module which we know as the HTML module

    $self->name( 'html' );

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the interface
#
# ---------------------------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    $self->config_( 'port', 8080 );

    # Checking for updates if off by default

    $self->config_( 'update_check', 0 );

    # Sending of statistics is off

    $self->config_( 'send_stats', 0 );

    # The size of a history page

    $self->config_( 'page_size', 20 );

    # Only accept connections from the local machine for the UI

    $self->config_( 'local', 1 );

    # Use the default skin

    $self->config_( 'skin', 'default' );

    # Keep the history for two days

    $self->config_( 'history_days', 2 );

    # The last time we checked for an update using the local epoch

    $self->config_( 'last_update_check', 0 );

    # The user interface password

    $self->config_( 'password', md5_hex( '__popfile__' ) );

    # The last time (textual) that the statistics were reset

    my $lt = localtime;
    $self->config_( 'last_reset', $lt );

    # We start by assuming that the user speaks English like the
    # perfidious Anglo-Saxons that we are... :-)

    $self->config_( 'language', 'English' );

    # If this is 1 then when the language is loaded we will use the language string identifier as the
    # string shown in the UI.  This is used to test whether which identifiers are used where.

    $self->config_( 'test_language', 0 );

    # If 1, Messages are saved to an archive when they are removed or expired from the history cache

    $self->config_( 'archive', 0, 1 );

    # The directory where messages will be archived to, in sub-directories for each bucket

    $self->config_( 'archive_dir', 'archive' );

    # This is an advanced setting which will save archived files to a randomly numbered
    # sub-directory, if set to greater than zero, otherwise messages will be saved in the
    # bucket directory
    # 0 <= directory name < archive_classes

    $self->config_( 'archive_classes', 0 );

    # This setting defines what is displayed in the word matrix: 'freq' for frequencies,
    # 'prob' for probabilities, 'score' for logarithmic scores, if blank then the word
    # table is not shown

    $self->config_( 'wordtable_format', '' );

    # Controls whether to cache templates or not

    $self->config_( 'cache_templates', 0 );

    # Load skins

    $self->load_skins__();

    # Load the list of available user interface languages

    $self->load_languages__();

    # Calculate a session key

    $self->change_session_key__();

    # The parent needs a reference to the url handler function

    $self->{url_handler_} = \&url_handler__;

    # Finally register for the messages that we need to receive

    $self->mq_register_( 'NEWFL', $self );
    $self->mq_register_( 'UIREG', $self );
    $self->mq_register_( 'TICKD', $self );
    $self->mq_register_( 'LOGIN', $self );

    $self->calculate_today();

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# start
#
# Called to start the HTML interface running
#
# ---------------------------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    # In pre v0.21.0 POPFile the UI password was stored in plaintext in the configuration
    # data.  Check to see if the password is not a hash and upgrade it automatically here.

    if ( length( $self->config_( 'password' ) ) != 32 ) {
        $self->config_( 'password', md5_hex( '__popfile__' . $self->config_( 'password' ) ) );
    }

    # Ensure that the messages subdirectory exists

    if ( !$self->make_directory__( $self->get_user_path_( $self->global_config_( 'msgdir' ) ) ) ) {
        print STDERR "Failed to create the messages subdirectory\n";
        return 0;
    }

    # Load the current configuration from disk and then load up the
    # appropriate language, note that we always load English first
    # so that any extensions to the user interface that have not yet
    # been translated will still appear

    $self->load_language( 'English' );
    $self->load_language( $self->config_( 'language' ) ) if ( $self->config_( 'language' ) ne 'English' );

    # We need to force a history cache reload, note that this needs
    # to come after loading the language since we might need History_NoFrom
    # or History_NoSubject in while loading the cache

    $self->load_disk_cache__();
    $self->load_history_cache__();

    # Set the classifier option wmformat__ according to our wordtable_format
    # option.

    $self->{classifier__}->wmformat( $self->config_( 'wordtable_format' ) );

    return $self->SUPER::start();
}

# ---------------------------------------------------------------------------------------------
#
# start
#
# Called to stop the HTML interface running
#
# ---------------------------------------------------------------------------------------------
sub stop
{
    my ( $self ) = @_;

    $self->copy_pre_cache__();
    $self->save_disk_cache__();

    if ( $self->{api_session__} ne '' ) {
        $self->{classifier__}->release_session_key( $self->{api_session__} );
    }

    $self->SUPER::stop();
}

# ---------------------------------------------------------------------------------------------
#
# deliver
#
# Called by the message queue to deliver a message
#
# There is no return value from this method
#
# ---------------------------------------------------------------------------------------------
sub deliver
{
    my ( $self, $type, $message, $parameter ) = @_;

    # Handle registration of UI components

    if ( $type eq 'UIREG' ) {
        $message =~ /(.*):(.*):(.*)/;

        $self->register_configuration_item__( $1, $2, $3, $parameter );
    }

    # Get the new file in the history

    if ( $type eq 'NEWFL' ) {
        $self->log_( "Got NEWFL for $message" );
        $self->new_history_file__( $message );
    }

    # If a day has passed then clean up the history

    if ( $type eq 'TICKD' ) {
        $self->remove_mail_files();
    }

    # We keep track of the last username to login to show on the UI

    if ( $type eq 'LOGIN' ) {
        $self->{last_login__} = $message;
    }
}

# ---------------------------------------------------------------------------------------------
#
# url_handler__ - Handle a URL request
#
# $client     The web browser to send the results to
# $url        URL to process
# $command    The HTTP command used (GET or POST)
# $content    Any non-header data in the HTTP command
#
# Checks the session
# key and refuses access unless it matches.  Serves up a small set of specific urls that are
# the main UI pages and then any GIF file in the POPFile directory and CSS files in the skins
# subdirectory
#
# ---------------------------------------------------------------------------------------------
sub url_handler__
{
    my ( $self, $client, $url, $command, $content ) = @_;

    # Check to see if we obtained the session key yet
    if ( $self->{api_session__} eq '' ) {
        $self->{api_session__} = $self->{classifier__}->get_session_key( 'admin', '' );
    }

    # See if there are any form parameters and if there are parse them into the %form hash

    delete $self->{form_};

    # Remove a # element

    $url =~ s/#.*//;

    # If the URL was passed in through a GET then it may contain form arguments
    # separated by & signs, which we parse out into the $self->{form_} where the
    # key is the argument name and the value the argument value, for example if
    # you have foo=bar in the URL then $self->{form_}{foo} is bar.

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

    if ( $url =~ /\/(.+\.gif)/ ) {
        $self->http_file_( $client, $self->get_root_path_( $1 ), 'image/gif' );
        return 1;
    }

    if ( $url =~ /\/(.+\.png)/ ) {
        $self->http_file_( $client, $self->get_root_path_( $1 ), 'image/png' );
        return 1;
    }

    if ( $url =~ /\/(.+\.ico)/ ) {
        $self->http_file_( $client, $self->get_root_path_( $1 ), 'image/x-icon' );
        return 1;
    }

    if ( $url =~ /(skins\/.+\.css)/ ) {
        $self->http_file_( $client, $self->get_root_path_( $1 ), 'text/css' );
        return 1;
    }

    if ( $url =~ /(manual\/.+\.html)/ ) {
        $self->http_file_( $client, $self->get_root_path_( $1 ), 'text/html' );
        return 1;
    }

    # Check the password

    if ( $url eq '/password' )  {
        if ( md5_hex( '__popfile__' . $self->{form_}{password} ) eq $self->config_( 'password' ) )  {
            $self->change_session_key__( $self );
            delete $self->{form_}{password};
            $self->{form_}{session} = $self->{session_key__};
            if ( defined( $self->{form_}{redirect} ) ) {
                $url = $self->{form_}{redirect};
                if ( $url =~ s/\?(.*)// )  {
                    $self->parse_form_( $1 );
                }
            }
        } else {
            $self->password_page( $client, 1, '/' );
            return 1;
        }
    }

    # If there's a password defined then check to see if the user already knows the
    # session key, if they don't then drop to the password screen

    if ( ( (!defined($self->{form_}{session})) || ($self->{form_}{session} eq '' ) || ( $self->{form_}{session} ne $self->{session_key__} ) ) && ( $self->config_( 'password' ) ne md5_hex( '__popfile__' ) ) ) {

        # Since the URL that has caused us to hit the password page might have information stored in the
        # form hash we need to extract it out (except for the session key) and package it up so that
        # the password page can redirect to the right place if the correct password is entered. This
        # is especially important for the XPL functionality.

        my $redirect_url = $url . '?';

        foreach my $k (keys %{$self->{form_}}) {

            # Skip the session key since we are in the process of
            # assigning a new one through the password page

            if ( $k ne 'session' ) {

                # If we are dealing with an array of values (see parse_form_
                # for details) then we need to unpack it into separate entries),

                if ( $k =~ /^(.+)_array$/ ) {
                    my $field = $1;

                    foreach my $v (@{$self->{form_}{$k}}) {
                        $redirect_url .= "$field=$v&"
                    }
                } else {
                    $redirect_url .= "$k=$self->{form_}{$k}&"
                }
            }
        }

        $redirect_url =~ s/&$//;

        $self->password_page( $client, 0, $redirect_url );

        return 1;
    }

    if ( $url eq '/jump_to_message' )  {
        my $found = 0;
        my $file = $self->{form_}{view};

        $self->copy_pre_cache__();

        foreach my $akey ( keys %{ $self->{history__} } ) {
            if ($akey eq $file) {
                $found = 1;
                last;
            }
        }

        # Reset any filters

        $self->{form_}{filter}    = '';
        $self->{form_}{search}    = '';
        $self->{form_}{setsearch} = 1;

        if ( $found ) {
            $self->http_redirect_( $client, "/view?session=$self->{session_key__}&view=$self->{form_}{view}" );
        } else {
            $self->http_redirect_( $client, "/history" );
        }

        return 1;
    }

    if ( $url =~ /(popfile.*\.log)/ ) {
        $self->http_file_( $client, $self->logger()->debug_filename(), 'text/plain' );
        return 1;
    }

    if ( ( defined($self->{form_}{session}) ) && ( $self->{form_}{session} ne $self->{session_key__} ) ) {
        $self->session_page( $client, 0, $url );
        return 1;
    }

    if ( ( $url eq '/' ) || (!defined($self->{form_}{session})) ) {
        delete $self->{form_};
    }

    if ( $url eq '/shutdown' )  {
        $self->http_ok( $client, "POPFile shutdown", -1 );
        return 0;
    }

    # The url table maps URLs that we might receive to pages that we display, the
    # page table maps the pages to the functions that handle them and the related
    # template

    my %page_table = ( 'security'      => [ \&security_page,      'security-page.thtml'      ],       # PROFILE BLOCK START
                       'configuration' => [ \&configuration_page, 'configuration-page.thtml' ],
                       'buckets'       => [ \&corpus_page,        'corpus-page.thtml'        ],
                       'magnets'       => [ \&magnet_page,        'magnet-page.thtml'        ],
                       'advanced'      => [ \&advanced_page,      'advanced-page.thtml'      ],
                       'history'       => [ \&history_page,       'history-page.thtml'       ],
                       'view'          => [ \&view_page,          'view-page.thtml'          ] );     # PROFILE BLOCK STOP

    my %url_table = ( '/security'      => 'security',       # PROFILE BLOCK START
                      '/configuration' => 'configuration',
                      '/buckets'       => 'buckets',
                      '/magnets'       => 'magnets',
                      '/advanced'      => 'advanced',
                      '/view'          => 'view',
                      '/history'       => 'history',
                      '/'              => 'history' );      # PROFILE BLOCK STOP

    # Any of the standard pages can be found in the url_table, the other pages are probably
    # files on disk

    if ( defined($url_table{$url}) )  {
        my ( $method, $template ) = @{$page_table{$url_table{$url}}};

        if ( !defined( $self->{api_session__} ) ) {
            $self->http_error_( $client, 500 );
            return;
        }

        &{$method}( $self, $client, $self->load_template__( $template ) );
        return 1;
    }

    $self->http_error_( $client, 404 );
    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# http_ok - Output a standard HTTP 200 message with a body of data from a template
#
# $client    The web browser to send result to
# $templ     The template for the page to return
# $selected  Which tab is to be selected
#
# ---------------------------------------------------------------------------------------------
sub http_ok
{
    my ( $self, $client, $templ, $selected ) = @_;

    $selected = -1 if ( !defined( $selected ) );

    my @tab = ( 'menuStandard', 'menuStandard', 'menuStandard', 'menuStandard', 'menuStandard', 'menuStandard' );
    $tab[$selected] = 'menuSelected' if ( ( $selected <= $#tab ) && ( $selected >= 0 ) );

    for my $i (0..$#tab) {
        $templ->param( "Common_Middle_Tab$i" => $tab[$i] );
    }

    my $update_check = '';

    # Check to see if we've checked for updates today.  If we have not then insert a reference to an image
    # that is generated through a CGI on UseTheSource.  Also send stats to the same site if that is allowed

    if ( $self->{today__} ne $self->config_( 'last_update_check' ) ) {
        $self->calculate_today();

        if ( $self->config_( 'update_check' ) ) {
            my ( $major_version, $minor_version, $build_version ) = $self->version() =~ /^v([^.]*)\.([^.]*)\.(.*)$/;
            $templ->param( 'Common_Middle_If_UpdateCheck' => 1 );
            $templ->param( 'Common_Middle_Major_Version' => $major_version );
            $templ->param( 'Common_Middle_Minor_Version' => $minor_version );
            $templ->param( 'Common_Middle_Build_Version' => $build_version );
        }

        if ( $self->config_( 'send_stats' ) ) {
            $templ->param( 'Common_Middle_If_SendStats' => 1 );
            my @buckets = $self->{classifier__}->get_buckets( $self->{api_session__} );
            my $bc      = $#buckets + 1;
            $templ->param( 'Common_Middle_Buckets'  => $bc );
            $templ->param( 'Common_Middle_Messages' => $self->mcount__() );
            $templ->param( 'Common_Middle_Errors'   => $self->ecount__() );
        }

        $self->config_( 'last_update_check', $self->{today__}, 1 );
    }

    # Build an HTTP header for standard HTML

    my $http_header = "HTTP/1.1 200 OK\r\n";
    $http_header .= "Connection: close\r\n";
    $http_header .= "Pragma: no-cache\r\n";
    $http_header .= "Expires: 0\r\n";
    $http_header .= "Cache-Control: no-cache\r\n";
    $http_header .= "Content-Type: text/html";
    $http_header .= "; charset=$self->{language__}{LanguageCharset}\r\n";
    $http_header .= "Content-Length: ";

    my $text = $templ->output;

    $http_header .= length($text);
    $http_header .= "$eol$eol";

    print $client $http_header . $text;
}

# ---------------------------------------------------------------------------------------------
#
# configuration_page - get the configuration options
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub configuration_page
{
    my ( $self, $client, $templ ) = @_;

    $self->config_( 'skin', $self->{form_}{skin} )      if ( defined($self->{form_}{skin}) );
    $self->global_config_( 'debug', $self->{form_}{debug}-1 )   if ( ( defined($self->{form_}{debug}) ) && ( ( $self->{form_}{debug} >= 1 ) && ( $self->{form_}{debug} <= 4 ) ) );

    if ( defined($self->{form_}{language}) ) {
        if ( $self->config_( 'language' ) ne $self->{form_}{language} ) {
            $self->config_( 'language', $self->{form_}{language} );
            $self->load_language( $self->config_( 'language' ) );
        }
    }

    # Load all of the templates that are needed for the dynamic parts of
    # the configuration page, and for each one call its validation interface
    # so that any error messages or informational messages are fixed up
    # first

    my %dynamic_templates;

    for my $name (keys %{$self->{dynamic_ui__}{configuration}}) {
        $dynamic_templates{$name} = $self->load_template__( $self->{dynamic_ui__}{configuration}{$name}{template} );
        $self->{dynamic_ui__}{configuration}{$name}{object}->validate_item( $name,
                                                                            $dynamic_templates{$name},
                                                                             \%{$self->{language__}},
                                                                             \%{$self->{form_}} );
    }

    if ( defined($self->{form_}{ui_port}) ) {
        if ( ( $self->{form_}{ui_port} >= 1 ) && ( $self->{form_}{ui_port} < 65536 ) ) {
            $self->config_( 'port', $self->{form_}{ui_port} );
        } else {
            $templ->param( 'Configuration_If_UI_Port_Error' => 1 );
            delete $self->{form_}{ui_port};
        }
    }

    $templ->param( 'Configuration_UI_Port_Updated' => sprintf( $self->{language__}{Configuration_UIUpdate}, $self->config_( 'port' ) ) ) if ( defined($self->{form_}{ui_port} ) );
    $templ->param( 'Configuration_UI_Port' => $self->config_( 'port' ) );

    if ( defined($self->{form_}{page_size}) ) {
        if ( ( $self->{form_}{page_size} >= 1 ) && ( $self->{form_}{page_size} <= 1000 ) ) {
            $self->config_( 'page_size', $self->{form_}{page_size} );
        } else {
            $templ->param( 'Configuration_If_Page_Size_Error' => 1 );
            delete $self->{form_}{page_size};
        }
    }

    $templ->param( 'Configuration_Page_Size_Updated' => sprintf( $self->{language__}{Configuration_HistoryUpdate}, $self->config_( 'page_size' ) ) ) if ( defined($self->{form_}{page_size} ) );
    $templ->param( 'Configuration_Page_Size' => $self->config_( 'page_size' ) );

    if ( defined($self->{form_}{history_days}) ) {
        if ( ( $self->{form_}{history_days} >= 1 ) && ( $self->{form_}{history_days} <= 366 ) ) {
            $self->config_( 'history_days', $self->{form_}{history_days} );
        } else {
            $templ->param( 'Configuration_If_History_Days_Error' => 1 );
            delete $self->{form_}{history_days};
        }
    }

    $templ->param( 'Configuration_History_Days_Updated' => sprintf( $self->{language__}{Configuration_DaysUpdate}, $self->config_( 'history_days' ) ) ) if ( defined($self->{form_}{history_days} ) );
    $templ->param( 'Configuration_History_Days' => $self->config_( 'history_days' ) );

    if ( defined($self->{form_}{timeout}) ) {
        if ( ( $self->{form_}{timeout} >= 10 ) && ( $self->{form_}{timeout} <= 300 ) ) {
            $self->global_config_( 'timeout', $self->{form_}{timeout} );
        } else {
            $templ->param( 'Configuration_If_TCP_Timeout_Error' => 1 );
            delete $self->{form_}{timeout};
        }
    }

    $templ->param( 'Configuration_TCP_Timeout_Updated' => sprintf( $self->{language__}{Configuration_TCPTimeoutUpdate}, $self->global_config_( 'timeout' ) ) ) if ( defined($self->{form_}{timeout} ) );
    $templ->param( 'Configuration_TCP_Timeout' => $self->global_config_( 'timeout' ) );

    my ( @general_skins, @small_skins, @tiny_skins );
    for my $i (0..$#{$self->{skins__}}) {
        my %row_data;
        my $type = 'General';
        my $list = \@general_skins;
        my $name = $self->{skins__}[$i];
        $name =~ /\/([^\/]+)\/$/;
        $name = $1;
        my $selected = ( $name eq $self->config_( 'skin' ) )?'selected':'';

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
        $row_data{Configuration_Selected_Language} = ( $lang eq $self->config_( 'language' ) )?'selected':'';
        push ( @language_loop, \%row_data );
    }
    $templ->param( 'Configuration_Loop_Languages' => \@language_loop );

    # Insert all the items that are dynamically created from the modules that are loaded

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
        $self->{dynamic_ui__}{configuration}{$name}{object}->configure_item( $name,                       # PROFILE BLOCK START
                                                                             $dynamic_templates{$name} ); # PROFILE BLOCK STOP
        $configuration_html .= $dynamic_templates{$name}->output;
    }

    $templ->param( 'Configuration_Dynamic' => $configuration_html );
    $templ->param( 'Configuration_Debug_' . ( $self->global_config_( 'debug' ) + 1 ) . '_Selected' => 'selected' );

    if ( $self->global_config_( 'debug' ) & 1 ) {
        $templ->param( 'Configuration_If_Show_Log' => 1 );
    }

    $self->http_ok( $client, $templ, 3 );
}

# ---------------------------------------------------------------------------------------------
#
# security_page - get the security configuration page
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub security_page
{
    my ( $self, $client, $templ ) = @_;

    my $server_error = '';
    my $port_error   = '';

    if ( ( defined($self->{form_}{password}) ) &&
         ( $self->{form_}{password} ne $self->config_( 'password' ) ) ) {
        $self->config_( 'password', md5_hex( '__popfile__' . $self->{form_}{password} ) )
    }
    $self->config_( 'local', $self->{form_}{localui}-1 )      if ( defined($self->{form_}{localui}) );
    $self->config_( 'update_check', $self->{form_}{update_check}-1 ) if ( defined($self->{form_}{update_check}) );
    $self->config_( 'send_stats', $self->{form_}{send_stats}-1 )   if ( defined($self->{form_}{send_stats}) );

    $templ->param( 'Security_If_Local' => ( $self->config_( 'local' ) == 1 ) );
    $templ->param( 'Security_Password' => ( $self->config_( 'password' ) eq md5_hex( '__popfile__' ) )?'':$self->config_( 'password' ) );
    $templ->param( 'Security_If_Password_Updated' => ( defined($self->{form_}{password} ) ) );
    $templ->param( 'Security_If_Update_Check' => ( $self->config_( 'update_check' ) == 1 ) );
    $templ->param( 'Security_If_Send_Stats' => ( $self->config_( 'send_stats' ) == 1 ) );

    my %security_templates;

    for my $name (keys %{$self->{dynamic_ui__}{security}}) {
        $security_templates{$name} = $self->load_template__( $self->{dynamic_ui__}{security}{$name}{template} );
        $self->{dynamic_ui__}{security}{$name}{object}->validate_item( $name,
                                                                       $security_templates{$name},
                                                                       \%{$self->{language__}},
                                                                       \%{$self->{form_}} );
    }

    my %chain_templates;

    for my $name (keys %{$self->{dynamic_ui__}{chain}}) {
        $chain_templates{$name} = $self->load_template__( $self->{dynamic_ui__}{chain}{$name}{template} );
        $self->{dynamic_ui__}{chain}{$name}{object}->validate_item( $name,
                                                                    $chain_templates{$name},
                                                                    \%{$self->{language__}},
                                                                    \%{$self->{form_}} );
    }

    my $security_html = '';

    for my $name (sort keys %{$self->{dynamic_ui__}{security}}) {
        $self->{dynamic_ui__}{security}{$name}{object}->configure_item( $name,                        # PROFILE BLOCK START
                                                                        $security_templates{$name} ); # PROFILE BLOCK STOP
        $security_html .= $security_templates{$name}->output;
    }

    my $chain_html = '';

    for my $name (sort keys %{$self->{dynamic_ui__}{chain}}) {
        $self->{dynamic_ui__}{chain}{$name}{object}->configure_item( $name,                     # PROFILE BLOCK START
                                                                     $chain_templates{$name} ); # PROFILE BLOCK STOP
        $chain_html .= $chain_templates{$name}->output;
    }

    $templ->param( 'Security_Dynamic_Security' => $security_html );
    $templ->param( 'Security_Dynamic_Chain'    => $chain_html    );

    $self->http_ok( $client,$templ, 4 );
}

# ---------------------------------------------------------------------------------------------
#
# pretty_number - format a number with ,s every 1000
#
# $number       The number to format
#
# ---------------------------------------------------------------------------------------------
sub pretty_number
{
    my ( $self, $number ) = @_;

    my $c = $self->{language__}{Locale_Thousands};
    $c =~ s/"//g;

    $number = reverse $number;
    $number =~ s/(\d{3})/$1$c/g;
    $number = reverse $number;
    $c =~ s/\./\\./g;
    $number =~ s/^$c(.*)/$1/;

    return $number;
}

# ---------------------------------------------------------------------------------------------
#
# advanced_page - very advanced configuration options
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub advanced_page
{
    my ( $self, $client, $templ ) = @_;

    # Handle updating the parameter table

    if ( defined( $self->{form_}{update_params} ) ) {
        foreach my $param (sort keys %{$self->{form_}}) {
            if ( $param =~ /parameter_(.*)/ ) {
                $self->{configuration__}->parameter( $1, $self->{form_}{$param} );
            }
        }

        $self->{configuration__}->save_configuration();
    }

    if ( defined($self->{form_}{newword}) ) {
        my $result = $self->{classifier__}->add_stopword( $self->{api_session__}, $self->{form_}{newword} );
        if ( $result == 0 ) {
            $templ->param( 'Advanced_If_Add_Message' ) = 1;
        }
    }

    if ( defined($self->{form_}{word}) ) {
        my $result = $self->{classifier__}->remove_stopword( $self->{api_session__}, $self->{form_}{word} );
        if ( $result == 0 ) {
            $templ->param( 'Advanced_If_Delete_Message' ) = 1;
        }
    }

    # the word census
    my $last = '';
    my $need_comma = 0;
    my $groupCounter = 0;
    my $groupSize = 5;
    my @words = $self->{classifier__}->get_stopword_list( $self->{api_session__} );
    my $commas;

    my @word_loop;
    my $c;
    @words = sort @words;
    push ( @words, ' ' );
    for my $word (@words) {
        if ( $self->config_( 'language' ) =~ /^Korean$/ ) {
            no locale;
            $word =~ /^(.)/;
            $c = $1;
        } else {
                if ( $self->config_( 'language' ) =~ /^Nihongo$/ ) {
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

    my $last_module = '';

    my @param_loop;
    foreach my $param ($self->{configuration__}->configuration_parameters()) {
        my $value = $self->{configuration__}->parameter( $param );
        $param =~ /^([^_]+)_/;

        my %row_data;
        $row_data{Advanced_Parameter} = $param;
        $row_data{Advanced_Value}     = $value;

        if ( ( $last_module ne '' ) && ( $last_module ne $1 ) ) {
            $row_data{Advanced_If_New_Module} = 1;
        } else {
            $row_data{Advanced_If_New_Module} = 0;
        }

        $last_module = $1;

        push ( @param_loop, \%row_data);
    }

    $templ->param( 'Advanced_Loop_Parameter' => \@param_loop );

    $self->http_ok( $client, $templ, 5 );
}

sub max
{
    my ( $a, $b ) = @_;

    return ( $a > $b )?$a:$b;
}

# ---------------------------------------------------------------------------------------------
#
# magnet_page - the list of bucket magnets
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub magnet_page
{
    my ( $self, $client, $templ ) = @_;

    my $magnet_message = '';

    if ( defined( $self->{form_}{delete} ) ) {
        for my $i ( 1 .. $self->{form_}{count} ) {
            if ( defined( $self->{form_}{"remove$i"} ) && ( $self->{form_}{"remove$i"} ) ) {
                my $mtype   = $self->{form_}{"type$i"};
                my $mtext   = $self->{form_}{"text$i"};
                my $mbucket = $self->{form_}{"bucket$i"};

                $self->{classifier__}->delete_magnet( $self->{api_session__}, $mbucket, $mtype, $mtext );
            }
        }
    }

    if ( defined( $self->{form_}{count} ) && ( defined( $self->{form_}{update} ) || defined( $self->{form_}{create} ) ) ) {
        for my $i ( 0 .. $self->{form_}{count} ) {
            my $mtype   = $self->{form_}{"type$i"};
            my $mtext   = $self->{form_}{"text$i"};
            my $mbucket = $self->{form_}{"bucket$i"};

            if ( defined( $self->{form_}{update} ) ) {
                my $otype   = $self->{form_}{"otype$i"};
                my $otext   = $self->{form_}{"otext$i"};
                my $obucket = $self->{form_}{"obucket$i"};

                if ( defined( $otype ) ) {
                    $self->{classifier__}->delete_magnet( $self->{api_session__}, $obucket, $otype, $otext );
                }
            }

            if ( ( defined($mbucket) ) && ( $mbucket ne '' ) && ( $mtext ne '' ) ) {

                # Support for feature request 77646 - import function.  goal is a method of creating multiple
                # magnets all with the same target bucket quickly.
                #
                # If we have multiple lines in $mtext, each line will actually be used to create a new magnet
                # all with the same target.  We loop through all of the requested magnets, check to make sure
                # they are all valid (not already existing, etc...) and then loop through them again to create 
                # them.  this way, if even one isn't valid, none will be created.
                #
                # We also get rid of an \r's that may have been passed in.  We also and ignore lines containing, 
                # only white space and if a line is repeated we add just one bucket for it.

                $mtext =~ s/\r\n/\n/g;

                my @all_mtexts = split(/\n/,$mtext);
                my %mtext_hash;
                @mtext_hash{@all_mtexts} = ();
                my @mtexts = keys %mtext_hash;
                my $found = 0;

                foreach my $current_mtext (@mtexts) {
                    for my $bucket ($self->{classifier__}->get_buckets_with_magnets( $self->{api_session__} )) {
                        my %magnets;
                        @magnets{ $self->{classifier__}->get_magnets( $self->{api_session__}, $bucket, $mtype )} = ();

                        if ( exists( $magnets{$current_mtext} ) ) {
                            $found  = 1;
                            $magnet_message .= sprintf( $self->{language__}{Magnet_Error1}, "$mtype: $current_mtext", $bucket );
                            last;
                        }
		    }

                    if ( $found == 0 )  {
                        for my $bucket ($self->{classifier__}->get_buckets_with_magnets( $self->{api_session__} )) {
                            my %magnets;
                            @magnets{ $self->{classifier__}->get_magnets( $self->{api_session__}, $bucket, $mtype )} = ();

                            for my $from (keys %magnets)  {
                                if ( ( $mtext =~ /\Q$from\E/ ) || ( $from =~ /\Q$mtext\E/ ) )  {
                                    $found = 1;
                                    $magnet_message .= sprintf( $self->{language__}{Magnet_Error2}, "$mtype: $current_mtext", "$mtype: $from", $bucket );
                                    last;
                                }
                            }
                        }
                    }
		}

                if ( $found == 0 ) {
                    foreach my $current_mtext (@mtexts) {

                    # Skip mangnet definition if it consists only of white spaces

                    if ( $current_mtext =~ /^[ \t]*$/ ) {
                        next;
                    }

                    # It is possible to type leading or trailing white space in a magnet definition
                    # which can later cause mysterious failures because the whitespace is eaten by
                    # the browser when the magnet is displayed but is matched in the regular expression
                    # that does the magnet matching and will cause failures... so strip off the whitespace

                    $current_mtext =~ s/^[ \t]+//;
                    $current_mtext =~ s/[ \t]+$//;

                    $self->{classifier__}->create_magnet( $self->{api_session__}, $mbucket, $mtype, $current_mtext );
                    if ( !defined( $self->{form_}{update} ) ) {
                        $magnet_message .= sprintf( $self->{language__}{Magnet_Error3}, "$mtype: $current_mtext", $mbucket );
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
    my $magnet_count = $self->{classifier__}->magnet_count( $self->{api_session__} );
    my $navigator = '';

    if ( !defined( $start_magnet ) ) {
        $start_magnet = 0;
    }

    if ( !defined( $stop_magnet ) ) {
        $stop_magnet = $start_magnet + $self->config_( 'page_size' ) - 1;
    }

    if ( $self->config_( 'page_size' ) < $magnet_count ) {
        $self->set_magnet_navigator__( $templ, $start_magnet, $stop_magnet, $magnet_count );
    }

    $templ->param( 'Magnet_Start_Magnet' => $start_magnet );

    my %magnet_types = $self->{classifier__}->get_magnet_types( $self->{api_session__} );
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

    my @buckets = $self->{classifier__}->get_buckets( $self->{api_session__} );
    my @magnet_bucket_loop;
    foreach my $bucket (@buckets) {
        my %row_data;
        my $bcolor = $self->{classifier__}->get_bucket_color( $self->{api_session__}, $bucket );
        $row_data{Magnet_Bucket} = $bucket;
        $row_data{Magnet_Bucket_Color} = $bcolor;
        push ( @magnet_bucket_loop, \%row_data );
    }
    $templ->param( 'Magnet_Loop_Buckets' => \@magnet_bucket_loop );

    # magnet listing

    my @magnet_loop;
    for my $bucket ($self->{classifier__}->get_buckets_with_magnets( $self->{api_session__} )) {
        for my $type ($self->{classifier__}->get_magnet_types_in_bucket( $self->{api_session__}, $bucket )) {
            for my $magnet ($self->{classifier__}->get_magnets( $self->{api_session__}, $bucket, $type ))  {
                my %row_data;
                $count += 1;
                if ( ( $count < $start_magnet ) || ( $count > $stop_magnet ) ) {
                    next;
                }

                $i += 1;

                # to validate, must replace & with &amp;
                # stan todo note: come up with a smarter regex, this one's a bludgeon
                # another todo: Move this stuff into a function to make text
                # safe for inclusion in a form field

                my $validatingMagnet = $magnet;
                $validatingMagnet =~ s/&/&amp;/g;
                $validatingMagnet =~ s/</&lt;/g;
                $validatingMagnet =~ s/>/&gt;/g;

                # escape quotation characters to avoid orphan data within tags
                # todo: function to make arbitrary data safe for inclusion within
                # a html tag attribute (inside double-quotes)

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
                my @buckets = $self->{classifier__}->get_buckets( $self->{api_session__} );
                foreach my $mbucket (@buckets) {
                    my %bucket_data;
                    my $selected = ( $bucket eq $mbucket )?"selected":"";
                    my $bcolor   = $self->{classifier__}->get_bucket_color( $self->{api_session__}, $mbucket );
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

    $self->http_ok( $client, $templ, 4 );
}

# ---------------------------------------------------------------------------------------------
#
# bucket_page - information about a specific bucket
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub bucket_page
{
    my ( $self, $client, $templ ) = @_;

    $templ = $self->load_template__( 'bucket-page.thtml' );

    $templ->param( 'Bucket_Main_Title' => sprintf( $self->{language__}{SingleBucket_Title}, $self->{form_}{showbucket} ) );

    my $bucket_count = $self->{classifier__}->get_bucket_word_count( $self->{api_session__}, $self->{form_}{showbucket} );
    $templ->param( 'Bucket_Word_Count'   => $self->pretty_number( $bucket_count ) );
    $templ->param( 'Bucket_Unique_Count' => sprintf( $self->{language__}{SingleBucket_Unique}, $self->pretty_number( $self->{classifier__}->get_bucket_unique_count( $self->{api_session__}, $self->{form_}{showbucket} ) ) ) );
    $templ->param( 'Bucket_Total_Word_Count' => $self->pretty_number( $self->{classifier__}->get_word_count( $self->{api_session__} ) ) );

    my $percent = '0%';
    if ( $self->{classifier__}->get_word_count( $self->{api_session__} ) > 0 )  {
        $percent = sprintf( '%6.2f%%', int( 10000 * $bucket_count / $self->{classifier__}->get_word_count( $self->{api_session__} ) ) / 100 );
    }
    $templ->param( 'Bucket_Percentage' => $percent );

    if ( $self->{classifier__}->get_bucket_word_count( $self->{api_session__}, $self->{form_}{showbucket} ) > 0 ) {
        $templ->param( 'Bucket_If_Has_Words' => 1 );
        my @letter_data;
        for my $i ($self->{classifier__}->get_bucket_word_prefixes( $self->{api_session__}, $self->{form_}{showbucket} )) {
            my %row_data;
            $row_data{Bucket_Letter} = $i;
            $row_data{Bucket_Bucket} = $self->{form_}{showbucket};
            $row_data{Session_Key}   = $self->{session_key__};
            if ( defined( $self->{form_}{showletter} ) && ( $i eq $self->{form_}{showletter} ) ) {
                $row_data{Bucket_If_Show_Letter} = 1;
                $row_data{Bucket_Word_Table_Title} = sprintf( $self->{language__}{SingleBucket_WordTable}, $self->{form_}{showbucket} );
                my %temp;

                for my $j ( $self->{classifier__}->get_bucket_word_list( $self->{api_session__}, $self->{form_}{showbucket}, $i ) ) {
                    $temp{$j} = $self->{classifier__}->get_count_for_word( $self->{api_session__}, $self->{form_}{showbucket}, $j );
                }

                my $count = 0;
                my @word_data;
                my %word_row;
                for my $word (sort { $temp{$b} <=> $temp{$a} } keys %temp) {
                    if ( ( $count % 6 ) == 0 ) {
                        my %temp_row = %word_row;
                        push ( @word_data, \%temp_row );
                        $count = 0;
		    }
                    $word_row{"Bucket_Word_$count"} = $word;
                    $word_row{"Bucket_Word_Count_$count"} = $temp{$word};
                    $word_row{"Session_Key"} = $self->{session_key__};
                    $count++;
                }
                if ( $count != 0 ) {
		    for my $i ( $count..5) {
                        $word_row{"Bucket_Word_$i"} = '';
                        $word_row{"Bucket_Word_Count_$i"} = '';
		    }
                    push ( @word_data, \%word_row );
		}
                $row_data{Bucket_Loop_Loop_Word_Row} = \@word_data;

            } else {
                $row_data{Bucket_If_Show_Letter} = 0;
            }
            push ( @letter_data, \%row_data );
       }

       $templ->param( 'Bucket_Loop_Letters' => \@letter_data );
    }

    $self->http_ok( $client, $templ, 1 );
}

# ---------------------------------------------------------------------------------------------
#
# bar_chart_100 - Output an HTML bar chart
#
# %values       A hash of bucket names with values in series 0, 1, 2, ...
#
# ---------------------------------------------------------------------------------------------
sub bar_chart_100
{
    my ( $self, %values ) = @_;
    my $body = '';
    my $total_count = 0;
    my @xaxis = sort {
        if ( $self->{classifier__}->is_pseudo_bucket( $self->{api_session__}, $a ) == $self->{classifier__}->is_pseudo_bucket( $self->{api_session__}, $b ) ) {
            $a cmp $b;
        } else {
            $self->{classifier__}->is_pseudo_bucket( $self->{api_session__}, $a ) <=> $self->{classifier__}->is_pseudo_bucket( $self->{api_session__}, $b );
        }
    } keys %values;

    return '' if ( $#xaxis < 0 );

    my @series = sort keys %{$values{$xaxis[0]}};

    for my $bucket (@xaxis)  {
        $total_count += $values{$bucket}{0};
    }

    for my $bucket (@xaxis)  {
        $body .= "<tr>\n<td align=\"left\"><font color=\"". $self->{classifier__}->get_bucket_color( $self->{api_session__}, $bucket ) . "\">$bucket</font></td>\n<td>&nbsp;</td>";

        for my $s (@series) {
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
                 ( $self->{classifier__}->is_pseudo_bucket( $self->{api_session__}, $bucket ) ) ) {
                $count = '';
                $percent = '';
            }

            $body .= "\n<td align=\"right\">$count$percent</td>";
        }
        $body .= "\n</tr>\n";
    }

    my $colspan = 3 + $#series;

    $body .= "<tr>\n<td colspan=\"$colspan\">&nbsp;</td>\n</tr>\n<tr>\n<td colspan=\"$colspan\">\n";

    if ( $total_count != 0 ) {
        $body .= "<table class=\"barChart\" width=\"100%\" summary=\"$self->{language__}{Bucket_BarChartSummary}\">\n<tr>\n";
        foreach my $bucket (@xaxis) {
            my $percent = int( $values{$bucket}{0} * 10000 / $total_count ) / 100;
            if ( $percent != 0 )  {
                $body .= "<td bgcolor=\"" . $self->{classifier__}->get_bucket_color( $self->{api_session__}, $bucket ) . "\" title=\"$bucket ($percent%)\" width=\"";
                $body .= (int($percent)<1)?1:int($percent);
                $body .= "%\"><img src=\"pix.gif\" alt=\"\" height=\"20\" width=\"1\" /></td>\n";
            }
        }
        $body .= "</tr>\n</table>";
    }

    $body .= "</td>\n</tr>\n";

    if ( $total_count != 0 )  {
        $body .= "<tr>\n<td colspan=\"$colspan\" align=\"right\"><span class=\"graphFont\">100%</span></td>\n</tr>\n";
    }

    return $body;
}

# ---------------------------------------------------------------------------------------------
#
# corpus_page - the corpus management page
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub corpus_page
{
    my ( $self, $client, $templ ) = @_;

    if ( defined( $self->{form_}{clearbucket} ) ) {
        $self->{classifier__}->clear_bucket( $self->{api_session__}, $self->{form_}{showbucket} );
    }

    if ( defined($self->{form_}{reset_stats}) ) {
        foreach my $bucket ($self->{classifier__}->get_all_buckets( $self->{api_session__} )) {
            $self->set_bucket_parameter__( $bucket, 'count', 0 );
            $self->set_bucket_parameter__( $bucket, 'fpcount', 0 );
            $self->set_bucket_parameter__( $bucket, 'fncount', 0 );
        }
        my $lasttime = localtime;
        $self->config_( 'last_reset', $lasttime );
        $self->{configuration__}->save_configuration();
    }

    if ( defined($self->{form_}{showbucket}) )  {
        $self->bucket_page( $client, $templ );
        return;
    }

    if ( ( defined($self->{form_}{color}) ) && ( defined($self->{form_}{bucket}) ) ) {
        $self->{classifier__}->set_bucket_color( $self->{api_session__}, $self->{form_}{bucket}, $self->{form_}{color});
    }

    if ( ( defined($self->{form_}{bucket}) ) && ( defined($self->{form_}{subject}) ) && ( $self->{form_}{subject} > 0 ) ) {
        $self->set_bucket_parameter__( $self->{form_}{bucket}, 'subject', $self->{form_}{subject} - 1 );
    }

    if ( ( defined($self->{form_}{bucket}) ) && ( defined($self->{form_}{xtc}) ) && ( $self->{form_}{xtc} > 0 ) ) {
        $self->set_bucket_parameter__( $self->{form_}{bucket}, 'xtc', $self->{form_}{xtc} - 1 );
    }

    if ( ( defined($self->{form_}{bucket}) ) && ( defined($self->{form_}{xpl}) ) && ( $self->{form_}{xpl} > 0 ) ) {
        $self->set_bucket_parameter__( $self->{form_}{bucket}, 'xpl', $self->{form_}{xpl} - 1 );
    }

    if ( ( defined($self->{form_}{bucket}) ) &&  ( defined($self->{form_}{quarantine}) ) && ( $self->{form_}{quarantine} > 0 ) ) {
        $self->set_bucket_parameter__( $self->{form_}{bucket}, 'quarantine', $self->{form_}{quarantine} - 1 );
    }

    # This regular expression defines the characters that are NOT valid
    # within a bucket name

    my $invalid_bucket_chars = '[^[:lower:]\-_0-9]';

    if ( ( defined($self->{form_}{cname}) ) && ( $self->{form_}{cname} ne '' ) ) {
        if ( $self->{form_}{cname} =~ /$invalid_bucket_chars/ )  {
            $templ->param( 'Corpus_If_Create_Error' => 1 );
        } else {
            if ( $self->{classifier__}->is_bucket( $self->{api_session__}, $self->{form_}{cname} ) ||
                $self->{classifier__}->is_pseudo_bucket( $self->{api_session__}, $self->{form_}{cname} ) ) {
                $templ->param( 'Corpus_If_Create_Message' => 1 );
                $templ->param( 'Corpus_Create_Message' => sprintf( $self->{language__}{Bucket_Error2}, $self->{form_}{cname} ) );
            } else {
                $self->{classifier__}->create_bucket( $self->{api_session__}, $self->{form_}{cname} );
                $templ->param( 'Corpus_If_Create_Message' => 1 );
                $templ->param( 'Corpus_Create_Message' => sprintf( $self->{language__}{Bucket_Error3}, $self->{form_}{cname} ) );
            }
       }
    }

    if ( ( defined($self->{form_}{delete}) ) && ( $self->{form_}{name} ne '' ) ) {
        $self->{form_}{name} = lc($self->{form_}{name});
        $self->{classifier__}->delete_bucket( $self->{api_session__}, $self->{form_}{name} );
        $templ->param( 'Corpus_If_Delete_Message' => 1 );
        $templ->param( 'Corpus_Delete_Message' => sprintf( $self->{language__}{Bucket_Error6}, $self->{form_}{name} ) );
    }

    if ( ( defined($self->{form_}{newname}) ) && ( $self->{form_}{oname} ne '' ) ) {
        if ( $self->{form_}{newname} =~ /$invalid_bucket_chars/ )  {
            $templ->param( 'Corpus_If_Rename_Error' => 1 );
        } else {
            $self->{form_}{oname} = lc($self->{form_}{oname});
            $self->{form_}{newname} = lc($self->{form_}{newname});
            if ( $self->{classifier__}->rename_bucket( $self->{api_session__}, $self->{form_}{oname}, $self->{form_}{newname} ) == 1 ) {
                $templ->param( 'Corpus_If_Rename_Message' => 1 );
                $templ->param( 'Corpus_Rename_Message' => sprintf( $self->{language__}{Bucket_Error5}, $self->{form_}{oname}, $self->{form_}{newname} ) );
            } else {
                $templ->param( 'Corpus_If_Rename_Message' => 1 );
                $templ->param( 'Corpus_Rename_Message' => 'Internal error: rename failed' );
            }
        }
    }

    my @buckets = $self->{classifier__}->get_buckets( $self->{api_session__} );

    my $total_count = 0;
    my @delete_data;
    my @rename_data;
    foreach my $bucket (@buckets) {
        my %delete_row;
        my %rename_row;
        $delete_row{Corpus_Delete_Bucket} = $bucket;
        $delete_row{Corpus_Delete_Bucket_Color} = $self->get_bucket_parameter__( $bucket, 'color' );
        $rename_row{Corpus_Rename_Bucket} = $bucket;
        $rename_row{Corpus_Rename_Bucket_Color} = $self->get_bucket_parameter__( $bucket, 'color' );
        $total_count += $self->get_bucket_parameter__( $bucket, 'count' );
        push ( @delete_data, \%delete_row );
        push ( @rename_data, \%rename_row );
    }
    $templ->param( 'Corpus_Loop_Delete_Buckets' => \@delete_data );
    $templ->param( 'Corpus_Loop_Rename_Buckets' => \@rename_data );

    my @pseudos = $self->{classifier__}->get_pseudo_buckets( $self->{api_session__} );
    push @buckets, @pseudos;

    my @corpus_data;
    foreach my $bucket (@buckets) {
        my %row_data;
        $row_data{Corpus_Bucket}        = $bucket;
        $row_data{Corpus_Bucket_Color}  = $self->get_bucket_parameter__( $bucket, 'color' );
        $row_data{Corpus_Bucket_Unique} = $self->pretty_number(  $self->{classifier__}->get_bucket_unique_count( $self->{api_session__}, $bucket ) );
        $row_data{Corpus_If_Bucket_Not_Pseudo} = !$self->{classifier__}->is_pseudo_bucket( $self->{api_session__}, $bucket );
        $row_data{Corpus_If_Subject}    = !$self->get_bucket_parameter__( $bucket, 'subject' );
        $row_data{Corpus_If_XTC}        = !$self->get_bucket_parameter__( $bucket, 'xtc' );
        $row_data{Corpus_If_XPL}        = !$self->get_bucket_parameter__( $bucket, 'xpl' );
        $row_data{Corpus_If_Quarantine} = !$self->get_bucket_parameter__( $bucket, 'quarantine' );
        $row_data{Localize_On}          = $self->{language__}{On};
        $row_data{Localize_Off}         = $self->{language__}{Off};
        $row_data{Localize_TurnOn}      = $self->{language__}{TurnOn};
        $row_data{Localize_TurnOff}     = $self->{language__}{TurnOff};
        my @color_data;
        foreach my $color (@{$self->{classifier__}->{possible_colors__}} ) {
            my %color_row;
            $color_row{Corpus_Available_Color} = $color;
            $color_row{Corpus_Color_Selected}  = ( $row_data{Corpus_Bucket_Color} eq $color )?'selected':'';
            push ( @color_data, \%color_row );
	}
        $row_data{Localize_Apply}          = $self->{language__}{Apply};
        $row_data{Session_Key}             = $self->{session_key__};
        $row_data{Corpus_Loop_Loop_Colors} = \@color_data;
        push ( @corpus_data, \%row_data );
    }
    $templ->param( 'Corpus_Loop_Buckets' => \@corpus_data );

    my %bar_values;
    for my $bucket (@buckets)  {
        $bar_values{$bucket}{0} = $self->get_bucket_parameter__( $bucket, 'count' );
        $bar_values{$bucket}{1} = $self->get_bucket_parameter__( $bucket, 'fpcount' );
        $bar_values{$bucket}{2} = $self->get_bucket_parameter__( $bucket, 'fncount' );
    }

    $templ->param( 'Corpus_Bar_Chart_Classification' => $self->bar_chart_100( %bar_values ) );

    @buckets = $self->{classifier__}->get_buckets( $self->{api_session__} );

    delete $bar_values{unclassified};

    for my $bucket (@buckets)  {
        $bar_values{$bucket}{0} = $self->{classifier__}->get_bucket_word_count( $self->{api_session__}, $bucket );
        delete $bar_values{$bucket}{1};
        delete $bar_values{$bucket}{2};
    }

    $templ->param( 'Corpus_Bar_Chart_Word_Counts' => $self->bar_chart_100( %bar_values ) );

    my $number = $self->pretty_number(  $self->{classifier__}->get_unique_word_count( $self->{api_session__} ) );
    $templ->param( 'Corpus_Total_Unique' => $number );

    my $pmcount = $self->pretty_number(  $self->mcount__() );
    $templ->param( 'Corpus_Message_Count' => $pmcount );

    my $pecount = $self->pretty_number(  $self->ecount__() );
    $templ->param( 'Corpus_Error_Count' => $pecount );

    my $accuracy = $self->{language__}{Bucket_NotEnoughData};
    my $percent = 0;
    if ( $self->mcount__() > $self->ecount__() ) {
        $percent = int( 10000 * ( $self->mcount__() - $self->ecount__() ) / $self->mcount__() ) / 100;
        $accuracy = "$percent%";
    }
    $templ->param( 'Corpus_Accuracy' => $accuracy );
    $templ->param( 'Corpus_If_Last_Reset' => 1 );
    $templ->param( 'Corpus_Last_Reset' => $self->config_( 'last_reset' ) );

    if ( ( defined($self->{form_}{lookup}) ) || ( defined($self->{form_}{word}) ) ) {
        $templ->param( 'Corpus_If_Looked_Up' => 1 );
        $templ->param( 'Corpus_Word' => $self->{form_}{word} );
        my $word = $self->{form_}{word};

        if ( !( $word =~ /^[A-Za-z0-9\-_]+:/ ) ) {
	    $word = $self->{classifier__}->{parser__}->{mangle__}->mangle($word, 1);
        }

        if ( $self->{form_}{word} ne '' ) {
	    my $max = 0;
    	    my $max_bucket = '';
	    my $total = 0;
	    foreach my $bucket (@buckets) {
	        my $val = $self->{classifier__}->get_value_( $self->{api_session__}, $bucket, $word );
	        if ( $val != 0 ) {
	            my $prob = exp( $val );
	            $total += $prob;
	            if ( $prob > $max ) {
	                $max = $prob;
	                $max_bucket = $bucket;
	            }
	        } else {

	            # Take into account the probability the Bayes calculation applies
	            # for the buckets in which the word is not found.

	            $total += exp( $self->{classifier__}->get_not_likely_( $self->{api_session__} ) );
	        }
	    }

            my @lookup_data;
	    foreach my $bucket (@buckets) {
	        my $val = $self->{classifier__}->get_value_( $self->{api_session__}, $bucket, $word );

	        if ( $val != 0 ) {
                    my %row_data;
	            my $prob    = exp( $val );
  	            my $n       = ($total > 0)?$prob / $total:0;
	            my $score   = ($#buckets >= 0)?($val - $self->{classifier__}->get_not_likely_( $self->{api_session__} ) )/log(10.0):0;
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
                    $row_data{Corpus_Bucket_Color}   = $self->get_bucket_parameter__( $bucket, 'color' );
                    $row_data{Corpus_Probability}    = $probf;
                    $row_data{Corpus_Normal}         = $normal;
                    $row_data{Corpus_Score}          = $score;
                    push ( @lookup_data, \%row_data );
                }
            }
            $templ->param( 'Corpus_Loop_Lookup' => \@lookup_data );

            if ( $max_bucket ne '' ) {
                $templ->param( 'Corpus_Lookup_Message' => sprintf( $self->{language__}{Bucket_LookupMostLikely}, $word, $self->{classifier__}->get_bucket_color( $self->{api_session__}, $max_bucket ), $max_bucket ) );
            } else {
                $templ->param( 'Corpus_Lookup_Message' => sprintf( $self->{language__}{Bucket_DoesNotAppear}, $word ) );
            }
        }
    }

    $self->http_ok( $client, $templ, 1 );
}

# ---------------------------------------------------------------------------------------------
#
# compare_mf - Compares two mailfiles, used for sorting mail into order
#
# ---------------------------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------------------------
#
# sort_filter_history
#
# Called to set up the history_keys array with the appropriate order set of keys from the
# history based on the passed in filter, search and sort settings
#
# $filter       Name of bucket to filter on
# $search       From/Subject line to search for
# $sort         The field to sort on (from, subject, bucket)
#
# ---------------------------------------------------------------------------------------------
sub sort_filter_history
{
    my ( $self, $filter, $search, $sort ) = @_;

    # If the need_resort__ is set then we reindex the history indexes

    if ( $self->{need_resort__} == 1 ) {
        my $i = 0;

        foreach my $key (sort compare_mf keys %{$self->{history__}}) {
            $self->{history__}{$key}{index} = $i;
            $i += 1;
        }
    }

    # Place entries in the history_keys array based on three critera:
    #
    # 1. Whether the bucket they are classified in matches the $filter
    # 2. Whether their from/subject matches the $search
    # 3. In the order of $sort which can be from, subject or bucket

    delete $self->{history_keys__};

    if ( ( $filter ne '' ) || ( $search ne '' ) ) {
        foreach my $file (sort compare_mf keys %{$self->{history__}}) {
            if ( ( $filter eq '' ) ||                                                                            # PROFILE BLOCK START
                 ( $self->{history__}{$file}{bucket} eq $filter ) ||
                 ( ( $filter eq '__filter__magnet' ) && ( $self->{history__}{$file}{magnet} ne '' ) ) ||
                 ( ( $filter eq '__filter__no__magnet' ) && ( $self->{history__}{$file}{magnet} eq '' ) ) ) {    # PROFILE BLOCK STOP
                if ( ( $search eq '' ) ||                                                                        # PROFILE BLOCK START
                   ( $self->{history__}{$file}{from}    =~ /\Q$search\E/i ) ||
                   ( $self->{history__}{$file}{subject} =~ /\Q$search\E/i ) ) {                                  # PROFILE BLOCK STOP
                           if ( defined( $self->{history_keys__} ) ) {
                            @{$self->{history_keys__}} = (@{$self->{history_keys__}}, $file);
                        } else {
                            @{$self->{history_keys__}} = ($file);
                        }
                   }
            }
        }
    } else {
        @{$self->{history_keys__}} = keys %{$self->{history__}};
    }

    # If a sort is specified then use it to sort the history items by an a subkey
    # (from, subject or bucket) otherwise use compare_mf to give the history back
    # in the order the messages were received.  Note that when sorting on a alphanumeric
    # field we ignore all punctuation characters so that "John and 'John and John
    # all sort next to each other

    # Ascending or Descending? Ascending is noted by /-field/

    my $descending = 0;
    if ($sort =~ s/^\-//) {
        $descending = 1;
    }

    if ( ( $sort ne '' ) &&                                           # PROFILE BLOCK START

         # If the filter had no messages, this will be undefined
         # and there are no ways to sort nothing

         defined @{$self->{history_keys__}} ) {                       # PROFILE BLOCK STOP

        @{$self->{history_keys__}} = sort {
                                            my ($a1,$b1) = ($self->{history__}{$a}{$sort},  # PROFILE BLOCK START
                                              $self->{history__}{$b}{$sort});               # PROFILE BLOCK STOP
                                              $a1 =~ s/&(l|g)t;//ig;
                                              $b1 =~ s/&(l|g)t;//ig;
                                              $a1 =~ s/[^A-Z0-9]//ig;
                                              $b1 =~ s/[^A-Z0-9]//ig;
                                              return ( $a1 cmp $b1 );
                                          } @{$self->{history_keys__}};
    } else {

        # Here's a quick shortcut so that we don't have to iterate
        # if there's no work for us to do

        if ( $self->history_size() > 0 ) {
            @{$self->{history_keys__}} = sort compare_mf @{$self->{history_keys__}};
        }
    }

    @{$self->{history_keys__}} = reverse @{$self->{history_keys__}} if ($descending);

    $self->{need_resort__} = 0;
}

# ---------------------------------------------------------------------------------------------
#
# load_disk_cache__
#
# Preloads the history__ hash with information from the disk which will have been saved
# the last time we shutdown
#
# ---------------------------------------------------------------------------------------------
sub load_disk_cache__
{
    my ( $self ) = @_;

    my $cache_file = $self->get_user_path_( $self->global_config_( 'msgdir' ) . 'history_cache' );
    if ( !(-e $cache_file) ) {
        return;
    }

    open CACHE, "<$cache_file";

    my $first = <CACHE>;

    if ( $first =~ /___HISTORY__ __ VERSION__ 1/ ) {
        while ( my $line = <CACHE> ) {
            last if ( !( $line =~ /__HISTORY__ __BOUNDARY__/ ) );

            $line = <CACHE>;
            $line =~ s/[\r\n]//g;
            my $key = $line;
            $line = <CACHE>;
            $line =~ s/[\r\n]//g;
            $self->{history__}{$key}{bucket} = $line;
            $line = <CACHE>;
            $line =~ s/[\r\n]//g;
            $self->{history__}{$key}{reclassified} = $line;
            $line = <CACHE>;
            $line =~ s/[\r\n]//g;
            $self->{history__}{$key}{magnet} = $line;
            $line = <CACHE>;
            $line =~ s/[\r\n]//g;
            $self->{history__}{$key}{subject} = $line;
            $line = <CACHE>;
            $line =~ s/[\r\n]//g;
            $self->{history__}{$key}{from} = $line;
            $line = <CACHE>;
            $line =~ s/[\r\n]//g;
            $self->{history__}{$key}{short_subject} = $line;
            $line = <CACHE>;
            $line =~ s/[\r\n]//g;
            $self->{history__}{$key}{short_from} = $line;
            $self->{history__}{$key}{cull}       = 0;
        }
    }
    close CACHE;
}

# ---------------------------------------------------------------------------------------------
#
# save_disk_cache__
#
# Save the current of the history cache so that it can be reloaded next time on startup
#
# ---------------------------------------------------------------------------------------------
sub save_disk_cache__
{
    my ( $self ) = @_;

    if ( $self->{save_cache__} == 0 ) {
        return;
    }

    open CACHE, '>' . $self->get_user_path_( $self->global_config_( 'msgdir' ) . 'history_cache' );
    print CACHE "___HISTORY__ __ VERSION__ 1\n";
    foreach my $key (keys %{$self->{history__}}) {
        print CACHE "__HISTORY__ __BOUNDARY__\n";
        print CACHE "$key\n";
        print CACHE "$self->{history__}{$key}{bucket}\n";
        print CACHE "$self->{history__}{$key}{reclassified}\n";
        print CACHE "$self->{history__}{$key}{magnet}\n";
        print CACHE "$self->{history__}{$key}{subject}\n";
        print CACHE "$self->{history__}{$key}{from}\n";
        print CACHE "$self->{history__}{$key}{short_subject}\n";
        print CACHE "$self->{history__}{$key}{short_from}\n";
    }
    close CACHE;
}

# ---------------------------------------------------------------------------------------------
#
# load_history_cache__
#
# Forces a reload of the history cache from disk.  This works by globbing the history
# directory and then checking for new files that need to be loaded into the history cache
# and culling any files that have been removed without telling us
#
# ---------------------------------------------------------------------------------------------
sub load_history_cache__
{
    my ( $self ) = @_;

    # We calculate the largest value for the first number in the MSG file
    # names to verify at the end that the global download_count parameter
    # has not been corrupted.

    my $max = 0;

    # First we mark every entry in the history cache with cull set to one, after we have
    # looked through the messages directory for message we will delete any of the entries
    # in the hash that have cull still set to 1.  cull gets set to 0 everytime we see an
    # existing history cache entry that is still on the disk, or when we create a new
    # entry.  Strictly speaking this should not be necessary because when files are deleted
    # their corresponding history entry is meant to be deleted, but since disk is not 100%
    # reliable we do this check so that the history cache is in sync with the disk at all
    # times

    foreach my $key (keys %{$self->{history__}}) {
        $self->{history__}{$key}{cull} = 1;
    }

    # Now get all the names of files from the appropriate history subdirectory and run
    # through them looking for existing entries in the history which must be marked
    # for non-culling and new entries that need to be added to the end

    opendir MESSAGES, $self->get_user_path_( $self->global_config_( 'msgdir' ) );

    my @history_files;

    while ( my $entry = readdir MESSAGES ) {
        if ( $entry =~ /(popfile(\d+)=\d+\.msg)$/ ) {
            $entry = $1;

            if ( $2 > $max ) {
                $max = $2;
            }

            if ( defined( $self->{history__}{$entry} ) ) {
                $self->{history__}{$entry}{cull} = 0;
            } else {
                push @history_files, ($entry);
            }
        }
    }

    closedir MESSAGES;

    foreach my $i ( 0 .. $#history_files ) {
        $self->new_history_file__( $history_files[$i] );
    }

    # Remove any entries from the history that have been removed from disk, see the big
    # comment at the start of this function for more detail

    my $index = 0;

    foreach my $key (sort compare_mf keys %{$self->{history__}}) {
        if ( $self->{history__}{$key}{cull} == 1 ) {
            delete $self->{history__}{$key};
        } else {
            $self->{history__}{$key}{index} = $index;
            $index += 1;
        }
    }

    $self->{need_resort__}     = 0;
    $self->sort_filter_history( '', '', '' );

    if ( $max > $self->global_config_( 'download_count' ) ) {
        $self->global_config_( 'download_count', $max+1 );
    }
}

# ---------------------------------------------------------------------------------------------
#
# new_history_file__
#
# Adds a new file to the history cache
#
# $file                The name of the file added
# $index               (optional) The history keys index
#
# ---------------------------------------------------------------------------------------------
sub new_history_file__
{
    my ( $self, $file, $index ) = @_;

    # Find the class information for this file using the history_read_class helper
    # function, and then parse the MSG file for the From and Subject information

    my ( $reclassified, $bucket, $usedtobe, $magnet ) = $self->{classifier__}->history_read_class( $file );
    my $from    = '';
    my $subject = '';
    my $long_header = '';

    $magnet       = '' if ( !defined( $magnet ) );
    $reclassified = '' if ( !defined( $reclassified ) );

    if ( open MAIL, '<'. $self->get_user_path_( $self->global_config_( 'msgdir' ) . $file ) ) {
        while ( <MAIL> )  {
            last if ( /^(\r\n|\r|\n)/ );

            # Support long header that has more than 2 lines

            if ( /^[\t ]+(=\?[\w-]+\?[BQ]\?.*\?=.*)/ ) {
                if ( $long_header eq 'from' ) {
                    $from .= $1;
                    next;
                }

                if ( $long_header eq 'subject' ) {
                    $subject .= $1;
                    next;
                }
            } else {
                if ( /^From: *(.*)/i ) {
                    $long_header = 'from';
                    $from = $1;
                    next;
                } else {
                    if ( /^Subject: *(.*)/i ) {
                        $long_header = 'subject';
                        $subject = $1;
                        next;
                    }
                }
                $long_header = '';
            }

            last if ( ( $from ne '' ) && ( $subject ne '' ) );
        }
        close MAIL;
    }

    $from    = "<$self->{language__}{History_NoFrom}>"    if ( $from eq '' );
    $subject = "<$self->{language__}{History_NoSubject}>" if ( !( $subject =~ /[^ \t\r\n]/ ) );

    $from    =~ s/\"(.*)\"/$1/g;
    $subject =~ s/\"(.*)\"/$1/g;

    # TODO Interface violation here, need to clean up
    # Pass language parameter to decode_string()

    $from    = $self->{classifier__}->{parser__}->decode_string( $from, $self->config_( 'language' ) );
    $subject = $self->{classifier__}->{parser__}->decode_string( $subject, $self->config_( 'language' ) );

    my ( $short_from, $short_subject ) = ( $from, $subject );

    if ( length($short_from)>40 )  {
        $short_from =~ /(.{40})/;
        $short_from = "$1...";
    }

    if ( length($short_subject)>40 )  {
        $short_subject =~ s/=20/ /g;
        $short_subject =~ /(.{40})/;
        $short_subject = $1;

        # Do not truncate at 39 if the last char is the first byte of DBCS char(pair of two bytes).
        # Truncate it 1 byte shorter.
        if ( $self->config_( 'language' ) =~ /^Korean|Nihongo$/ ) {
            $short_subject =~ s/(([\x80-\xff].)*)[\x80-\xff]?$/$1/;
            $short_subject .= "...";
        } else {
            $short_subject .= "...";
        }
    }

    $from =~ s/&/&amp;/g;
    $from =~ s/</&lt;/g;
    $from =~ s/>/&gt;/g;
    $from =~ s/"/&quot;/g;

    $short_from =~ s/&/&amp;/g;
    $short_from =~ s/</&lt;/g;
    $short_from =~ s/>/&gt;/g;
    $short_from =~ s/"/&quot;/g;

    $subject =~ s/&/&amp;/g;
    $subject =~ s/</&lt;/g;
    $subject =~ s/>/&gt;/g;
    $subject =~ s/"/&quot;/g;

    $short_subject =~ s/&/&amp;/g;
    $short_subject =~ s/</&lt;/g;
    $short_subject =~ s/>/&gt;/g;
    $short_subject =~ s/"/&quot;/g;

    # If the index is known, stick it straight into the history else go into
    # the precache for merging into history when the history is viewed next

    my $cache = 'history__';
    if ( !defined( $index ) ) {
        $cache = 'history_pre_cache__';
    }

    $self->{$cache}{$file}{bucket}        = $bucket;
    $self->{$cache}{$file}{reclassified}  = $reclassified;
    $self->{$cache}{$file}{magnet}        = $magnet;
    $self->{$cache}{$file}{subject}       = $subject;
    $self->{$cache}{$file}{from}          = $from;
    $self->{$cache}{$file}{short_subject} = $short_subject;
    $self->{$cache}{$file}{short_from}    = $short_from;
    $self->{$cache}{$file}{cull}          = 0;

    if ( !defined( $index ) ) {
        $index = 0;
        $self->{need_resort__} = 1;
    }

    $self->{$cache}{$file}{index}         = $index;
}

# ---------------------------------------------------------------------------------------------
#
# history_cache_empty
#
# Returns whether the cache is empty or not
#
# ---------------------------------------------------------------------------------------------
sub history_cache_empty
{
    my ( $self ) = @_;

    return ( $self->history_size() == 0 );
}

# ---------------------------------------------------------------------------------------------
#
# history_size
#
# Returns the size of the history cache, note that this is actually the size of the
# history_keys array since that is used to access selected entries in the history cache
# itself
#
# ---------------------------------------------------------------------------------------------
sub history_size
{
    my ( $self ) = @_;

    if ( defined( $self->{history_keys__} ) ) {
        my @keys = @{$self->{history_keys__}};

        return ($#keys + 1);
    } else {
        return 0;
    }
}

# ---------------------------------------------------------------------------------------------
#
# set_history_navigator__
#
# Fix up the history-navigator-widget.thtml template
#
# $templ                - The template to fix up
# $start_message        - The number of the first message displayed
# $stop_message         - The number of the last message displayed
#
# ---------------------------------------------------------------------------------------------
sub set_history_navigator__
{
    my ( $self, $templ, $start_message, $stop_message ) = @_;

    $templ->param( 'History_Navigator_Fields' => $self->print_form_fields_(0,1,('session','filter','search','sort' ) ) );

    if ( $start_message != 0 )  {
        $templ->param( 'History_Navigator_If_Previous' => 1 );
        $templ->param( 'History_Navigator_Previous'    => $start_message - $self->config_( 'page_size' ) );
    }

    # Only show two pages either side of the current page, the first page and the last page
    #
    # e.g. [1] ... [4] [5] [6] [7] [8] ... [24]

    my $i = 0;
    my $p = 1;
    my $dots = 0;
    my @nav_data;
    while ( $i < $self->history_size() ) {
        my %row_data;
        if ( ( $i == 0 ) ||
             ( ( $i + $self->config_( 'page_size' ) ) >= $self->history_size() ) ||
             ( ( ( $i - 2 * $self->config_( 'page_size' ) ) <= $start_message ) &&
               ( ( $i + 2 * $self->config_( 'page_size' ) ) >= $start_message ) ) ) {
            $row_data{History_Navigator_Page} = $p;
            $row_data{History_Navigator_I} = $i;
            if ( $i == $start_message ) {
                $row_data{History_Navigator_If_This_Page} = 1;
            } else {
                $row_data{History_Navigator_Fields} = $self->print_form_fields_(0,1,('session','filter','search','sort'));
            }

            $dots = 1;
        } else {
            $row_data{History_Navigator_If_Spacer} = 1;
	    if ( $dots ) {
                $row_data{History_Navigator_If_Dots} = 1;
	    }
            $dots = 0;
        }

        $i += $self->config_( 'page_size' );
        $p++;
        push ( @nav_data, \%row_data );
    }
    $templ->param( 'History_Navigator_Loop' => \@nav_data );

    if ( $start_message < ( $self->history_size() - $self->config_( 'page_size' ) ) )  {
        $templ->param( 'History_Navigator_If_Next' => 1 );
        $templ->param( 'History_Navigator_Next'    => $start_message + $self->config_( 'page_size' ) );
    }
}

# ---------------------------------------------------------------------------------------------
#
# set_magnet_navigator__
#
# Sets the magnet navigator up in a template
#
# $templ         - The loaded Magnet page template
# $start_magnet  - The number of the first magnet
# $stop_magnet   - The number of the last magnet
# $magnet_count  - Total number of magnets
#
# ---------------------------------------------------------------------------------------------
sub set_magnet_navigator__
{
    my ( $self, $templ, $start_magnet, $stop_magnet, $magnet_count ) = @_;

    if ( $start_magnet != 0 )  {
        $templ->param( 'Magnet_Navigator_If_Previous' => 1 );
        $templ->param( 'Magnet_Navigator_Previous'    => $start_magnet - $self->config_( 'page_size' ) );
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

        $i += $self->config_( 'page_size' );
        push ( @page_loop, \%row_data );
    }
    $templ->param( 'Magnet_Navigator_Loop_Pages' => \@page_loop );

    if ( $start_magnet < ( $magnet_count - $self->config_( 'page_size' ) ) )  {
        $templ->param( 'Magnet_Navigator_If_Next' => 1 );
        $templ->param( 'Magnet_Navigator_Next'    => $start_magnet + $self->config_( 'page_size' ) );
    }
}


# ---------------------------------------------------------------------------------------------
#
# history_reclassify - handle the reclassification of messages on the history page
#
# ---------------------------------------------------------------------------------------------
sub history_reclassify
{
    my ( $self ) = @_;

    if ( defined( $self->{form_}{change} ) ) {

        $self->{save_cache__} = 1;

        # This hash will map filenames of MSG files in the history to the
        # new classification that they should be, it is built by iterating
        # through the $self->{form_} looking for entries with the message number
        # of each message that is displayed and then creating an entry in
        # %messages if there is a corresponding entry in $self->{form_} for
        # that message number

        my %messages;

        foreach my $i ( $self->{form_}{start_message}  .. $self->{form_}{start_message} + $self->config_( 'page_size' ) - 1) {
            my $mail_file = $self->{history_keys__}[$i];

            # The first check makes sure we didn't run off the end of the history table
            # the second that there is something defined for this message number and the
            # third that this message number has a value (i.e. a bucket name)

            if ( defined( $mail_file ) && defined( $self->{form_}{$i} ) && ( $self->{form_}{$i} ne '' ) ) {
                $messages{$mail_file} = $self->{form_}{$i};
            }
        }

        # At this point %messages maps that files that need reclassifying to their
        # new bucket classification

        # This hash maps buckets to list of files to place in those buckets

        my %work;

        while ( my ($mail_file, $newbucket) = each %messages ) {

            # Get the current classification for this message

            my ( $reclassified, $bucket, $usedtobe, $magnet) = $self->{classifier__}->history_read_class( $mail_file );

            # Only reclassify messages that haven't been reclassified before

            if ( !$reclassified ) {
                push @{$work{$newbucket}}, $self->get_user_path_( $self->global_config_( 'msgdir' ) . $mail_file );

                $self->log_( "Reclassifying $mail_file from $bucket to $newbucket" );

                if ( $bucket ne $newbucket ) {
                    my $count = $self->get_bucket_parameter__( $newbucket, 'count' );
                    $self->set_bucket_parameter__( $newbucket, 'count', $count+1 );

                    $count = $self->get_bucket_parameter__( $bucket, 'count' );
                    $count -= 1;
                    $count = 0 if ( $count < 0 ) ;
                    $self->set_bucket_parameter__( $bucket, 'count', $count );

                    my $fncount = $self->get_bucket_parameter__( $newbucket, 'fncount' );
                    $self->set_bucket_parameter__( $newbucket, 'fncount', $fncount+1 );

                    my $fpcount = $self->get_bucket_parameter__( $bucket, 'fpcount' );
                    $self->set_bucket_parameter__( $bucket, 'fpcount', $fpcount+1 );
                }

                # Update the class file

                $self->{classifier__}->history_write_class( $mail_file, 1, $newbucket, ( $bucket || "unclassified" ) , '');

                # Since we have just changed the classification of this file and it has
                # now been reclassified and has a new bucket name then we need to update the
                # history cache to reflect that

                $self->{history__}{$mail_file}{reclassified} = 1;
                $self->{history__}{$mail_file}{bucket}       = $newbucket;

                # Add message feedback

                $self->{feedback}{$mail_file} = sprintf( $self->{language__}{History_ChangedTo}, $self->{classifier__}->get_bucket_color( $self->{api_session__}, $newbucket ), $newbucket );

                $self->{configuration__}->save_configuration();
            }
        }

        # At this point the work hash maps the buckets to lists of files to reclassify, so run through
        # them doing bulk updates

        foreach my $newbucket (keys %work) {
            $self->{classifier__}->add_messages_to_bucket( $self->{api_session__}, $newbucket, @{$work{$newbucket}} );
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# history_undo - handle undoing of reclassifications of messages on the history page
#
# ---------------------------------------------------------------------------------------------
sub history_undo
{
    my( $self ) = @_;

    foreach my $key (keys %{$self->{form_}}) {
        if ( $key =~ /^undo_([0-9]+)$/ ) {
            my $mail_file = $self->{history_keys__}[$1];
            my %temp_corpus;

            # Load the class file

            my ( $reclassified, $bucket, $usedtobe, $magnet ) = $self->{classifier__}->history_read_class( $mail_file );

            # Only undo if the message has been classified...

            if ( defined( $usedtobe ) ) {
                $self->{classifier__}->remove_message_from_bucket( $self->{api_session__}, $bucket, $self->get_user_path_( $self->global_config_( 'msgdir' ) . $mail_file ) );

                $self->{save_cache__} = 1;

                $self->log_( "Undoing $mail_file from $bucket to $usedtobe" );

                if ( $bucket ne $usedtobe ) {
                    my $count = $self->get_bucket_parameter__( $bucket, 'count' ) - 1;
                    $count = 0 if ( $count < 0 );
                    $self->set_bucket_parameter__( $bucket, 'count', $count );

                    $count = $self->get_bucket_parameter__( $usedtobe, 'count' ) + 1;
                    $self->set_bucket_parameter__( $usedtobe, 'count', $count );

                    my $fncount = $self->get_bucket_parameter__( $bucket, 'fncount' ) - 1;
                    $fncount = 0 if ( $fncount < 0 );
                    $self->set_bucket_parameter__( $bucket, 'fncount', $fncount );

                    my $fpcount = $self->get_bucket_parameter__( $usedtobe, 'fpcount' ) - 1;
                    $fpcount = 0 if ( $fpcount < 0 );
                    $self->set_bucket_parameter__( $usedtobe, 'fpcount', $fpcount );
                }

                # Since we have just changed the classification of this file and it has
                # not been reclassified and has a new bucket name then we need to update the
                # history cache to reflect that

                $self->{history__}{$mail_file}{reclassified} = 0;
                $self->{history__}{$mail_file}{bucket}       = $usedtobe;

                # Update the class file

                $self->{classifier__}->history_write_class( $mail_file, 0, ( $usedtobe || "unclassified" ), '', '');

                # Add message feedback

                $self->{feedback}{$mail_file} = sprintf( $self->{language__}{History_ChangedTo}, ($self->{classifier__}->get_bucket_color( $self->{api_session__}, $usedtobe ) || ''), $usedtobe );

                $self->{configuration__}->save_configuration();
            }
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# history_page - get the message classification history page
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub history_page
{
    my ( $self, $client, $templ ) = @_;

    # Set up default values for various form elements that have been passed
    # in or not so that we don't have to worry about undefined values later
    # on in the function

    $self->{form_}{sort}   = $self->{old_sort__} || '' if ( !defined( $self->{form_}{sort}   ) );
    $self->{form_}{search} = (!defined($self->{form_}{setsearch})?$self->{old_search__}:'') || '' if ( !defined( $self->{form_}{search} ) );
    $self->{form_}{filter} = (!defined($self->{form_}{setfilter})?$self->{old_filter__}:'') || '' if ( !defined( $self->{form_}{filter} ) );

    # If the user is asking for a new sort option then it needs to get
    # stored in the sort form variable so that it can be used for subsequent
    # page views of the History to keep the sort in place

    $self->{form_}{sort} = $self->{form_}{setsort} if ( defined( $self->{form_}{setsort} ) );

    # Cache some values to keep interface widgets updated if history is re-accessed without parameters

    $self->{old_sort__} = $self->{form_}{sort};

    # If the user hits the Reset button on a search then we need to clear
    # the search value but make it look as though they hit the search button
    # so that sort_filter_history will get called below to get the right values
    # in history_keys

    if ( defined( $self->{form_}{reset_filter_search} ) ) {
        $self->{form_}{filter}    = '';
        $self->{form_}{search}    = '';
        $self->{form_}{setsearch} = 1;
    }

    # Information from submit buttons isn't always preserved if the buttons aren't
    # pressed. This compares values in some fields and sets the button-values as
    # though they had been pressed

    # Set setsearch if search changed and setsearch is undefined
    $self->{form_}{setsearch} = 'on' if ( ( ( !defined($self->{old_search__}) && ($self->{form_}{search} ne '') ) || ( defined($self->{old_search__}) && ( $self->{old_search__} ne $self->{form_}{search} ) ) ) && !defined($self->{form_}{setsearch} ) );
    $self->{old_search__} = $self->{form_}{search};

    # Set setfilter if filter changed and setfilter is undefined
    $self->{form_}{setfilter} = 'Filter' if ( ( ( !defined($self->{old_filter__}) && ($self->{form_}{filter} ne '') ) || ( defined($self->{old_filter__}) && ( $self->{old_filter__} ne $self->{form_}{filter} ) ) ) && !defined($self->{form_}{setfilter} ) );
    $self->{old_filter__} = $self->{form_}{filter};

    # Set up the text that will appear at the top of the history page
    # indicating the current filter and search settings

    my $filter = $self->{form_}{filter};
    my $filtered = '';
    if ( !( $filter eq '' ) ) {
        if ( $filter eq '__filter__magnet' ) {
            $filtered .= $self->{language__}{History_Magnet};
        } else {
            if ( $filter eq '__filter__no__magnet' ) {
                $filtered .= $self->{language__}{History_NoMagnet};
            } else {
                $filtered = sprintf( $self->{language__}{History_Filter}, $self->{classifier__}->get_bucket_color( $self->{api_session__}, $self->{form_}{filter} ), $self->{form_}{filter} ) if ( $self->{form_}{filter} ne '' );
            }
        }
    }

    $filtered .= sprintf( $self->{language__}{History_Search}, $self->{form_}{search} ) if ( $self->{form_}{search} ne '' );

    # Handle the reinsertion of a message file or the user hitting the
    # undo button

    $self->history_reclassify();
    $self->history_undo();

    # Handle removal of one or more items from the history page, the remove_array form, if defined,
    # will contain all the indexes into history_keys that need to be deleted. If undefined, the remove
    # form element will contain the single index to be deleted. We pass each file that needs
    # deleting into the history_delete_file helper

    if ( defined( $self->{form_}{deletemessage} ) ) {

        # Remove the list of marked messages using the array of "remove" checkboxes, the fact
        # that deletemessage is defined will later on cause a call to sort_filter_history
        # that will reload the history_keys with the appropriate messages that now exist
        # in the cache.  Note that there is no need to invalidate the history cache since
        # we are in control of deleting messages

        for my $i ( keys %{$self->{form_}} ) {
            if ( $i =~ /^remove_(\d+)$/ ) {
                $self->history_delete_file( $self->{history_keys__}[$1 - 1], 0);
            }
        }
    }

    # Handle clearing the history files, there are two options here, clear the current page
    # or clear all the files in the cache

    if ( defined( $self->{form_}{clearall} ) ) {
        foreach my $i (0 .. $self->history_size()-1 ) {
            $self->history_delete_file( $self->{history_keys__}[$i],   # PROFILE BLOCK START
                                        $self->config_( 'archive' ) ); # PROFILE BLOCK STOP
        }
    }

    if ( defined($self->{form_}{clearpage}) ) {
        foreach my $i ( $self->{form_}{start_message} .. $self->{form_}{start_message} + $self->config_( 'page_size' ) - 1 ) {
            if ( defined( $self->{history_keys__}[$i] ) ) {
                $self->history_delete_file( $self->{history_keys__}[$i],   # PROFILE BLOCK START
                                            $self->config_( 'archive' ) ); # PROFILE BLOCK STOP
            }
        }

        # Check that the start_message now exists, if not then go back a page

        while ( ( $self->{form_}{start_message} + $self->config_( 'page_size' ) ) >= $self->history_size() ) {
            $self->{form_}{start_message} -= $self->config_( 'page_size' );
        }
    }

    $self->copy_pre_cache__();

    # If the history cache is invalid then we need to reload it and then if
    # any of the sort, search or filter options have changed they must be
    # applied.  The watch word here is to avoid doing work

    $self->sort_filter_history( $self->{form_}{filter}, # PROFILE BLOCK START
                                $self->{form_}{search},
                                $self->{form_}{sort} ) if ( ( defined( $self->{form_}{setfilter}     ) ) ||
                                                            ( defined( $self->{form_}{setsort}       ) ) ||
                                                            ( defined( $self->{form_}{setsearch}     ) ) ||
                                                            ( defined( $self->{form_}{deletemessage} ) ) ||
                                                            ( defined( $self->{form_}{clearall}      ) ) ||
                                                            ( defined( $self->{form_}{clearpage}     ) ) ||
                                                            ( $self->{need_resort__} == 1 )            );      # PROFILE BLOCK STOP

    # Redirect somewhere safe if non-idempotent action has been taken

    if ( defined( $self->{form_}{deletemessage}  ) ||  # PROFILE BLOCK START
         defined( $self->{form_}{clearpage}      ) ||
         defined( $self->{form_}{undo}           ) ||
         defined( $self->{form_}{reclassify}     ) ) { # PROFILE BLOCK STOP
        return $self->http_redirect_( $client, "/history?" . $self->print_form_fields_(1,0,('start_message','filter','search','sort','session') ) );
    }

    $templ->param( 'History_Field_Search'  => $self->{form_}{search} );
    $templ->param( 'History_If_Search'     => defined( $self->{form_}{search} ) );
    $templ->param( 'History_Field_Sort'    => $self->{form_}{sort} );
    $templ->param( 'History_Field_Filter'  => $self->{form_}{filter} );
    $templ->param( 'History_Filtered'      => $filtered );
    $templ->param( 'History_If_MultiPage'  => $self->config_( 'page_size' ) <= $self->history_size() );

    my @buckets = $self->{classifier__}->get_buckets( $self->{api_session__} );

    my @bucket_data;
    foreach my $bucket (@buckets) {
        my %row_data;
        $row_data{History_Bucket} = $bucket;
        $row_data{History_Bucket_Color}  = $self->{classifier__}->get_bucket_parameter( $self->{api_session__},
                                                                      $bucket,
                                                                      'color' );
        push ( @bucket_data, \%row_data );
    }

    my @sf_bucket_data;
    foreach my $bucket (@buckets) {
        my %row_data;
        $row_data{History_Bucket} = $bucket;
        $row_data{History_Selected} = ( defined( $self->{form_}{filter} ) && ( $self->{form_}{filter} eq $bucket ) )?'selected':'';
        $row_data{History_Bucket_Color}  = $self->{classifier__}->get_bucket_parameter( $self->{api_session__},
                                                                      $bucket,
                                                                      'color' );
        push ( @sf_bucket_data, \%row_data );
    }
    $templ->param( 'History_Loop_SF_Buckets' => \@sf_bucket_data );

    $templ->param( 'History_Filter_Magnet' => ($self->{form_}{filter} eq '__filter__magnet')?'selected':'' );
    $templ->param( 'History_Filter_No_Magnet' => ($self->{form_}{filter} eq '__filter__no__magnet')?'selected':'' );
    $templ->param( 'History_Filter_Unclassified' => ($self->{form_}{filter} eq 'unclassified')?'selected':'' );

    if ( !$self->history_cache_empty() )  {
        $templ->param( 'History_If_Some_Messages' => 1 );

        my $start_message = 0;
        $start_message = $self->{form_}{start_message} if ( ( defined($self->{form_}{start_message}) ) && ($self->{form_}{start_message} > 0 ) );
        $self->{form_}{start_message} = $start_message;
        $templ->param( 'History_Start_Message' => $start_message );

        my $stop_message  = $start_message + $self->config_( 'page_size' ) - 1;
        $stop_message = $self->history_size() - 1 if ( $stop_message >= $self->history_size() );

        $self->set_history_navigator__( $templ, $start_message, $stop_message );

        my %headers_table = ( '',        'ID',              # PROFILE BLOCK START
                              'from',    'From',
                              'subject', 'Subject',
                              'bucket',  'Classification'); # PROFILE BLOCK STOP


        # It would be tempting to do keys %headers_table here but there is not guarantee that
        # they will come back in the right order

        my @header_data;
        foreach my $header ('', 'from', 'subject', 'bucket') {
            my %row_data;
            $row_data{History_Fields} = $self->print_form_fields_(1,1,('filter','session','search'));
            $row_data{History_Sort}   = ( $self->{form_}{sort} eq $header )?'-':'';
            $row_data{History_Header} = $header;

            my $label = '';
            if ( defined $self->{language__}{ $headers_table{$header} }) {
                $label = $self->{language__}{ $headers_table{$header} };
            } else {
                $label = $headers_table{$header};
            }
            $row_data{History_Label} = $label;
            $row_data{History_If_Sorted} = ( $self->{form_}{sort} =~ /^\-?\Q$header\E$/ );
            $row_data{History_If_Sorted_Ascending} = ( $self->{form_}{sort} !~ /^-/ );
            push ( @header_data, \%row_data );
        }
        $templ->param( 'History_Loop_Headers' => \@header_data );

        my @history_data;
        foreach my $i ($start_message..$stop_message) {
            my %row_data;
            my $mail_file = $row_data{History_Mail_File} = $self->{history_keys__}[$i];
            $row_data{History_From}          = $self->{history__}{$mail_file}{from};
            $row_data{History_Subject}       = $self->{history__}{$mail_file}{subject};
            $row_data{History_Short_From}    = $self->{history__}{$mail_file}{short_from};
            $row_data{History_Short_Subject} = $self->{history__}{$mail_file}{short_subject};
            my $bucket = $row_data{History_Bucket} = $self->{history__}{$mail_file}{bucket};
            $row_data{History_Bucket_Color}  = $self->{classifier__}->get_bucket_parameter( $self->{api_session__},
                                                                          $bucket,
                                                                          'color' );
            $row_data{History_If_Reclassified} = $self->{history__}{$mail_file}{reclassified};
            $row_data{History_Index}         = $self->{history__}{$mail_file}{index} + 1;
            $row_data{History_I}             = $i;
            $row_data{History_I1}            = $i + 1;
            $row_data{History_Fields}        = $self->print_form_fields_(0,1,('start_message','session','filter','search','sort' ) );
            $row_data{History_If_Not_Pseudo} = !$self->{classifier__}->is_pseudo_bucket( $self->{api_session__},
                                                                           $bucket );
            $row_data{History_If_Magnetized} = ( $self->{history__}{$mail_file}{magnet} ne '' );
            $row_data{History_Magnet}        = $self->{history__}{$mail_file}{magnet};
            $row_data{History_Loop_Loop_Buckets} = \@bucket_data;
            if ( defined $self->{feedback}{$mail_file} ) {
                $row_data{History_If_Feedback} = 1;
                $row_data{History_Feedback} = $self->{feedback}{$mail_file};
                delete $self->{feedback}{$mail_file};
            }
            $row_data{Session_Key} = $self->{session_key__};
            $row_data{Localize_Remove}     = $self->{language__}{Remove};

            push ( @history_data, \%row_data );
        }
        $templ->param( 'History_Loop_Messages' => \@history_data );
    }

    $self->http_ok( $client, $templ, 0 );
}

# ---------------------------------------------------------------------------------------------
#
# view_page - Shows a single email
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub view_page
{
    my ( $self, $client, $templ ) = @_;

    my $mail_file     = $self->{form_}{view};
    my $start_message = $self->{form_}{start_message} || 0;
    my $reclassified  = $self->{history__}{$mail_file}{reclassified};
    my $bucket        = $self->{history__}{$mail_file}{bucket};
    my $color         = $self->{classifier__}->get_bucket_color( $self->{api_session__}, $bucket );
    my $page_size     = $self->config_( 'page_size' );

    $self->{form_}{sort}   = '' if ( !defined( $self->{form_}{sort}   ) );
    $self->{form_}{search} = '' if ( !defined( $self->{form_}{search} ) );
    $self->{form_}{filter} = '' if ( !defined( $self->{form_}{filter} ) );
    $self->{form_}{format} = $self->config_( 'wordtable_format' ) if ( !defined( $self->{form_}{format} ) );

    # If a format change was requested for the word matrix, record it in the
    # configuration and in the classifier options.

    $self->{classifier__}->wmformat( $self->{form_}{format} );

    my $index = -1;

    foreach my $i ( 0 .. $self->history_size()-1 ) {
        if ( $self->{history_keys__}[$i] eq $mail_file ) {
            use integer;
            $index         = $i;
            $start_message = ($i / $page_size ) * $page_size;
            $self->{form_}{start_message} = $start_message;
            last;
        }
    }

    $templ->param( 'View_Fields'           => $self->print_form_fields_(0,1,('filter','session','search','sort')) );
    $templ->param( 'View_All_Fields'       => $self->print_form_fields_(1,1,('start_message','filter','session','search','sort')));
    $templ->param( 'View_If_Previous'      => ( $index > 0 ) );
    $templ->param( 'View_Previous'         => $self->{history_keys__}[ $index - 1 ] );
    $templ->param( 'View_Previous_Message' => (( $index - 1 ) >= $start_message)?$start_message:($start_message - $page_size));
    $templ->param( 'View_If_Next'          => ( $index < ( $self->history_size() - 1 ) ) );
    $templ->param( 'View_Next'             => $self->{history_keys__}[ $index + 1 ] );
    $templ->param( 'View_Next_Message'     => (( $index + 1 ) < ( $start_message + $page_size ) )?$start_message:($start_message + $page_size));

    $templ->param( 'View_Field_Search'     => $self->{form_}{search} );
    $templ->param( 'View_Field_Sort'       => $self->{form_}{sort}   );
    $templ->param( 'View_Field_Filter'     => $self->{form_}{filter} );

    $templ->param( 'View_From'             => $self->{history__}{$mail_file}{from}    );
    $templ->param( 'View_Subject'          => $self->{history__}{$mail_file}{subject} );
    $templ->param( 'View_Bucket'           => $self->{history__}{$mail_file}{bucket}  );
    $templ->param( 'View_Bucket_Color'     => $color );

    $templ->param( 'View_Index'            => $index );
    $templ->param( 'View_This'             => $self->{history_keys__}[ $index ] );
    $templ->param( 'View_This_Page'        => (( $index ) >= $start_message )?$start_message:($start_message - $self->config_( 'page_size' )));

    $templ->param( 'View_If_Reclassified'  => $reclassified );
    if ( $reclassified ) {
        $templ->param( 'View_Already' => sprintf( $self->{language__}{History_Already}, ($color || ''), ($bucket || '') ) );
    } else {
        $templ->param( 'View_If_Magnetized' => ( $self->{history__}{$mail_file}{magnet} ne '' ) );
        if ( $self->{history__}{$mail_file}{magnet} eq '' ) {
            my @bucket_data;
            foreach my $abucket ($self->{classifier__}->get_buckets( $self->{api_session__} )) {
                my %row_data;
                $row_data{View_Bucket_Color} = $self->{classifier__}->get_bucket_color( $self->{api_session__}, $abucket );
                $row_data{View_Bucket} = $abucket;
                push ( @bucket_data, \%row_data );
	    }
            $templ->param( 'View_Loop_Buckets' => \@bucket_data );
        } else {
            $templ->param( 'View_Magnet' => $self->{history__}{$mail_file}{magnet} );
        }
    }

    if ( $self->{history__}{$mail_file}{magnet} eq '' ) {
        my %matrix;
        my %idmap;

        # Enable saving of word-scores

        $self->{classifier__}->wordscores( 1 );

        # Build the scores by classifying the message, since get_html_colored_message has parsed the message
        # for us we do not need to parse it again and hence we pass in undef for the filename

        my $current_class = $self->{classifier__}->classify( $self->{api_session__}, $self->get_user_path_( $self->global_config_( 'msgdir' ) . $mail_file ), $templ, \%matrix, \%idmap );

        # Check whether the original classfication is still valid.
        # If not, add a note at the top of the page:

        if ( $current_class ne $self->{history__}{$mail_file}{bucket} ) {
            my $new_color = $self->{classifier__}->get_bucket_color( $self->{api_session__}, $current_class );
            $templ->param( 'View_If_Class_Changed' => 1 );
            $templ->param( 'View_Class_Changed' => $current_class );
            $templ->param( 'View_Class_Changed_Color' => $new_color );
        }

        # Disable, print, and clear saved word-scores

        $self->{classifier__}->wordscores( 0 );

        $templ->param( 'View_Message' => $self->{classifier__}->fast_get_html_colored_message(
            $self->{api_session__}, $self->get_user_path_( $self->global_config_( 'msgdir' ) . $mail_file ), \%matrix, \%idmap ) );

        # We want to insert a link to change the output format at the start of the word
        # matrix.  The classifier puts a comment in the right place, which we can replace
        # by the link.  (There's probably a better way.)

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
        $self->{history__}{$mail_file}{magnet} =~ /(.+): ([^\r\n]+)/;
        my $header = $1;
        my $text   = $2;
        my $body = '<tt>';

        open MESSAGE, '<' . $self->get_user_path_( $self->global_config_( 'msgdir' ) . $mail_file );
        my $line;

        while ($line = <MESSAGE>) {
            $line =~ s/</&lt;/g;
            $line =~ s/>/&gt;/g;

            $line =~ s/([^\r\n]{100,150} )/$1<br \/>/g;
            $line =~ s/([^ \r\n]{150})/$1<br \/>/g;
            $line =~ s/[\r\n]+/<br \/>/g;

            if ( $line =~ /^([A-Za-z-]+): ?([^\n\r]*)/ ) {
                my $head = $1;
                my $arg  = $2;

                if ( $head =~ /\Q$header\E/i ) {

                    $text =~ s/</&lt;/g;
                    $text =~ s/>/&gt;/g;

                    if ( $arg =~ /\Q$text\E/i ) {
                          my $new_color = $self->{classifier__}->get_bucket_color( $self->{api_session__}, $bucket );
                          $line =~ s/(\Q$text\E)/<b><font color=\"$new_color\">$1<\/font><\/b>/;
                    }
                }
            }

            $body .= $line;
        }
        close MESSAGE;
        $body .= '</tt>';
        $templ->param( 'View_Message' => $body );
    }

    if ($self->{history__}{$mail_file}{magnet} ne '') {
        $templ->param( 'View_Magnet_Reason' => sprintf( $self->{language__}{History_MagnetBecause},  # PROFILE BLOCK START
                          $color, $bucket,
                          Classifier::MailParse::splitline($self->{history__}{$mail_file}{magnet},0)
            ) );                                                                                     # PROFILE BLOCK STOP
    }

    $self->http_ok( $client, $templ, 0 );
}

# ---------------------------------------------------------------------------------------------
#
# password_page - Simple page asking for the POPFile password
#
# $client     The web browser to send the results to
# $error      1 if the user previously typed the password incorrectly
# $redirect   The page to go to on a correct password
#
# ---------------------------------------------------------------------------------------------
sub password_page
{
    my ( $self, $client, $error, $redirect ) = @_;
    my $session_temp = $self->{session_key__};

    # Show a page asking for the password with no session key information on it

    $self->{session_key__} = '';
    my $templ = $self->load_template__( 'password-page.thtml' );
    $self->{session_key__} = $session_temp;

    # These things need fixing up on the password page:
    #
    # The page to redirect to if the user gets the password right
    # An error if they typed in the wrong password

    $templ->param( 'Password_If_Error' => $error );
    $templ->param( 'Password_Redirect' => $redirect );

    $self->http_ok( $client, $templ );
}

# ---------------------------------------------------------------------------------------------
#
# session_page - Simple page information the user of a bad session key
#
# $client     The web browser to send the results to
#
# ---------------------------------------------------------------------------------------------
sub session_page
{
    my ( $self, $client ) = @_;

    my $templ = $self->load_template__( 'session-page.thtml' );
    $self->http_ok( $client, $templ );
}

# ---------------------------------------------------------------------------------------------
#
# load_template__
#
# Loads the named template and returns a new HTML::Template object
#
# $template          The name of the template to load from the current skin
#
# ---------------------------------------------------------------------------------------------
sub load_template__
{
    my ( $self, $template ) = @_;

    # First see if that template exists in the currently selected skin, if it does not
    # then load the template from the default.  This allows a skin author to change
    # just a single part of POPFile with duplicating that entire set of templates

    my $root = 'skins/' . $self->config_( 'skin' ) . '/';
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
        cache             => $self->config_( 'cache_templates' ) );

    # Set a variety of common elements that are used repeatedly throughout
    # POPFile's pages

    my $now = localtime;
    my %fixups = ( 'Skin_Root'               => $root,
                   'Session_Key'             => $self->{session_key__},
                   'Common_Bottom_Date'      => $now,
                   'Common_Bottom_LastLogin' => $self->{last_login__},
                   'Common_Bottom_Version'   => $self->version() );

    foreach my $fixup (keys %fixups) {
        if ( $templ->query( name => $fixup ) ) {
            $templ->param( $fixup => $fixups{$fixup} );
        }
    }

    # Localize the template in use.
    #
    # Templates are automatically localized.  Any TMPL_VAR that begins with
    # Localize_ will be fixed up automatically with the appropriate string
    # for the language in use.  For example if you write
    #
    #     <TMPL_VAR name="Localize_Foo_Bar">
    #
    # this will automatically be converted to the string associated with
    # Foo_Bar in the current language file.

    my @vars = $templ->param();

    foreach my $var (@vars) {
        if ( $var =~ /^Localize_(.*)/ ) {
            $templ->param( $var => $self->{language__}{$1} );
        }
    }

    return $templ;
}

# ---------------------------------------------------------------------------------------------
#
# load_skins__
#
# Gets the names of all the directory in the skins subdirectory and loads them into the skins
# array.
#
# ---------------------------------------------------------------------------------------------
sub load_skins__
{
    my ( $self ) = @_;

    @{$self->{skins__}} = glob $self->get_root_path_( 'skins/*' );

    for my $i (0..$#{$self->{skins__}}) {
        $self->{skins__}[$i] =~ s/\/$//;
        $self->{skins__}[$i] .= '/';
    }
}

# ---------------------------------------------------------------------------------------------
#
# load_languages__
#
# Get the names of the available languages for the user interface
#
# ---------------------------------------------------------------------------------------------
sub load_languages__
{
    my ( $self ) = @_;

    @{$self->{languages__}} = glob $self->get_root_path_( 'languages/*.msg' );

    for my $i (0..$#{$self->{languages__}}) {
        $self->{languages__}[$i] =~ s/.*\/(.+)\.msg$/$1/;
    }
}

# ---------------------------------------------------------------------------------------------
#
# change_session_key__
#
# Changes the session key, the session key is a randomly chosen 6 to 10 character key that
# protects and identifies sessions with the POPFile user interface.  At the current time
# it is primarily used for two purposes: to prevent a malicious user telling the browser to
# hit a specific URL causing POPFile to do something undesirable (like shutdown) and to
# handle the password mechanism: if the session key is wrong the password challenge is
# made.
#
# The characters valid in the session key are A-Z, a-z and 0-9
#
# ---------------------------------------------------------------------------------------------
sub change_session_key__
{
    my ( $self ) = @_;

    my @chars = ( 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',   # PROFILE BLOCK START
                  'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'U', 'V', 'W', 'X', 'Y',
                  'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A' ); # PROFILE BLOCK STOP

    $self->{session_key__} = '';

    my $length = int( 6 + rand(4) );

    for my $i (0 .. $length) {
        my $random = $chars[int( rand(36) )];

        # Just to add spice to things we sometimes lowercase the value

        if ( rand(1) < rand(1) ) {
            $random = lc($random);
        }

        $self->{session_key__} .= $random;
    }
}

# ---------------------------------------------------------------------------------------------
#
# load_language
#
# Fill the language hash with the language strings that are from the named language file
#
# $lang    - The language to load (no .msg extension)
#
# ---------------------------------------------------------------------------------------------
sub load_language
{
    my ( $self, $lang ) = @_;

    if ( open LANG, '<' . $self->get_root_path_( "languages/$lang.msg" ) ) {
        while ( <LANG> ) {
            next if ( /[ \t]*#/ );

            if ( /([^\t ]+)[ \t]+(.+)/ ) {
                my $id  = $1;
                my $msg = ($self->config_( 'test_language' ))?"<TMPL_VAR name=\"Localize_$1\">":$2;
                $msg =~ s/[\r\n]//g;

                $self->{language__}{$id} = $msg;
            }
        }
        close LANG;
    }
}

# ---------------------------------------------------------------------------------------------
#
# copy_pre_cache__
#
# Copies the history_pre_cache into the history
#
# ---------------------------------------------------------------------------------------------
sub copy_pre_cache__
{
    my ($self) = @_;

    # Copy the history pre-cache over AFTER any possibly index-based remove operations are complete

    my $index = $self->history_size() + 1;
    my $added = 0;
    foreach my $file (sort compare_mf keys %{$self->{history_pre_cache__}} ) {
        $self->{history__}{$file} = $self->{history_pre_cache__}{$file};
        $self->{history__}{$file}{index} = $index;
        $index += 1;
        $added = 1;
        delete $self->{history_pre_cache__}{$file};
        $self->{save_cache__} = 1;
    }

    $self->{history_pre_cache__} = {};
    $self->sort_filter_history( '', '', '' ) if ( $added );
}

# ---------------------------------------------------------------------------------------------
#
# remove_mail_files - Remove old popfile saved mail files
#
# Removes the popfile*.msg files that are older than a number of days configured as
# history_days.
#
# ---------------------------------------------------------------------------------------------
sub remove_mail_files
{
    my ( $self ) = @_;

    opendir MESSAGES, $self->get_user_path_( $self->global_config_( 'msgdir' ) );

    while ( my $mail_file = readdir MESSAGES ) {
        if ( $mail_file =~ /popfile(\d+)=\d+\.msg$/ ) {
            my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat( $self->get_user_path_( $self->global_config_( 'msgdir' ) . $mail_file ) );

            if ( $ctime < (time - $self->config_( 'history_days' ) * $seconds_per_day) )  {
                $self->history_delete_file( $mail_file, $self->config_( 'archive' ) );
                $self->{need_resort__} = 1;
            }
        }
    }

    closedir MESSAGES;

    # Clean up old style msg/cls files

    my @mail_files = glob( $self->get_user_path_( $self->global_config_( 'msgdir' ) . "popfile*_*.???" ) );

    foreach my $mail_file (@mail_files) {
        unlink($mail_file);
    }
}

# ---------------------------------------------------------------------------------------------
#
# calculate_today - set the global $self->{today__} variable to the current day in seconds
#
# ---------------------------------------------------------------------------------------------
sub calculate_today
{
    my ( $self ) = @_;

    $self->{today__} = int( time / $seconds_per_day ) * $seconds_per_day;
}

# ---------------------------------------------------------------------------------------------
#
# history_delete_file   - Handle the deletion of archived message files. Deletes .cls
#                           files related to any .msg file.
#
# $mail_file    - The filename to delete with or without the directory prefix
# $archive      - Boolean, whether or not to save the file as part of an archive
#
# ---------------------------------------------------------------------------------------------
sub history_delete_file
{
    my ( $self, $mail_file, $archive ) = @_;

    $mail_file =~ /(popfile(\d+)\=(\d+)\.msg)$/;
    $mail_file = $1;
    $self->log_( "delete: $mail_file" );

    if ( $archive ) {
        my $path = $self->get_user_path_( $self->config_( 'archive_dir' ) );

        $self->make_directory__( $path );

        my ($reclassified, $bucket, $usedtobe, $magnet) = $self->{classifier__}->history_read_class( $mail_file );

        if ( ( $bucket ne 'unclassified' ) && ( $bucket ne 'unknown class' ) && ( $bucket ne 'unsure' ) ) {
            $path .= "\/" . $bucket;
            $self->make_directory__( $path );

            if ( $self->config_( 'archive_classes' ) > 0) {
                # archive to a random sub-directory of the bucket archive
                my $subdirectory = int( rand( $self->config_( 'archive_classes' ) ) );
                $path .= "\/" . $subdirectory;
                $self->make_directory__( $path );
            }

            # Previous comment about this potentially being unsafe (may have placed messages in
            # unusual places, or overwritten files) no longer applies
            # Files are now placed in the user directory, in the archive_dir subdirectory

            $self->history_copy_file( $self->get_user_path_( $self->global_config_( 'msgdir' ) . "$mail_file" ), $path, $mail_file );
        }
    }

    # Before deleting the file make sure that the appropriate entry in the
    # history cache is also remove

    delete $self->{history__}{$mail_file};

    # Now remove the files from the disk, remove both the msg file containing
    # the mail message and its associated CLS file

    unlink( $self->get_user_path_( $self->global_config_( 'msgdir' ) . $mail_file ) );
    $mail_file =~ s/msg$/cls/;
    unlink( $self->get_user_path_( $self->global_config_( 'msgdir' ) . $mail_file ) );
}

# ---------------------------------------------------------------------------------------------
#
# history_copy_file     - Copies a file to a specified location and filename
#
#   $from       - The source file. May be relative or absolute.
#   $to_dir     - The destination directory. May be relative or absolute.
#                   Will not be created if non-existent.
#   $to_name    - The destination filename.
#
# ---------------------------------------------------------------------------------------------
sub history_copy_file
{
    my ( $self, $from, $to_dir, $to_name ) = @_;

    if ( open( FROM, "<$from") ) {
        if ( open( TO, ">$to_dir\/$to_name") ) {
            binmode FROM;
            binmode TO;

            while (<FROM>) {
                print TO $_;
            }

            close TO;
        }

        close FROM;
    }
}

# ---------------------------------------------------------------------------------------------
#
# print_form_fields_ - Returns a form string containing any presently defined form fields
#
# $first        - 1 if the form field is at the beginning of a query, 0 otherwise
# $in_href      - 1 if the form field is printing in a href, 0 otherwise (eg, for a 302 redirect)
# $include      - a list of fields to return
#
# ---------------------------------------------------------------------------------------------
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
            $formstring .= "session=$self->{session_key__}";
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

# ---------------------------------------------------------------------------------------------
# register_configuration_item__
#
#     $type            The type of item (configuration, security or chain)
#     $name            Unique name for this item
#     $template        The name of the template to load
#     $object          Reference to the object calling this method
#
# This seemingly innocent method disguises a lot.  It is called by modules that wish to
# register that they have specific elements of UI that need to be dynamically added to the
# Configuration and Security screens of POPFile.  This is done so that the HTML module does
# not need to know about the modules that are loaded, their individual configuration elements
# or how to do validation
#
# A module calls this method for each separate UI element (normally an HTML form that handles
# a single configuration option stored in a template) and passes in four pieces of information:
#
# The type is the position in the UI where the element is to be displayed. configuration means
# on the Configuration screen under "Module Options"; security means on the Security page
# and is used exclusively for stealth mode operation right now; chain is also on the security
# page and is used for identifying chain servers (in the case of SMTP the chained server and
# for POP3 the SPA server)
#
# A unique name for this configuration item
#
# The template (this is the name of a template file and must be unique for each call to this
# method)
#
# A reference to itself.
#
# When this module needs to display an element of UI it will call the object's configure_item
# public method passing in the name of the element required, a reference to the loaded template
# and configure_item must set whatever variables are required in the template.
#
# When the module needs to validate it will call the object's validate_item interface passing
# in the name of the element, a reference to the template and a reference to the form
# hash which has been parsed.
#
# Example the module foo has a configuration item called bar which it needs a UI for, and
# so it calls
#
#    register_configuration_item( 'configuration', 'foo', 'foo-bar.thtml', $self )
#
# later it will receive a call to its
#
#    configure_item( 'foo', loaded foo-bar.thtml )
#
# and needs to fill the template variables.  Then it will may receive a call to its
#
#    validate_item( 'foo', loaded foo-bar.thtml, language hash, form hash )
#
# and needs to check the form for information from any form it created and returned from the
# call to configure_item and update its own state.
#
# ---------------------------------------------------------------------------------------------
sub register_configuration_item__
{
   my ( $self, $type, $name, $templ, $object ) = @_;

   $self->{dynamic_ui__}{$type}{$name}{object}   = $object;
   $self->{dynamic_ui__}{$type}{$name}{template} = $templ;
}

# ---------------------------------------------------------------------------------------------
#
# mcount__, ecount__ get the total message count, or the total error count
#
# ---------------------------------------------------------------------------------------------

sub mcount__
{
    my ( $self ) = @_;

    my $count = 0;

    my @buckets = $self->{classifier__}->get_buckets( $self->{api_session__} );

    foreach my $bucket (@buckets) {
        $count += $self->get_bucket_parameter__( $bucket, 'count' );
    }

    return $count;
}

sub ecount__
{
    my ( $self ) = @_;

    my $count = 0;

    my @buckets = $self->{classifier__}->get_buckets( $self->{api_session__} );

    foreach my $bucket (@buckets) {
        $count += $self->get_bucket_parameter__( $bucket, 'fncount' );
    }

    return $count;
}

# ---------------------------------------------------------------------------------------------
#
# make_directory__
#
# Wrapper for mkdir that ensures that the path we are making doesn't end in / or \
# (Done because your can't do mkdir 'foo/' on NextStep.
#
# $path        The directory to make
#
# Returns whatever mkdir returns
#
# ---------------------------------------------------------------------------------------------
sub make_directory__
{
    my ( $self, $path ) = @_;

    $path =~ s/[\\\/]$//;

    return 1 if ( -d $path );
    return mkdir( $path );
}

# ---------------------------------------------------------------------------------------------
#
# get_bucket_parameter__/set_bucket_parameter__
#
# Wrapper for Classifier::Bayes::get_bucket_parameter__ the eliminates the need for all
# our calls to mention $self->{api_session__}
#
# See Classifier::Bayes::get_bucket_parameter for parameters and return values.
#
# (same thing for set_bucket_parameter__)
#
# ---------------------------------------------------------------------------------------------
sub get_bucket_parameter__
{

    # The first parameter is going to be a reference to this class, the
    # rest we leave untouched in @_ and pass to the real API

    my $self = shift;
    my $result = $self->{classifier__}->get_bucket_parameter( $self->{api_session__}, @_ );
    return $result;
}
sub set_bucket_parameter__
{
    my $self = shift;
    return $self->{classifier__}->set_bucket_parameter( $self->{api_session__}, @_ );
}

# GETTERS/SETTERS

sub classifier
{
    my ( $self, $value ) = @_;

    if ( defined( $value ) ) {
        $self->{classifier__} = $value;
    }

    return $self->{classifier__};
}

sub language
{
    my ( $self ) = @_;

    return %{$self->{language__}};
}

sub session_key
{
    my ( $self ) = @_;

    return $self->{session_key__};
}

1;
