package Classifier::MailParse;

# ---------------------------------------------------------------------------------------------
#
# MailParse.pm --- Parse a mail message or messages into words
#
# ---------------------------------------------------------------------------------------------

use strict;
use warnings;
use locale;
use Classifier::WordMangle;

# HTML entity mapping to character codes, this maps things like &amp; to their corresponding
# character code

my %entityhash;

@entityhash{"nbsp","iexcl","cent","pound","curren","yen","brvbar","sect","uml","copy","ordf","laquo","not","shy","reg","macr","deg","plusmn","sup2","sup3","acute","micro","para","middot","cedil","sup1","ordm","raquo","frac14","frac12","frac34","iquest","Agrave","Aacute","Acirc","Atilde","Auml","Aring","AElig","Ccedil","Egrave","Eacute","Ecirc","Euml","Igrave","Iacute","Icirc","Iuml","ETH","Ntilde","Ograve","Oacute","Ocirc","Otilde","Ouml","times","Oslash","Ugrave","Uacute","Ucirc","Uuml","Yacute","THORN","szlig","agrave","aacute","acirc","atilde","auml","aring","aelig","ccedil","egrave","eacute","ecirc","euml","igrave","iacute","icirc","iuml","eth","ntilde","ograve","oacute","ocirc","otilde","ouml","divide","oslash","ugrave","uacute","ucirc","uuml","yacute","thorn","yuml"} = ( 160,161,162,163,164,165,166,167,168,169,170,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255 );        

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
    
    # This will store the from, to and subject from the last parse
    
    $self->{from}      = '';
    $self->{to}        = '';
    $self->{subject}   = '';
    
    return bless $self, $type;
}

# ---------------------------------------------------------------------------------------------
#
# un_base64
#
# Decode a line of base64 encoded data
#
# $line     A line of base64 encoded data
#
# ---------------------------------------------------------------------------------------------
sub un_base64 
{
    my ($self, $line) = @_;
    my $result;
    
    $line =~ s/=+$//; 
    $line =~ s/[\r\n]//g; 
    $line =~ tr|A-Za-z0-9+/| -_|;

    $result = join'', map( unpack("u", chr(32 + length($_)*3/4) . $_), $line =~ /(.{1,196})/gs);
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
    my ($self, $word, $encoded, $before, $after) = @_;

    print "--- $word ($before) ($after)\n" if ($self->{debug});
    
    my $mword = $self->{mangle}->mangle($word);
    
    if ( $mword ne '' )  {
        if ( $self->{color} ) {
            my $color = $self->{bayes}->get_color($mword);
            if ( $encoded == 0 )  {
                $after = '&' if ( $after eq '>' );
                $self->{ut} =~ s/($before)\Q$word\E($after)/$1<b><font color=$color>$word<\/font><\/b>$2/;
            } else {
                $self->{ut} .= "Found in encoded data <font color=$color>$word<\/font>\r\n";
            }
        } else {
            $self->{words}{$mword} += 1;
            $self->{msg_total}     += 1;

            print "--- $word ($self->{words}{$mword}) ($before) ($after)\n" if ($self->{debug});
        }
    }
}

