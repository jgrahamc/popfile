package Classifier::MailParse;

# ---------------------------------------------------------------------------------------------
#
# MailParse.pm --- Parse a mail message or messages into words
#
# ---------------------------------------------------------------------------------------------

use strict;
use Classifier::WordMangle;

#----------------------------------------------------------------------------
# new
#
# Class new() function
#----------------------------------------------------------------------------

sub new
{
    my $type = shift;
    my $self;

    # Used to mangle words into the right shape for classification

    $self->{mangle} = new Classifier::WordMangle;
  
    # Hash of word frequences

    $self->{words}  = {};

    # Total word cout

    $self->{msg_total} = 0;
    
    # Debug messages?

    $self->{debug}     = 0;
    
    return bless $self, $type;
}

# ---------------------------------------------------------------------------------------------
#
# un_base64
#
# Decode a line of base64 encoded data
#
# ---------------------------------------------------------------------------------------------

sub un_base64
{
    my ($self, $line) = @_;
    my $result;
    
    $line =~ s/=+$//; 
    $line =~ tr|A-Za-z0-9+/| -_|;

    $result = join'', map( unpack("u", chr(32 + length($_)*3/4) . $_), $line =~ /(.{1,60})/gs);
    $result =~ s/\x00//g;
    
    return $result;
}

# ---------------------------------------------------------------------------------------------
#
# update_word
#
# Updates the word frequency for a word 
#
# ---------------------------------------------------------------------------------------------

sub update_word
{
    my ($self, $word) = @_;
    
    $word = $self->{mangle}->mangle($word);
    
    if ( $word ne '' ) 
    {
        $self->{words}{$word} += 1;
        $self->{msg_total}    += 1;
        
        print "--- $word ($self->{words}{$word})\n" if ($self->{debug});
    }
}

# ---------------------------------------------------------------------------------------------
#
# add_line
#
# Parses a single line of text and updates the word frequencies
#
# ---------------------------------------------------------------------------------------------

sub add_line
{
    my ($self, $line) = @_;

    # Pull out any email addresses in the line that are marked with <> and have an @ in them

    while ( $line =~ s/<([A-Za-z0-9\-_]+?@[A-Za-z0-9\-_\.]+?)>// ) 
    {
        update_word($self, $1);
    }

    # Grab domain names

    while ( $line =~ s/(([A-Za-z][A-Za-z0-9\-_]+\.){2,})([A-Za-z0-9\-_]+)([^A-Za-z0-9\-_]|$)/\4/ ) 
    {
        update_word($self, "$1$3");
    }

    # Only care about words between 3 and 45 characters since short words like
    # an, or, if are too common and the longest word in English (according to
    # the OED) is pneumonoultramicroscopicsilicovolcanoconiosis

    while ( $line =~ s/([A-Za-z][A-Za-z\']{2,44})[,\.\"\'\)\?!]{0,2}([ \t\n\r]|$)// )
    {
        update_word($self,$1);
    }
}

# ---------------------------------------------------------------------------------------------
#
# parse_stream
#
# Read messages from a file stream and parse into a list of words and frequencies
#
# ---------------------------------------------------------------------------------------------

sub parse_stream
{
    my ($self, $file) = @_;
    
    # This will contain the mime boundary information in a mime message

    my $mime     = '';
    
    # Contains the encoding for the current block in a mime message

    my $encoding = '';

    # Clear the word hash

    $self->{words}     = {};
    $self->{msg_total} = 0;

    open MSG, "<$file";
    
    # Read each line and find each "word" which we define as a sequence of alpha
    # characters
    
    while (<MSG>)
    {
        my $line = $_;
    
        print ">>> $line" if $self->{debug};

        # If we are in a mime document then spot the boundaries

        if ( ( $mime ne '' ) && ( $line =~ /$mime/ ) )
        {
            print "Hit mime boundary\n" if $self->{debug};
            $encoding = '';
            next;
        }
    
        # If we are doing base64 decoding then look for suitable lines and remove them 
        # for decoding
    
        if ( $encoding =~ /base64/i )
        {
            my $decoded = '';
            while ( ( $line =~ /^[A-Za-z0-9+\/]{72}[\n\r]?$/ ) || ( $line =~ /^[A-Za-z0-9+\/]+=?[\n\r]?$/ ) )
            {
                print "64> $line" if $self->{debug};
                $decoded .= un_base64( $self, $line );
                if ( $decoded =~ /[^A-Za-z\-\.]$/ ) 
                {
                    add_line( $self, $decoded );
                    $decoded = '';
                }
                $line = <MSG>;
            }
            
            add_line( $self, $decoded );
        }

        # Remove HTML tags completely
        
        if ( $encoding =~ /quoted\-printable/ ) 
        {
            $line =~ s/=20/ /g;
            $line =~ s/<[\/!]?[A-Za-z]+[^>]*?>//g;
            $line =~ s/<[\/!]?[A-Za-z]+[^>]*?$//;
            $line =~ s/^[\/!]?[A-Za-z]+[^>]*?>//;
        }
        
        # If we have an email header then just keep the part after the :
        
        if ( $line =~ /^([A-Za-z-]+): ([^\n\r]*)/ ) 
        {
            my $header   = $1;
            my $argument = $2;
            
            print "Header ($header) ($argument)\n" if ($self->{debug});

            if ( $header =~ /From/ ) 
            {
                $encoding = '';
            }
            
            # Handle the From, To and Cc headers and extract email addresses
            # from them and treat them as words
            
            if ( $header =~ /(From|To|Cc)/i )
            {
                while ( $argument =~ s/<(.+?)>// ) 
                {
                    update_word($self, $1);
                }
                
                add_line( $self, $argument );
                next;
            }
            
            # Look for MIME
            
            if ( $header =~ /Content-Type/i ) 
            {
                if ( $argument =~ /multipart\//i )
                {
                    my $boundary = $argument;
                    if ( !( $argument =~ /boundary=\"(.*)\"/ ))
                    {
                        $boundary = <MSG>;
                    }

                    if ( $boundary =~ /boundary=\"(.*)\"/ ) 
                    {
                        print "Set mime boundary to $1\n" if $self->{debug};
                        
                        $mime = $1;
                        $mime =~ s/(\+|\/|\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/\\\1/g;
                    }
                }

                next;
            }
            
            # Look for the different encodings in a MIME document, when we hit base64 we will
            # do a special parse here since words might be broken across the boundaries
            
            if ( $header =~ /Content-Transfer-Encoding/i )
            {
                $encoding = $argument;
                next;
            }

            # Some headers to discard

            if ( $header =~ /(Thread-Index|X-UIDL|Message-ID|X-Text-Classification)/i ) 
            {
                next;
            }
            
            add_line( $self, $argument );
        } else {
            add_line( $self, $line );
        }
    }
    
    close MSG;
}

1;
