# POPFILE LOADABLE MODULE
package UI::XMLRPC;

#----------------------------------------------------------------------------
#
# This package contains the XML-RPC interface for POPFile, all the methods
# in Classifier::Bayes can be accessed through the XMLRPC interface and
# a typical method would be accessed as follows
#
#     Classifier/Bayes.get_buckets
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
#   Modified by     Sam Schinke (sschinke@users.sourceforge.net)
#
#----------------------------------------------------------------------------

use POPFile::Module;
@ISA = ("POPFile::Module");

use POPFile::API;

use strict;
use warnings;
use locale;

use IO::Socket;
use IO::Select;

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

    bless $self, $type;;

    $self->name( 'xmlrpc' );

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

    # By default we are disabled

    $self->config_( 'enabled', 0 );

    # XML-RPC is available on port 8081 initially

    $self->config_( 'port', 8081 );

    # Only accept connections from the local machine

    $self->config_( 'local', 1 );

    $self->{api__} = new POPFile::API;

    return 1;
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

    if ( $self->config_( 'enabled' ) == 0 ) {
        return 2;
    }

    require XMLRPC::Transport::HTTP;

    # Tell the user interface module that we having a configuration
    # item that needs a UI component

    $self->register_configuration_item_( 'configuration',   # PROFILE BLOCK START
                                         'xmlrpc_port',
                                         $self );           # PROFILE BLOCK STOP

    $self->register_configuration_item_( 'security',        # PROFILE BLOCK START
                                         'xmlrpc_local',
                                          $self );          # PROFILE BLOCK STOP

    # We use a single XMLRPC::Lite object to handle requests for access to the
    # Classifier::Bayes object

    $self->{server__} = XMLRPC::Transport::HTTP::Daemon->new(   # PROFILE BLOCK START
                                     Proto     => 'tcp',
                                     $self->config_( 'local' )  == 1 ? (LocalAddr => 'localhost') : (),
                                     LocalPort => $self->config_( 'port' ),
                                     Listen    => SOMAXCONN,
                                     Reuse     => 1 );          # PROFILE BLOCK STOP

    if ( !defined( $self->{server__} ) ) {
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

    # All requests will get dispatched to the main Classifier::Bayes object, for example
    # the get_bucket_color interface is accessed with the method name.  The actual
    # dispatch is via the POPFile::API object which we create in initialize above.
    #
    #     POPFile/API.get_bucket_color

    $self->{api__}->{c} = $self->{classifier__};
    $self->{server__}->dispatch_to( $self->{api__} );

    # DANGER WILL ROBINSON!  In order to make a polling XML-RPC server I am using
    # the XMLRPC::Transport::HTTP::Daemon class which uses blocking I/O.  This would
    # be all very well but it seems to be totally ignorning signals on Windows and so
    # POPFile is unstoppable when the handle() method is called.  Forking with this
    # blocking doesn't help much because then we get an unstoppable child.
    #
    # So the solution relies on knowing the internals of XMLRPC::Transport::HTTP::Daemon
    # which is actually a SOAP::Transport::HTTP::Daemon which has a HTTP::Daemon (stored
    # in a private variable called _daemon.  HTTP::Daemon is an IO::Socket::INET which means
    # we can create a selector on it, so here we access a PRIVATE variable on the XMLRPC
    # object.  This is very bad behaviour, but it works until someone changes XMLRPC.

    $self->{selector__} = new IO::Select( $self->{server__}->{_daemon} );

    return 1;
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

    # See if there's a connection pending on the XMLRPC socket and handle
    # single request

    my ( $ready ) = $self->{selector__}->can_read(0);

    if ( defined( $ready ) ) {
        if ( my $client = $self->{server__}->accept() ) {

            # Check that this is a connection from the local machine, if it's not then we drop it immediately
            # without any further processing.  We don't want to allow remote users to admin POPFile

            my ( $remote_port, $remote_host ) = sockaddr_in( $client->peername() );

            if ( ( $self->config_( 'local' ) == 0 ) ||              # PROFILE BLOCK START
                 ( $remote_host eq inet_aton( "127.0.0.1" ) ) ) {   # PROFILE BLOCK STOP
                my $request = $client->get_request();

                # Note that handle() relies on the $request being perfectly valid, so here we
                # check that it is, if it is not then we don't want to call handle and we'll
                # return out own error

                if ( defined( $request ) ) {
                    $self->{server__}->request( $request );

                    # Note the direct call to SOAP::Transport::HTTP::Server::handle() here, this is
                    # because we have taken the code from XMLRPC::Transport::HTTP::Server::handle()
                    # and reproduced a modification of it here, accepting a single request and handling
                    # it.  This call to the parent of XMLRPC::Transport::HTTP::Server will actually
                    # deal with the request

                    $self->{server__}->SOAP::Transport::HTTP::Server::handle();
                    $client->send_response( $self->{server__}->response );
		}
                $client->close();
            }
        }
    }

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# configure_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $language        Reference to the hash holding the current language
#    $session_key     The current session key
#
#  Must return the HTML for this item
# ---------------------------------------------------------------------------------------------

sub configure_item
{
    my ( $self, $name, $language, $session_key ) = @_;

    my $body;

    if ( $name eq 'xmlrpc_port' ) {
        $body .= "<form action=\"/configuration\">\n";
        $body .= "<label class=\"configurationLabel\" for=\"configPopPort\">". $$language{Configuration_XMLRPCPort} . ":</label><br />\n";
        $body .= "<input name=\"xmlrpc_port\" type=\"text\" id=\"configPopPort\" value=\"" . $self->config_( 'port' ) . "\" />\n";
        $body .= "<input type=\"submit\" class=\"submit\" name=\"update_xmlrpc_port\" value=\"" . $$language{Apply} . "\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
    }

    if ( $name eq 'xmlrpc_local' ) {
        $body .= "<span class=\"securityLabel\">$$language{Security_XMLRPC}:</span><br />\n";

        $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td nowrap=\"nowrap\">\n";
        if ( $self->config_( 'local' ) == 1 ) {
            $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
            $body .= "<span class=\"securityWidgetStateOff\">$$language{Security_NoStealthMode}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"securityAcceptPOP3On\" name=\"toggle\" value=\"$$language{ChangeToYes}\" />\n";
            $body .= "<input type=\"hidden\" name=\"xmlrpc_local\" value=\"1\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        } else {
            $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
            $body .= "<span class=\"securityWidgetStateOn\">$$language{Yes}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"securityAcceptPOP3Off\" name=\"toggle\" value=\"$$language{ChangeToNo} (Stealth Mode)\" />\n";
            $body .= "<input type=\"hidden\" name=\"xmlrpc_local\" value=\"2\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        }
        $body .= "</td></tr></table>\n";
     }

    return $body;
}

# ---------------------------------------------------------------------------------------------
#
# validate_item
#
#    $name            The name of the item being configured, was passed in by the call
#                     to register_configuration_item
#    $language        Reference to the hash holding the current language
#    $form            Hash containing all form items
#
#  Must return the HTML for this item
# ---------------------------------------------------------------------------------------------

sub validate_item
{
    my ( $self, $name, $language, $form ) = @_;

    # Just check to see if the XML rpc port was change and check its value

    if ( $name eq 'xmlrpc_port' ) {
        if ( defined($$form{xmlrpc_port}) ) {
            if ( ( $$form{xmlrpc_port} >= 1 ) && ( $$form{xmlrpc_port} < 65536 ) ) {
                $self->config_( 'port', $$form{xmlrpc_port} );
                return '<blockquote>' . sprintf( $$language{Configuration_XMLRPCUpdate} . '</blockquote>' , $self->config_( 'port' ) );
            } else {
                 return "<blockquote><div class=\"error01\">$$language{Configuration_Error7}</div></blockquote>";
            }
        }
    }

    if ( $name eq 'xmlrpc_local' ) {
        $self->config_( 'local', $$form{xmlrpc_local}-1 ) if ( defined($$form{xmlrpc_local}) );
    }

    return '';
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

1;

