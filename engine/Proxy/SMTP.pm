# POPFILE LOADABLE MODULE
package Proxy::SMTP;

use Proxy::Proxy;
@ISA = ("Proxy::Proxy");

# ---------------------------------------------------------------------------------------------
#
# This module handles proxying the SMTP protocol for POPFile.
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
# ---------------------------------------------------------------------------------------------

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

    $self->name( 'smtp' );

    $self->{child_} = \&child__;
    $self->{connection_timeout_error_} = '554 Transaction failed';
    $self->{connection_failed_error_}  = '554 Transaction failed, can\'t connect to';
    $self->{good_response_}            = '^[23]';

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the SMTP proxy module
#
# ---------------------------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    # By default we don't fork on Windows
    $self->config_( 'force_fork', ($^O eq 'MSWin32')?0:1 );

    # Default port for SMTP service
    $self->config_( 'port', 25 );

    # Where to forward on to
    $self->config_( 'chain_server', '' );
    $self->config_( 'chain_port', 25 );

    # Only accept connections from the local machine for smtp
    $self->config_( 'local', 1 );

    # The welcome string from the proxy is configurable
    $self->config_( 'welcome_string', "SMTP POPFile ($self->{version_}) welcome" );

    # Tell the user interface module that we having a configuration
    # item that needs a UI component

    $self->register_configuration_item_( 'configuration',
                                         'smtp_port',
                                         $self );

    $self->register_configuration_item_( 'configuration',              # PROFILE BLOCK START
                                         'smtp_force_fork',
                                         $self );                      # PROFILE BLOCK STOP

    $self->register_configuration_item_( 'security',
                                         'smtp_local',
                                         $self );

    $self->register_configuration_item_( 'chain',
                                         'smtp_server',
                                         $self );

    $self->register_configuration_item_( 'chain',
                                         'smtp_server_port',
                                          $self );

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# child__
#
# The worker method that is called when we get a good connection from a client
#
# $client   - an open stream to a SMTP client
# $download_count - The unique download count for this session
#
# ---------------------------------------------------------------------------------------------
sub child__
{
    my ( $self, $client, $download_count, $pipe, $ppipe, $pid ) = @_;

    # Number of messages downloaded in this session
    my $count = 0;

    # The handle to the real mail server gets stored here
    my $mail;

    # Tell the client that we are ready for commands and identify our version number
    $self->tee_( $client, "220 " . $self->config_( 'welcome_string' ) . "$eol" );

    # Retrieve commands from the client and process them until the client disconnects or
    # we get a specific QUIT command
    while  ( <$client> ) {
        my $command;

        $command = $_;

        # Clean up the command so that it has a nice clean $eol at the end
        $command =~ s/(\015|\012)//g;

        $self->log_( "Command: --$command--" );

        if ( $command =~ /HELO/i ) {
            if ( $self->config_( 'chain_server' ) )  {
                if ( $mail = $self->verify_connected_( $mail, $client, $self->config_( 'chain_server' ),  $self->config_( 'chain_port' ) ) )  {

                    $self->smtp_echo_response_( $mail, $client, $command );


                } else {
                    last;
                }
            } else {
                $self->tee_(  $client, "421 service not available$eol" );
            }

            next;
        }
        
        # Handle EHLO specially so we can control what ESMTP extensions are negotiated
        
        if ( $command =~ /EHLO/i ) {
            if ( $self->config_( 'chain_server' ) )  {
                if ( $mail = $self->verify_connected_( $mail, $client, $self->config_( 'chain_server' ),  $self->config_( 'chain_port' ) ) )  {

                    # TODO: Make this user-configurable (-smtp_add_unsupported, -smtp_remove_unsupported)

                    # Stores a list of unsupported ESMTP extensions

                    my $unsupported;

                    
                    
                    # RFC 1830, http://www.faqs.org/rfcs/rfc1830.html
                    # CHUNKING and BINARYMIME both require the support of the "BDAT" command
                    # support of BDAT requires extensive changes to POPFile's internals and
                    # will not be implemented at this time

                    $unsupported .= "CHUNKING|BINARYMIME";
                    
                    # append unsupported ESMTP extensions to $unsupported here, important to maintain
                    # format of OPTION|OPTION2|OPTION3
                    
                    $unsupported = qr/250\-$unsupported/;
                                        
                    $self->smtp_echo_response_( $mail, $client, $command, $unsupported );


                } else {
                    last;
                }
            } else {
                $self->tee_(  $client, "421 service not available$eol" );
            }

            next;
        }

        if ( ( $command =~ /MAIL FROM:/i )    ||
             ( $command =~ /RCPT TO:/i )      ||
             ( $command =~ /VRFY/i )          ||
             ( $command =~ /EXPN/i )          ||
             ( $command =~ /NOOP/i )          ||
             ( $command =~ /HELP/i )          ||
             ( $command =~ /RSET/i ) ) {
            $self->smtp_echo_response_( $mail, $client, $command );
            next;
        }

        if ( $command =~ /DATA/i ) {
            # Get the message from the remote server, if there's an error then we're done, but if not then
            # we echo each line of the message until we hit the . at the end
            if ( $self->smtp_echo_response_( $mail, $client, $command ) ) {
                $count += 1;

                my ( $class, $history_file ) = $self->{classifier__}->classify_and_modify( $client, $mail, $download_count, $count, 0, '' );

                # Tell the parent that we just handled a mail
                print $pipe "CLASS:$class$eol";
                print $pipe "NEWFL:$history_file$eol";
                flush $pipe;
                $self->yield_( $ppipe, $pid );

                my $response = <$mail>;
                $self->tee_( $client, $response );
                next;
            }
        }

        # The mail client wants to stop using the server, so send that message through to the
        # real mail server, echo the response back up to the client and exit the while.  We will
        # close the connection immediately
        if ( $command =~ /QUIT/i ) {
            if ( $mail )  {
                $self->smtp_echo_response_( $mail, $client, $command );
                close $mail;
            } else {
                $self->tee_(  $client, "221 goodbye$eol" );
            }
            last;
        }

        # Don't know what this is so let's just pass it through and hope for the best
        if ( $mail && $mail->connected )  {
            $self->smtp_echo_response_( $mail, $client, $command );
            next;
        } else {
            $self->tee_(  $client, "500 unknown command or bad syntax$eol" );
            last;
        }
    }

    close $mail if defined( $mail );
    close $client;
    print $pipe "CMPLT$eol";
    flush $pipe;
    $self->yield_( $ppipe, $pid );
    close $pipe;
}

