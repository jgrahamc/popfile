# POPFILE LOADABLE MODULE
package Proxy::NNTP;

use Proxy::Proxy;
@ISA = ("Proxy::Proxy");

# ---------------------------------------------------------------------------------------------
#
# This module handles proxying the NNTP protocol for POPFile.
#
# Copyright (c) 2001-2003 John Graham-Cumming
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

    $self->name( 'nntp' );

    $self->{child_} = \&child__;
    $self->{connection_timeout_error_} = '500 no response from mail server';
    $self->{connection_failed_error_}  = '500 can\'t connect to';
    $self->{good_response_}            = '^(1|2|3)\d\d';

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# initialize
#
# Called to initialize the POP3 proxy module
#
# ---------------------------------------------------------------------------------------------
sub initialize
{
    my ( $self ) = @_;

    # Default ports for POP3 service and the user interface
    $self->config_( 'port', 119 );

    # Only accept connections from the local machine for NNTP
    $self->config_( 'local', 1 );
    
    # The separator within the NNTP user name is :
    $self->config_( 'separator', ':');

    return 1;
}

# ---------------------------------------------------------------------------------------------
#
# child__
#
# The worker method that is called when we get a good connection from a client
#
# $client   - an open stream to a POP3 client
# $download_count - The unique download count for this session
#
# ---------------------------------------------------------------------------------------------
sub child__
{
    my ( $self, $client, $download_count, $pipe ) = @_;

    # Number of messages downloaded in this session
    my $count = 0;

    # The handle to the real news server gets stored here
    my $news;
    
    # The state of the connection (username needed, password needed, authenticated/connected)
    my $connection_state = 'username needed';

    # Tell the client that we are ready for commands and identify our version number
    $self->tee_( $client, "201 NNTP POPFile (vTODO.TODO.TODO) server ready$eol" );

    # Retrieve commands from the client and process them until the client disconnects or
    # we get a specific QUIT command
    while  ( <$client> ) {
        my $command;

        $command = $_;

        # Clean up the command so that it has a nice clean $eol at the end
        $command =~ s/(\015|\012)//g;

        $self->log_( "Command: --$command--" );
        #$self->log_( "State: --$connection_state--" );
        
        
        # The news client wants to stop using the server, so send that message through to the
        # real mail server, echo the response back up to the client and exit the while.  We will
        # close the connection immediately
        if ( $command =~ /^ *QUIT/i ) {
            if ( $news )  {
                $self->echo_response_( $news, $client, $command );
                close $news;
            } else {
                $self->tee_( $client, "205 goodbye$eol" );
            }
            last;
        }        
        
        if ($connection_state eq 'username needed') {
        
            my $user_command = '^ *AUTHINFO USER (.+)(:(\d+))?(' . $self->config_( 'separator' ) . '(.+))?';
            if ( $command =~ /$user_command/i ) { 
                if ( $1 ne '' )  {
                    if ( $news = $self->verify_connected_( $news, $client, $1, $3 || 119 ) )  {
                                                
                        if (defined $5) {
                            # Pass through the AUTHINFO command with the actual user name for this server,
                            # if one is defined, and send the reply straight to the client
                            $self->echo_response_($news, $client, 'AUTHINFO USER ' . $5 );
                            $connection_state = "password needed";
                        } else {
                            # Signal to the client to send the password
                            $self->tee_($client, "381 password$eol"); 
                            $connection_state = "ignore password";
                        }
                        
                       
                                                
                    } else {
                        last;
                    }
                } else {
                    $self->tee_( $client, "482 Authentication rejected server name not specified in AUTHINFO USER command$eol" );
                    last;
                }
    
                $self->flush_extra_( $news, $client, 0 );
                next;
            } else {
                # Issue a 480 authentication required response
                
                $self->tee_( $client, "480 Authorization required for this command$eol" );
                next;
            }
            
        } elsif ( $connection_state eq "password needed" ) {
                                    
            if ($command =~ /^ *AUTHINFO PASS (.*)/i) {
                
                my $response = $self->echo_response_($news, $client, $command);
                $self->tee_($client,$response);
                
                if ($response =~ /^281 .*/) {
                    $connection_state = "connected"                                        
                }
                                                                
                next;                
            } else {
                
                # Issue a 381 more authentication required response
                
                $self->tee_( $client, "381 more authentication required for this command$eol" );
                next;
            }            
        } elsif ($connection_state eq "ignore password") {
            if ($command =~ /^ *AUTHINFO PASS (.*)/i) {
                
                $self->tee_($client, "281 authentication accepted$eol");
                $connection_state = "connected";
                next;                 
            } else {
                
                # Issue a 480 authentication required response
                
                $self->tee_( $client, "381 more authentication required for this command$eol" );
                next;
            }
        } elsif ( $connection_state eq "connected" ) {
            
            # COMMANDS USED DIRECTLY WITH THE REMOTE NNTP SERVER GO HERE
            
            # The client wants to retrieve an article. We oblige, and insert classification headers.
            if ( $command =~ /^ *ARTICLE (.*)/i ) {
                my $response = $self->get_response_( $news, $client, $command);
                if ( $response =~ /^220 (.*) (.*)$/i) {
                    
                    $count += 1;
                    my $class = $self->{classifier__}->classify_and_modify( $news, $client, $download_count, $count, 0, '' );
    
                    # Tell the parent that we just handled a mail
                    print $pipe "$class$eol";                 
                }
                
                $self->flush_extra_( $news, $client, 0 );                                        
                next;
            }
            
            # Commands expecting a code + text response
            if ( $command =~ /^ *(LIST|HEAD|BODY|NEWSGROUPS|NEWNEWS|LISTGROUP|XGTITLE|XINDEX|XHDR|XOVER|XPAT|XROVER|XTHREAD)/i ) {                
                my $response = $self->get_response_( $news, $client, $command);
                
                # 2xx (200) series response indicates multi-line text follows to .crlf
                
                $self->echo_to_dot_( $news, $client, 0 ) if ($response =~ /^2\d\d/ );
                               
                $self->flush_extra_( $news, $client, 0 );
                next;
            }
            
            # Exceptions to 200 code above
            if ( $ command =~ /^ *(HELP)/i ) {
                my $response = $self->get_response_( $news, $client, $command);
                
                $self->echo_to_dot_( $news, $client, 0 ) if ( $response =~ /^1\d\d/ );
                
                $self->flush_extra_( $news, $client, 0 );
                next;
            }
            
            
            # Commands expecting a single-line response
            if ( $command =~ /^ *(GROUP|STAT|IHAVE|LAST|NEXT|SLAVE|MODE|XPATH)/i ) {
                $self->get_response_( $news, $client, $command );
                $self->flush_extra_( $news, $client, 0 );
                next;
            }
            
            # Commands followed by multi-line client response
            if ( $command =~ /^ *(IHAVE|POST|XRELPIC)/i ) {
                my $response = $self->get_response_( $news, $client, $command);
                
                # 3xx (300) series response indicates multi-line text should be sent, up to .crlf
                if ($response =~ /^3\d\d/ ) {
                    $self->echo_to_dot_( $client, $news, 0 );
                    
                    # Echo to dot consumes the dot. We recreate it.
                    
                    $self->get_response_( $news, $client, ".$eol" );
                                    
                    # The client may have some cruft after the .crlf,
                    # the server will respond, the client may(?) echo something back                
                    $self->flush_extra_( $client, $news, 0 );
                    $self->flush_extra_( $news, $client, 0 );
                    $self->flush_extra_( $client, $news, 0 );
                }
                
                next;                
            }
            
            
        }
        
        # Commands we expect no response to, such as the null command
        
        if ( $ command =~ /^ *$/ ) {            
            if ( $news && $news->connected ) {
                $self->get_response_($news, $client, $command, '',1);
                $self->flush_extra_( $news, $client, 0 );
                next;               
            }                        
        }
        

        # Don't know what this is so let's just pass it through and hope for the best
        if ( $news && $news->connected)  {
            $self->echo_response_($news, $client, $command );
            $self->flush_extra_( $news, $client, 0 );
            next;
        } else {
            $self->tee_(  $client, "-ERR unknown command or bad syntax$eol" );
            last;
        }
    }

    close $news if defined( $news );
    close $client;
    close $pipe;

    $self->log_( "NNTP forked child done" );
}

# TODO echo_response_ that calls echo_response_ with the extra parameters
# required et al.
