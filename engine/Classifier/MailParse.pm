package Classifier::MailParse;

# ---------------------------------------------------------------------------------------------
#
# MailParse.pm --- Parse a mail message or messages into words
#
# ---------------------------------------------------------------------------------------------

use strict;
use warnings;
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
    
    # Internal use for keeping track of a line without touching it
    
    $self->{ut}        = '';
    
    # Specifies the parse mode, 1 means color the output
    
    $self->{color}     = 0;

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
    my ($self, $word, $encoded) = @_;
    
    my $mword = $self->{mangle}->mangle($word);
    
    if ( $mword ne '' ) 
    {
        if ( $self->{color} )
        {
            my $color = $self->{bayes}->get_color($mword);
            if ( $encoded == 0 ) 
            {
                $self->{ut} =~ s/($word)/<b><font color=$color>$1<\/font><\/b>/g;
            }
            else
            {
                $self->{ut} .= "Found in encoded data <font color=$color>$word<\/font>\r\n";
            }
        }
        else
        {
            $self->{words}{$mword} += 1;
            $self->{msg_total}     += 1;

            print "--- $word ($self->{words}{$mword})\n" if ($self->{debug});
        }
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
    my ($self, $line, $encoded) = @_;

    # Pull out any email addresses in the line that are marked with <> and have an @ in them

    while ( $line =~ s/<([A-Za-z0-9\-_]+?@[A-Za-z0-9\-_\.]+?)>// ) 
    {
        update_word($self, $1, $encoded);
    }

    # Grab domain names

    while ( $line =~ s/(([A-Za-z][A-Za-z0-9\-_]+\.){2,})([A-Za-z0-9\-_]+)([^A-Za-z0-9\-_]|$)/$4/ ) 
    {
        update_word($self, "$1$3", $encoded);
    }

    # Grab IP addresses

    while ( $line =~ s/(([12]?\d{1,2}\.){3}[12]?\d{1,2})// ) 
    {
        update_word($self, "$1", $encoded);
    }

    # Only care about words between 3 and 45 characters since short words like
    # an, or, if are too common and the longest word in English (according to
    # the OED) is pneumonoultramicroscopicsilicovolcanoconiosis

    while ( $line =~ s/([A-Za-z][A-Za-z\']{0,44})[-,\.\"\'\)\?!:;\/]{0,5}([ \t\n\r]|$)/ / )
    {
        if (length $1 >= 3)        
        {
            update_word($self,$1, $encoded);
        }
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

    my $content_type = '';

    # Used to return a colorize page
    
    my $colorized = '';

    $self->{words}     = {};
    $self->{msg_total} = 0;

    if ( $self->{color} )
    {
        $colorized .= "<tt>";
    }

    open MSG, "<$file";
    binmode MSG;
    
    # Read each line and find each "word" which we define as a sequence of alpha
    # characters
    
    while (<MSG>)
    {
        my $read = $_;

        # For the Mac we do further splitting of the line at the CR characters
        
        while ( $read =~ s/(.*?[\r\n]+)// ) 
        {
            my $line = $1;
             
            print ">>> $line" if $self->{debug};

            if ( $self->{color} ) 
            {
                if ( $self->{ut} ne '' ) 
                {
                    $colorized .= $self->{ut};
                }

                my $splitline = $line;    
                $splitline =~ s/([^\r\n]{150})/$1\r\n/g;

                $self->{ut} = $splitline;
                $self->{ut} =~ s/</&lt;/g;
                $self->{ut} =~ s/>/&gt;/g;
            }

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
                $self->{ut} = '' if $self->{color};
                while ( ( $line =~ /^([A-Za-z0-9+\/]{4}){1,48}[\n\r]*?$/ ) || ( $line =~ /^[A-Za-z0-9+\/]+=+?[\n\r]*?$/ ) )
                {
                    print "64> $line" if $self->{debug};
                    $decoded    .= un_base64( $self, $line );
                    if ( $decoded =~ /[^A-Za-z\-\.]$/ ) 
                    {
                        if ( $self->{color} )
                        {
                            my $splitline = $line;    
                            $splitline =~ s/([^\r\n]{150})/$1\r\n/g;
                            $self->{ut} = $splitline;
                        }
                        add_line( $self, $decoded, 1 );
                        $decoded = '';
                        if ( $self->{color} ) 
                        {
                            if ( $self->{ut} ne '' ) 
                            {
                                $colorized .= $self->{ut};
                                $self->{ut} = '';
                            }
                        }
                    }
                    $line = <MSG>;
                }

                add_line( $self, $decoded, 1 );
            }

            if ( $line =~ /<html>/i ) 
            {
                $content_type = 'text/html';
            }

            # Transform some escape characters

            if ( $encoding =~ /quoted\-printable/ )
            {
                $line =~ s/=20/ /g;
                $line =~ s/=3D/=/g;
            }

            # Remove HTML tags completely

            if ( $content_type =~ /html/ ) 
            {
                $line =~ s/<[\/!]?[A-Za-z]+[^>]*?>/ /g;
                $line =~ s/<[\/!]?[A-Za-z]+[^>]*?$/ /;
                $line =~ s/^[^>]*?>/ /;
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
                    $content_type = '';
                }

                # Handle the From, To and Cc headers and extract email addresses
                # from them and treat them as words

                if ( $header =~ /(From|To|Cc)/i )
                {
                    while ( $argument =~ s/<([A-Za-z0-9\-_]+?@[A-Za-z0-9\-_\.]+?)>// ) 
                    {
                        update_word($self, $1, 0);
                    }

                    add_line( $self, $argument, 0 );
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
                            $mime =~ s/(\+|\/|\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/\\$1/g;
                        }
                    }

                    $content_type = $argument;
                    next;
                }

                # Look for the different encodings in a MIME document, when we hit base64 we will
                # do a special parse here since words might be broken across the boundaries

                if ( $header =~ /Content-Transfer-Encoding/i )
                {
                    $encoding = $argument;
                    print "Setting encoding to $encoding\n" if $self->{debug};
                    next;
                }

                # Some headers to discard

                if ( $header =~ /(Thread-Index|X-UIDL|Message-ID|X-Text-Classification)/i ) 
                {
                    next;
                }

                add_line( $self, $argument, 0 );
            } else {
                add_line( $self, $line, 0 );
            }
        }
    }

    close MSG;
    
    if ( $self->{color} ) 
    {
        if ( $self->{ut} ne '' ) 
        {
            $colorized .= $self->{ut};
        }

        $colorized .= "</tt>";
        $colorized =~ s/[\r\n]+$//;
        $colorized =~ s/[\r\n]+/__BREAK__/g;
        $colorized =~ s/__BREAK__/<br>/g;
        
        return $colorized;
    }
}

1;
