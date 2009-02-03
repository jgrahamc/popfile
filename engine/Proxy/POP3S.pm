# POPFILE LOADABLE MODULE 4
package Proxy::POP3S;

use Proxy::Proxy;
use Proxy::POP3;
use Digest::MD5;
@ISA = ("Proxy::Proxy");
#@ISA = ("Proxy::POP3");

# ----------------------------------------------------------------------------
#
# This module handles proxying the POP3 protocol for POPFile.
#
# Copyright (c) 2001-2009 John Graham-Cumming
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
#   Modified by     Sam Schinke (sschinke@users.sourceforge.net)
#
# ----------------------------------------------------------------------------

use strict;
use warnings;
use locale;

# A handy variable containing the value of an EOL for networks
my $eol = "\015\012";

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;
    my $self = Proxy::Proxy->new();

    # Must call bless before attempting to call any methods

    bless $self, $type;

    $self->name( 'pop3s' );

    $self->{child_} = \&child__;
    $self->{connection_timeout_error_} = '-ERR no response from mail server';
    $self->{connection_failed_error_}  = '-ERR can\'t connect to';
    $self->{good_response_}            = '^\+OK';

    # Client requested APOP
    $self->{use_apop__} = 0;

    # APOP username
    $self->{apop_user__} = '';

    # The APOP portion of the banner sent by the POP3 server
    $self->{apop_banner__} = undef;


    return $self;
}

# ----------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the POP3 proxy module
#
# ----------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    # By default we don't fork on Windows
    $self->config_( 'force_fork', ($^O eq 'MSWin32')?0:1 );

    # Default port for POP3S service
    $self->config_( 'port', 995 );

    # Only accept connections from the local machine for POP3S
    $self->config_( 'local', 1 );

    # The welcome string from the proxy is configurable
    $self->config_( 'welcome_string',                       # PROFILE BLOCK START
        "POP3S POPFile ($self->{version_}) server ready" ); # PROFILE BLOCK STOP

    if ( !$self->SUPER::initialize() ) {
        return 0;
    }

    # Disabled by default
    $self->config_( 'enabled', 0 );

    return 1;
}

# ----------------------------------------------------------------------------
#
# start
#
# ----------------------------------------------------------------------------
sub start
{
    my ( $self ) = @_;

    # If we are not enabled then no further work happens in this module

    if ( $self->config_( 'enabled' ) == 0 ) {
        return 2;
    }

    # Tell the user interface module that we having a configuration
    # item that needs a UI component

    $self->register_configuration_item_( 'configuration',              # PROFILE BLOCK START
                                         'pop3s_configuration',
                                         'pop3s-configuration-panel.thtml',
                                         $self );                      # PROFILE BLOCK STOP

    $self->register_configuration_item_( 'security',                   # PROFILE BLOCK START
                                         'pop3s_security',
                                         'pop3s-security-panel.thtml',
                                         $self );                      # PROFILE BLOCK STOP

    return $self->SUPER::start();
}

# ----------------------------------------------------------------------------
#
# child__
#
# The worker method that is called when we get a good connection from
# a client
#
# $client         - an open stream to a POP3 client
# $admin_session  - administrator session
#
# ----------------------------------------------------------------------------
sub child__
{
    my ( $self, $client, $admin_session ) = @_;

    return Proxy::POP3::child__( $self, $client, $admin_session );
}

# ----------------------------------------------------------------------------
#
# configure_item
#
#    $name            Name of this item
#    $templ           The loaded template that was passed as a parameter
#                     when registering
#    $language        Current language
#
# Returns 1 if pop3_local is 1
#
# ----------------------------------------------------------------------------

sub configure_item
{
    my ( $self, $name, $templ, $language ) = @_;

    if ( $name eq 'pop3s_configuration' ) {
        $templ->param( 'POP3S_Configuration_If_Force_Fork' => ( $self->config_( 'force_fork' ) == 1 ) );
        $templ->param( 'POP3S_Configuration_Port'          => $self->config_( 'port' ) );
    } else {
        if ( $name eq 'pop3s_security' ) {
            $templ->param( 'POP3S_Security_Local' => ( $self->config_( 'local' ) == 1 ) );
            return ( $self->config_( 'local' ) == 1 );
        } else {
            $self->SUPER::configure_item( $name, $templ, $language );
        }
    }
}

# ----------------------------------------------------------------------------
#
# validate_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $templ           The loaded template
#    $language        The language currently in use
#    $form            Hash containing all form items
#
# ----------------------------------------------------------------------------

sub validate_item
{
    my ( $self, $name, $templ, $language, $form ) = @_;

    my ( $status_message , $error_message );

    if ( $name eq 'pop3s_configuration' ) {
        if ( defined($$form{pop3s_port}) ) {
            if ( $self->is_valid_port_( $$form{pop3s_port} ) ) {
                if ( $self->config_( 'port') ne $$form{pop3s_port} ) {
                    $self->config_( 'port', $$form{pop3s_port} );
                    $status_message .= sprintf(                # PROFILE BLOCK START
                            $$language{Configuration_POP3SUpdate},
                            $self->config_( 'port' ) ) . "\n"; # PROFILE BLOCK STOP
                }
            } else {
                $error_message .= $$language{Configuration_Error3} . "\n";
            }
        }

        if ( defined($$form{update_pop3s_configuration}) ) {
            if ( $$form{pop3s_force_fork} ) {
                if ( $self->config_( 'force_fork' ) ne 1 ) {
                    $self->config_( 'force_fork', 1 );
                    $status_message .= $$language{Configuration_POP3SForkEnabled};
                }
            } else {
                if ( $self->config_( 'force_fork' ) ne 0 ) {
                    $self->config_( 'force_fork', 0 );
                    $status_message .= $$language{Configuration_POP3SForkDisabled};
                }
            }
        }

        return( $status_message, $error_message );
    }

    if ( $name eq 'pop3s_security' ) {
        if ( $$form{serveropt_pop3s} ) {
            if ( $self->config_( 'local' ) ne 0 ) {
                $self->config_( 'local', 0 );
                $status_message = $$language{Security_ServerModeUpdatePOP3S};
            }
        }
        else {
            if ( $self->config_( 'local' ) ne 1 ) {
                $self->config_( 'local', 1 );
                $status_message = $$language{Security_StealthModeUpdatePOP3S};
            }
        }

        return( $status_message, $error_message );
    }

    return $self->SUPER::validate_item( $name, $templ, $language, $form );
}

1;