# ---------------------------------------------------------------------------------------------
#
# smtp_echo_response_
#
# $mail     The stream (created with IO::) to send the message to (the remote mail server)
# $client   The local mail client (created with IO::) that needs the response
# $command  The text of the command to send (we add an EOL)
# $suppress (OPTIONAL) suppress any lines that match, compile using qr/pattern/
#
# Send $command to $mail, receives the response and echoes it to the $client and the debug
# output.
#
# This subroutine returns responses from the server as defined in appendix E of
# RFC 821, allowing multi-line SMTP responses.
#
# Returns true if the initial response is a 2xx or 3xx series (as defined by {good_response_}
#
# ---------------------------------------------------------------------------------------------
sub smtp_echo_response_
{
    my ($self, $mail, $client, $command, $suppress) = @_;
    my $response = $self->get_response_( $mail, $client, $command );

    if ( $response =~ /^\d\d\d-/ ) {
        $self->echo_to_regexp_($mail, $client, qr/^\d\d\d /, 1, $suppress);
    }
    return ( $response =~ /$self->{good_response_}/ );
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

    if ( $name eq 'smtp_port' ) {
        $body .= "<form action=\"/configuration\">\n";
        $body .= "<label class=\"configurationLabel\" for=\"configPopPort\">$$language{Configuration_SMTPPort}:</label><br />\n";
        $body .= "<input name=\"smtp_port\" type=\"text\" id=\"configPopPort\" value=\"" . $self->config_( 'port' ) . "\" />\n";
        $body .= "<input type=\"submit\" class=\"submit\" name=\"update_smtp_port\" value=\"$$language{Apply}\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
    }

    if ( $name eq 'smtp_local' ) {
        $body .= "<span class=\"securityLabel\">$$language{Security_SMTP}:</span><br />\n";

        $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td nowrap=\"nowrap\">\n";
        if ( $self->config_( 'local' ) == 1 ) {
            $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
            $body .= "<span class=\"securityWidgetStateOff\">$$language{Security_NoStealthMode}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"securityAcceptPOP3On\" name=\"toggle\" value=\"$$language{ChangeToYes}\" />\n";
            $body .= "<input type=\"hidden\" name=\"smtp_local\" value=\"1\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        } else {
            $body .= "<form class=\"securitySwitch\" action=\"/security\">\n";
            $body .= "<span class=\"securityWidgetStateOn\">$$language{Yes}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOff\" id=\"securityAcceptPOP3Off\" name=\"toggle\" value=\"$$language{ChangeToNo} (Stealth Mode)\" />\n";
            $body .= "<input type=\"hidden\" name=\"smtp_local\" value=\"2\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        }
        $body .= "</td></tr></table>\n";
     }

    if ( $name eq 'smtp_server' ) {
        $body .= "<form action=\"/security\">\n";
        $body .= "<label class=\"securityLabel\" for=\"securitySecureServer\">$$language{Security_SMTPServer}:</label><br />\n";
        $body .= "<input type=\"text\" name=\"smtp_chain_server\" id=\"securitySecureServer\" value=\"" . $self->config_( 'chain_server' ) . "\" />\n";
        $body .= "<input type=\"submit\" class=\"submit\" name=\"update_smtp_server\" value=\"$$language{Apply}\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
    }

    if ( $name eq 'smtp_server_port' ) {
        $body .= "<form action=\"/security\">\n";
        $body .= "<label class=\"securityLabel\" for=\"securitySecurePort\">$$language{Security_SMTPPort}:</label><br />\n";
        $body .= "<input type=\"text\" name=\"smtp_chain_server_port\" id=\"securitySecurePort\" value=\"" . $self->config_( 'chain_port' ) . "\" />\n";
        $body .= "<input type=\"submit\" class=\"submit\" name=\"update_smtp_server_port\" value=\"$$language{Apply}\" />\n";
        $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
    }

    if ( $name eq 'smtp_force_fork' ) {
        $body .= "<span class=\"configurationLabel\">$$language{Configuration_SMTPFork}:</span><br />\n";
        $body .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"\"><tr><td nowrap=\"nowrap\">\n";

        if ( $self->config_( 'force_fork' ) == 0 ) {
            $body .= "<form action=\"/configuration\">\n";
            $body .= "<span class=\"securityWidgetStateOff\">$$language{No}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"windowTrayIconOn\" name=\"toggle\" value=\"$$language{ChangeToYes}\" />\n";
            $body .= "<input type=\"hidden\" name=\"smtp_force_fork\" value=\"1\" />\n";
            $body .= "<input type=\"hidden\" name=\"session\" value=\"$session_key\" />\n</form>\n";
        } else {
            $body .= "<form action=\"/configuration\">\n";
            $body .= "<span class=\"securityWidgetStateOn\">$$language{Yes}</span>\n";
            $body .= "<input type=\"submit\" class=\"toggleOn\" id=\"windowTrayIconOff\" name=\"toggle\" value=\"$$language{ChangeToNo}\" />\n";
            $body .= "<input type=\"hidden\" name=\"smtp_force_fork\" value=\"0\" />\n";
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

    if ( $name eq 'smtp_port' ) {
        if ( defined($$form{smtp_port}) ) {
            if ( ( $$form{smtp_port} >= 1 ) && ( $$form{smtp_port} < 65536 ) ) {
                $self->config_( 'port', $$form{smtp_port} );
                return '<blockquote>' . sprintf( $$language{Configuration_POP3Update} . '</blockquote>' , $self->config_( 'port' ) );
             } else {
                 return "<blockquote><div class=\"error01\">$$language{Configuration_Error3}</div></blockquote>";
             }
        }
    }

    if ( $name eq 'smtp_local' ) {
        $self->config_( 'local', $$form{smtp_local}-1 ) if ( defined($$form{smtp_local}) );
    }

    if ( $name eq 'smtp_server' ) {
         $self->config_( 'chain_server', $$form{smtp_chain_server} ) if ( defined($$form{smtp_chain_server}) );
         return sprintf( "<blockquote>" . $$language{Security_SMTPServerUpdate} . "</blockquote>", $self->config_( 'chain_server' ) ) if ( defined($$form{smtp_chain_server}) );
    }

    if ( $name eq 'smtp_server_port' ) {
        if ( defined($$form{smtp_chain_server_port}) ) {
            if ( ( $$form{smtp_chain_server_port} >= 1 ) && ( $$form{smtp_chain_server_port} < 65536 ) ) {
                $self->config_( 'chain_port', $$form{smtp_chain_server_port} );
                return sprintf( "<blockquote>" . $$language{Security_SMTPPortUpdate} . "</blockquote>", $self->config_( 'chain_port' ) ) if ( defined($$form{smtp_chain_chain_port}) );
            } else {
                return "<blockquote><div class=\"error01\">$$language{Security_Error1}</div></blockquote>";
            }
        }
    }

    if ( $name eq 'smtp_force_fork' ) {
        if ( defined($$form{smtp_force_fork}) ) {
            $self->config_( 'force_fork', $$form{smtp_force_fork} );
        }
    }

    return '';
}

1;