# ---------------------------------------------------------------------------------------------
#
# add_line
#
# Parses a single line of text and updates the word frequencies
#
# $bigline      The line to split into words and add to the word counts
# $encoded      1 if the line was found in encoded text (base64)
#
# ---------------------------------------------------------------------------------------------
sub add_line 
{
    my ($self, $bigline, $encoded) = @_;
    my $p = 0;
    
    # If the line is really long then split at every 1k and feed it to the parser below
    
    while ( $p < length($bigline) ) {
        my $line = substr($bigline, $p, 1024);
        
        # Pull out any email addresses in the line that are marked with <> and have an @ in them

        while ( $line =~ s/(mailto:)?([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+?))([\&\?\:\/ >\&\;])// )  {
            update_word($self, $2, $encoded, ($1?$1:''), '[\&\?\:\/ >\&\;]');
            add_url($self, $3, $encoded, '\@', '[\&\?\:\/]');
        }
        
        # Grab domain names
        while ( $line =~ s/(([[:alpha:]0-9\-_]+\.)+)(com|edu|gov|int|mil|net|org|aero|biz|coop|info|museum|name|pro|[[:alpha:]]{2})([^[:alpha:]0-9\-_\.]|$)/$4/ )  {
             add_url($self, "$1$3", $encoded, '', '');
        }
            
             

        # Grab IP addresses

        while ( $line =~ s/(([12]?\d{1,2}\.){3}[12]?\d{1,2})// )  {
            update_word($self, "$1", $encoded, '', '');
        }
        
        #deal with runs of alternating spaces and letters
        #TODO: find a way to make this (and other similar stuff) highlight
        #       without using the encoded content printer or modifying $self->{ut}
        while ( $line =~ /(([ \xA0]|[^\w]|^)([\w][\xA0 ]){3,42}([\w][^ \xA0\w])?)/i ) {
            my $from = $1;            
            $from =~ s/^([\xA0 ])?(.*)([\xA0 \r\n])?$/$2/g;
            my $to = $from;            
            $to =~ s/[ \xA0]//g;
            print "\"$from\" -> \"$to\"\n" if $self->{debug};
            $line =~ s/$from/ $to /g;
            $self->{ut} =~ s/$from/ $to /g;
        }
        

        # Only care about words between 3 and 45 characters since short words like
        # an, or, if are too common and the longest word in English (according to
        # the OED) is pneumonoultramicroscopicsilicovolcanoconiosis

        while ( $line =~ s/([[:alpha:]][[:alpha:]\']{0,44})[_\-,\.\"\'\)\?!:;\/&]{0,5}([ \t\n\r]|$)/ / ) {
            update_word($self,$1, $encoded, '', '[_\-,\.\"\'\)\?!:;\/ &\t\n\r]') if (length $1 >= 3);
        }
        
        $p += 1024;
    }
}

# ---------------------------------------------------------------------------------------------
#
# update_tag
#
# Extract elements from within HTML tags that are considered important 'words' for analysis
# such as domain names, alt tags, 
#
# $tag     The tag name
# $arg     The arguments
#
# ---------------------------------------------------------------------------------------------
sub update_tag 
{
    my ($self, $tag, $arg) = @_;

    $tag =~ s/[\r\n]//g;
    $arg =~ s/[\r\n]//g;

    print "HTML tag $tag with argument " . $arg . "\n" if ($self->{debug});
 
    my $attribute;
    my $value;
    
    #these are used to pass good values to update_word
    my $quote;
    my $end_quote;
    
    # Strip the first attribute while there are any attributes
    # Match the closing attribute character, if there is none 
    # (this allows nested single/double quotes),
    # match a space or > or EOL    
    while ( $arg =~ s/[ \t]*(\w+)[ \t]*=[ \t]*([\"\'])?(.*?)(?(2)\2|($|([ \t>])))//i ) {
        $attribute = $1;
        $value     = $3;        
        $quote     = '';
        $end_quote = '[\> \t\&]';
        if (defined $2) {
            $quote     = $2;
            $end_quote = $2;
        }
                
        print "   attribute $attribute with value $quote$value$quote\n" if ($self->{debug});
        
        # Remove leading whitespace and leading value-less attributes
        if ( $arg =~ s/^(([ \t]*(\w+)[\t ]+)+)([^=])/$4/ ) {    
            print "   attribute(s) " . $1 . " with no value\n" if ($self->{debug});        
        }       
        
        # Toggle for parsing script URI's. 
        # Should be left off (0) until more is known about how different html 
        # rendering clients behave.
        my $parse_script_uri = 0;
        
        # Tags with src attributes
        if ( ( $attribute =~ /^src$/i ) &&
             ( ( $tag =~ /^img|frame|iframe$/i )
               || ( $tag =~ /^script$/i && $parse_script_uri ) ) ) {
            add_url( $self, $value, 0, $quote, $end_quote );
            next;
        }
        
        # Tags with href attributes
        if ( $attribute =~ /^href$/i && $tag =~ /^(a|link|base|area)$/i )  {
            # ftp, http, https
            if ( $value =~ /^(ftp|http|https):\/\//i ) {
                add_url($self, $value, 0, $quote, $end_quote);
                next;
            }
    
            # The less common mailto: goes second, and we only care if this is in an anchor
            if ( $tag =~ /^a$/ && $value =~ /^mailto:([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+?))([>\&\?\:\/]|$)/i )  {
               update_word( $self, $1, 0, 'mailto:', ($3?'[\\\>\&\?\:\/]':$end_quote) );
               add_url( $self, $2, 0, '@', ($3?'[\\\&\?\:\/]':$end_quote) );
            }
            next;
        }
        
        # Tags with alt attributes
        if ( $attribute =~ /^alt$/i && $tag =~ /^img$/i )  {
            add_line($self, $value, 0);
            next;
         }
         
        # Tags with working background attributes
        if ( $attribute =~ /^background$/i && $tag =~ /^(td|table|body)$/i ) {
            add_url( $self, $value, 0, $quote, $end_quote );
            next;
        }
        
        # Tags that load sounds
        if ( $ attribute =~ /^bgsound$/i && $tag =~ /^body$/i ) {
            add_url( $self, $2, 0, $quote, $end_quote );
            next;
        }
                
        # Tags with style attributes (this one may impact performance!!!)
        # most container tags accept styles, and the background style may
        # not be in a predictable location (search the entire value)
        if ( $attribute =~ /^style$/i && $tag =~ /^(body|td|tr|table|span|div|p)$/i ) {            
            add_url( $self, $1, 0, '[\']', '[\']' ) if ( $value =~ /background\-image:[ \t]?url\([ \t]?\'(.*)\'[ \t]?\)/i );
            next;
        }
        
        # Tags with action attributes
        if ( $attribute =~ /^action$/i && $tag =~ /^form$/i )  {
            if ( $value =~ /^(ftp|http|https):\/\//i ) {
                add_url( $self, $value, 0, $quote, $end_quote );
                next;
            }
        
            # mailto forms            
            if ( $value =~ /^mailto:([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+?))([>\&\?\:\/])/i )  {
               update_word( $self, $1, 0, 'mailto:', ($3?'[\\\>\&\?\:\/]':$end_quote) );
               add_url( $self, $2, 0, '@', ($3?'[\\\>\&\?\:\/]':$end_quote) );
            }            
            next;
        }        
    } 
}

# ---------------------------------------------------------------------------------------------
#
# add_url
#
# Parses a single url or domain and identifies interesting parts
#
# $url          the domain name to handle
# $encoded      1 if the domain was found in encoded text (base64)
#
# ---------------------------------------------------------------------------------------------
sub add_url
{
    my ($self, $url, $encoded, $before, $after) = @_;
      
    my $temp_url = $url;
    my $temp_before;
    my $temp_after;
    
    #remove URL encoding
    while ( ( $url =~ /\%([0-9A-F][0-9A-F])/i ) != 0 ) {
        my $from = "%$1";
        my $to   = chr(hex("0x$1"));
        $url =~ s/$from/$to/g;
        $self->{ut} =~ s/$from/$to/g;
    }                   
    
    # parts of a URL, from left to right
    my $protocol;   #optional
    my $authinfo;   #optional
    my $host;
    my $port;       #optional    
    my $path;       #optional
    my $query;      #optional
    my $hash;       #optional    
    
    # lay the groundwork
    $protocol = $1 if ( $url =~ s/^(.*)\:\/\/// );
    $authinfo = $1 if ( $url =~ s/^([[:alpha:]0-9\-_]+\:[[:alpha:]0-9\-_]+)\@// );
    
    if ( $url =~ s/^(([[:alpha:]0-9\-_]+\.)+)(com|edu|gov|int|mil|net|org|aero|biz|coop|info|museum|name|pro|[[:alpha:]]{2})([^[:alpha:]0-9\-_\.]|$)/$4/ ) {
        $host = "$1$3";        
    } else {
        print "no hostname found: [$temp_url]\n" if ($self->{debug});
        return 0;
    }    
    
    $port = $1 if ( $url =~ s/^\:(\d+)//);
    $path = $1 if ( $url =~ s/^([\\\/][^\#\?\n]*)($)?// );
    $query = $1 if ( $url =~ s/^[\?]([^\#\n]*|$)?// );
    $hash = $1 if ( $url =~ s/^[\#](.*)$// );
    
    print "URL: (".($protocol||'').")(".($authinfo||'').")(".($host||'').")(".($port||'').")(".($path||'').")(".($query||'').")(".($hash||'').")"." from ".$temp_url."\n" if ($self->{debug});
    
    
    if ( !defined $protocol || $protocol =~ /^(http|https)$/ ) {
        $temp_before = $before;
        $temp_before = "\:\/\/" if (defined $protocol);
        $temp_before = "[\@]" if (defined $authinfo);
              
        $temp_after = $after;
        $temp_after = "[\#]" if (defined $hash);
        $temp_after = "[\?]" if (defined $query);
        $temp_after = "[\\\\\/]" if (defined $path);
        $temp_after = "[\:]" if (defined $port);
        
        update_word( $self, $host, $encoded, $temp_before, $temp_after);
        # decided not to care about tld's beyond the verification performed when
        # grabbing $host
        # special subTLD's can just get their own classification weight (eg, .bc.ca)
        # http://www.0dns.org has a good reference of ccTLD's and their sub-tld's if desired
        while ( $host =~ s/^([^\.])+\.(.*\.(.*))$/$2/ ) {
            update_word( $self, $2, $encoded, '[\.]', '[<]');
        }        
    }
    
    # $protocol $authinfo $host $port $query $hash may be processed below if desired
}

# ---------------------------------------------------------------------------------------------
#
# parse_html
#
# Parse a line that might contain HTML information
#
# $line     A line of text 
#
# ---------------------------------------------------------------------------------------------
sub parse_html
{
    my ( $self, $line ) = @_;

    my $code = 0;
    
    # Remove HTML comments

    $line =~ s/<!--.*?-->//g;

    # Remove HTML tags completely

    if ( $self->{in_html_tag} )  {
        if ( $line =~ s/(.*?)>// ) {
            $self->{html_arg} .= $1;
            $self->{in_html_tag} = 0;
            $self->{html_tag} =~ s/=\n ?//g;
            $self->{html_arg} =~ s/=\n ?//g;
            update_tag( $self, $self->{html_tag}, $self->{html_arg} );
            $self->{html_tag} = '';
            $self->{html_arg} = '';
            $code             = 1;
        } else {
            $self->{html_arg} .= " " . $line;
            $line = '';
            return 1;
        }
    }

    while ( $line =~ s/<[\/]?([A-Za-z]+)([^>]*?)>// )  {
        update_tag( $self, $1, $2 );
        $code = 1;
    }

    if ( $line =~ s/<([^ >]+)([^>]*)$// )  {
        $self->{html_tag} = $1;
        $self->{html_arg} = $2;
        $self->{in_html_tag} = 1;
        $code = 1;
    }
    
    print "HTML removed leaves: $line \n" if ($self->{debug} && $code);
    
    if ( $self->{content_type} =~ /\/html/i ) {
        add_line( $self, $line, 0 );
    } else {
        $code = 0;
    }

    return $code;
}

# ---------------------------------------------------------------------------------------------
#
# parse_stream
#
# Read messages from a file stream and parse into a list of words and frequencies
#
# $file     The file to open and parse
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

    $self->{content_type} = '';

    # Used to return a colorize page
    
    my $colorized = '';

    $self->{in_html_tag} = 0;
    $self->{html_tag}    = '';
    $self->{html_arg}    = '';

    $self->{words}     = {};
    $self->{msg_total} = 0;
    $self->{from}      = '';
    $self->{to}        = '';
    $self->{subject}   = '';
    $self->{ut}        = '';
    
    $self->{in_headers} = 1;

    $colorized .= "<tt>" if ( $self->{color} );

    open MSG, "<$file";
    binmode MSG;
    
    # Read each line and find each "word" which we define as a sequence of alpha
    # characters
    
    while (<MSG>) {
        my $read = $_;

        # For the Mac we do further splitting of the line at the CR characters
        
        while ( $read =~ s/(.*?[\r\n]+)// )  {
            my $line = $1;

            next if ( !defined($line) );
            
            print ">>> $line" if $self->{debug};

            if ( $self->{color} )  {
                my $splitline = $line;    
                $splitline =~ s/([^\r\n]{100,120} )/$1\r\n/g;
                $splitline =~ s/([^ \r\n]{120})/$1\r\n/g;

                if ( !$self->{in_html_tag} )  {
                    $colorized .= $self->{ut} if ( $self->{ut} ne '' );
                    
                    $self->{ut} = '';
                }

                $splitline =~ s/</&lt;/g;
                $splitline =~ s/>/&gt;/g;
                $splitline =~ s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;
                $self->{ut} .= $splitline;
            }
            
            if ( !$self->{in_headers} ) {
                # If we are in a mime document then spot the boundaries
                if ( ( $mime ne '' ) && ( $line =~ /^\-\-$mime/ ) ) {
                    print "Hit mime boundary\n" if $self->{debug};
                    $encoding = '';
                    $self->{in_headers} = 1;
                    next;
                }
                
                # If we are doing base64 decoding then look for suitable lines and remove them 
                # for decoding
                
                if ( $encoding =~ /base64/i ) {
                    my $decoded = '';
                    $self->{ut} = '' if $self->{color};
                    print "ba> [$line]" if $self->{debug};
                    while ( ( $line =~ /^([A-Za-z0-9+\/]{4}){1,48}[\n\r]*/ ) || ( $line =~ /^[A-Za-z0-9+\/]+=+?[\n\r]*/ ) ) {
                        print "64> $line" if $self->{debug};
                        $decoded    .= un_base64( $self, $line );
                        if ( $decoded =~ /[^[:alpha:]\-\.]$/ )  {
                            if ( $self->{color} ) {
                                my $splitline = $line;    
                                $splitline =~ s/([^\r\n]{120})/$1\r\n/g;
                                $self->{ut} = $splitline;
                            }
                            add_line( $self, $decoded, 1 ) if ( parse_html( $self, $decoded ) == 0 );
                            $decoded = '';
                            if ( $self->{color} )  {
                                if ( $self->{ut} ne '' )  {
                                    $colorized .= $self->{ut};
                                    $self->{ut} = '';
                                }
                            }
                        }
                
                        last if ( !($line = <MSG>) );
                    }
                
                    add_line( $self, $decoded, 1 ) if ( parse_html( $self, $decoded ) == 0 );
                }
                
                next if ( !defined($line) );
                
                # Transform some escape characters
                
                if ( $encoding =~ /quoted\-printable/ ) {
                    $line =~ s/=[\r\n]*$/=\n/;
                    while ( ( $line =~ /=([0-9A-F][0-9A-F])/i ) != 0 ) {
                        my $from = "=$1";
                        my $to   = chr(hex("0x$1"));
                        $line =~ s/$from/$to/g;
                    }
                }
                
                # mangle up html character entities
                # these are just the low ISO-Latin1 entities
                # see: http://www.w3.org/TR/REC-html32#latin1
                # TODO: find a way to make this (and other similar stuff) highlight
                #       without using the encoded content printer or modifying $self->{ut}
                if ( $self->{content_type} =~ /html/ ) {
                     while ( $line =~ m/\G(\&([\w]{3,6})\;)/g ) {
                         my $from = $2;                         
                         my $to   = $entityhash{$1};
                         if ( defined( $to ) ) {
                            $to         = chr($to);
                            $line       =~ s/$from/$to/g;
                            $self->{ut} =~ s/$from/$to/g;
                            print "$from -> $to\n" if $self->{debug};
                         } 
                     }
                     while ( $line =~ /(\&\#([\d]{3})\;)/ ) {
                         if ( ( $1 < 255 ) && ( $1 > 159 ) ) {
                            my $from = $1;
                            my $to   = chr($2);
                            if ( defined( $to ) &&  ( $to ne '' ) ) {
                                $line       =~ s/$from/$to/g;
                                $self->{ut} =~ s/$from/$to/g;
                            }
                        }
                    }
                }
                add_line( $self, $line, 0 ) if ( parse_html( $self, $line ) == 0 );
            } 
            if ($self->{in_headers}) {                
                #check for blank line signifying end of headers
                if ( $line =~ /^\r\n/) {
                    $self->{in_headers} = 0;
                    print "Header parsing complete.\r" if $self->{debug};
                }
                                                
                # If we have an email header then just keep the part after the :
                if ( $line =~ /^([A-Za-z-]+): ?([^\n\r]*)/ )  {
                    my $header   = $1;
                    my $argument = $2;
    
                    print "Header ($header) ($argument)\n" if ($self->{debug});
    
                    # Handle the From, To and Cc headers and extract email addresses
                    # from them and treat them as words
    
                    if ( $header =~ /(From|To|Cc|Reply\-To)/i ) {
                        if ( $header =~ /From/ )  {
                            $encoding     = '';
                            $self->{content_type} = '';
                            $self->{from} = $argument if ( $self->{from} eq '' ) ;
                        }
    
                        $self->{to} = $argument if ( ( $header =~ /To/i ) && ( $self->{to} eq '' ) );
                        
                        while ( $argument =~ s/<([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+?))>// )  {
                            update_word($self, $1, 0, ';', '&');
                            add_url($self, $2, 0, '@', '[&<]');
                        }
    
                        while ( $argument =~ s/([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+))// )  {
                            update_word($self, $1, 0, '', '');
                            add_url($self, $2, 0, '@', '');
                        }
    
                        add_line( $self, $argument, 0 );
                        next;
                    }
    
                    $self->{subject} = $argument if ( ( $header =~ /Subject/ ) && ( $self->{subject} eq '' ) );
    
                    # Look for MIME
    
                    if ( $header =~ /Content-Type/i )  {
                        if ( $argument =~ /multipart\//i ) {
                            my $boundary = $argument;
                            
                            #TODO: add boundary to self->{ut}
                            $boundary = <MSG> if ( !( $argument =~ /boundary= ?[\"]?(.*)[\"]?/ )); 
    
                            if ( $boundary =~ /boundary= ?[\"]?(.*)[\"]?/ )  {
                                print "Set mime boundary to $1\n" if $self->{debug};
    
                                $mime = $1;
                                $mime =~ s/(\+|\/|\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/\\$1/g;
                            }
                        }
    
                        $self->{content_type} = $argument;
                        next;
                    }
    
                    # Look for the different encodings in a MIME document, when we hit base64 we will
                    # do a special parse here since words might be broken across the boundaries
    
                    if ( $header =~ /Content-Transfer-Encoding/i ) {
                        $encoding = $argument;
                        print "Setting encoding to $encoding\n" if $self->{debug};
                        next;
                    }
    
                    # Some headers to discard
    
                    next if ( $header =~ /(Thread-Index|X-UIDL|Message-ID|X-Text-Classification|X-Mime-Key)/i );
    
                    add_line( $self, $argument, 0 );
                } else {
                    add_line( $self, $line, 0 ) if ( parse_html( $self, $line ) == 0 );
                }
            }
        }
    }

    close MSG;
    
    if ( $self->{color} )  {
        $colorized .= $self->{ut} if ( $self->{ut} ne '' );

        $colorized .= "</tt>";
        $colorized =~ s/(\r\n\r\n|\r\r|\n\n)/__BREAK____BREAK__/g;
        $colorized =~ s/[\r\n]+/__BREAK__/g;
        $colorized =~ s/__BREAK__/<br>/g;
        
        return $colorized;
    }
}

1;
