package Classifier::MailParse;

# ---------------------------------------------------------------------------------------------
#
# MailParse.pm --- Parse a mail message or messages into words
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;
use warnings;
use locale;
use Classifier::WordMangle;

use MIME::Base64;
use MIME::QuotedPrint;

# HTML entity mapping to character codes, this maps things like &amp; to their corresponding
# character code

my %entityhash;

@entityhash{'amp', 'nbsp','iexcl','cent','pound','curren','yen','brvbar','sect','uml','copy','ordf','laquo','not','shy','reg','macr','deg','plusmn','sup2','sup3','acute','micro','para','middot','cedil','sup1','ordm','raquo','frac14','frac12','frac34','iquest','Agrave','Aacute','Acirc','Atilde','Auml','Aring','AElig','Ccedil','Egrave','Eacute','Ecirc','Euml','Igrave','Iacute','Icirc','Iuml','ETH','Ntilde','Ograve','Oacute','Ocirc','Otilde','Ouml','times','Oslash','Ugrave','Uacute','Ucirc','Uuml','Yacute','THORN','szlig','agrave','aacute','acirc','atilde','auml','aring','aelig','ccedil','egrave','eacute','ecirc','euml','igrave','iacute','icirc','iuml','eth','ntilde','ograve','oacute','ocirc','otilde','ouml','divide','oslash','ugrave','uacute','ucirc','uuml','yacute','thorn','yuml'} = ( 38, 160,161,162,163,164,165,166,167,168,169,170,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255 );        

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

    # These store the current HTML background color and font color to
    # detect "invisible ink" used by spammers

    $self->{htmlbackcolor} = map_color( $self, 'white' );
    $self->{htmlfontcolor} = map_color( $self, 'black' );

    # This is a mapping between HTML color names and HTML hexadecimal color values used by the
    # map_color value to get canonical color values

    $self->{color_map} = { 'white', 'ffffff', 'black', '000000', 'red', 'ff0000', 'green', '00ff00', 'blue', '0000ff' };

    $self->{content_type} = '';
    $self->{base64}       = '';
    $self->{in_html_tag}  = 0;
    $self->{html_tag}     = '';
    $self->{html_arg}     = '';
    $self->{in_headers}   = 0;
    
    return bless $self, $type;
}

# ---------------------------------------------------------------------------------------------
#
# map_color
#
# Convert an HTML color value into its canonical lower case hexadecimal form with no #
#
# $color        A color value found in a tag
#
# ---------------------------------------------------------------------------------------------
sub map_color
{
    my ( $self, $color ) = @_;
    
    # The canonical form is lowercase hexadecimal, so start by lowercasing and stripping any
    # initial #
    
    $color = lc( $color );
    $color =~ s/^#//;
    
    # Map color names to hexadecimal values
    
    if ( defined( $self->{color_map}{$color} ) ) {
        return $self->{color_map}{$color};
    } else {
        return $color;
    }
}

# ---------------------------------------------------------------------------------------------
#
# increment_word
#
# Updates the word frequency for a word without performing any coloring or transformation
# on the word
#
# $word     The word
#
# ---------------------------------------------------------------------------------------------
sub increment_word
{
    my ($self, $word) = @_;
    
    $self->{words}{$word} += 1;
    $self->{msg_total}    += 1;

    print "--- $word ($self->{words}{$word})\n" if ($self->{debug});
}

# ---------------------------------------------------------------------------------------------
#
# update_word
#
# Updates the word frequency for a word 
#
# $word         The word that is being updated
# $encoded      1 if the line was found in encoded text (base64)
# $before       The character that appeared before the word in the original line
# $after        The character that appeared after the word in the original line
# $prefix       A string to prefix any words with in the corpus, used for the special
#               identification of values found in for example the subject line
#
# ---------------------------------------------------------------------------------------------
sub update_word 
{
    my ($self, $word, $encoded, $before, $after, $prefix) = @_;

    my $mword = $self->{mangle}->mangle($word);

    if ( $mword ne '' )  {
        $mword = $prefix . ':' . $mword if ( $prefix ne '' );

        if ( $self->{color} ) {
            my $color = $self->{bayes}->get_color($mword);
            if ( $encoded == 0 )  {
                $after = '&' if ( $after eq '>' );
                if ( !( $self->{ut} =~ s/($before)\Q$word\E($after)/$1<b><font color=\"$color\">$word<\/font><\/b>$2/ ) ) {
                	print "Could not find $word for colorization\n" if ( $self->{debug} );
                }
            } else {
                $self->{ut} .= "Found in encoded data <font color=\"$color\">$word<\/font>\r\n";
            }
        } else {
            increment_word( $self, $mword );
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
# $prefix       A string to prefix any words with in the corpus, used for the special
#               identification of values found in for example the subject line
#
# ---------------------------------------------------------------------------------------------
sub add_line 
{
    my ($self, $bigline, $encoded, $prefix) = @_;
    my $p = 0;
    
    print "add_line: [$bigline]\n" if $self->{debug};
    
    # If the line is really long then split at every 1k and feed it to the parser below
    
    # Check the HTML back and font colors to ensure that we are not about to
    # add words that are hidden inside invisible ink

    if ( $self->{htmlfontcolor} ne $self->{htmlbackcolor} ) {
        while ( $p < length($bigline) ) {
            my $line = substr($bigline, $p, 1024);

            # mangle up html character entities
            # these are just the low ISO-Latin1 entities
            # see: http://www.w3.org/TR/REC-html32#latin1
            # TODO: find a way to make this (and other similar stuff) highlight
            #       without using the encoded content printer or modifying $self->{ut}

            while ( $line =~ m/(&(\w{3,6});)/g ) { 
                my $from = $1; 
                my $to   = $entityhash{$2}; 

                if ( defined( $to ) ) {
                    $to         = chr($to);
                    $line       =~ s/$from/$to/g;
                    $self->{ut} =~ s/$from/$to/g;
                    print "$from -> $to\n" if $self->{debug};
                } 
            }

            while ( $line =~ m/(&#([\d]{1,3});)/g ) { 

                # Don't decode odd (nonprintable) characters or < >'s. 

                if ( ( ( $2 < 255 ) && ( $2 > 63 ) ) || ( $2 == 61 ) || ( ( $2 < 60 ) && ( $2 > 31 ) ) ) { 
                    my $from = $1;
                    my $to   = chr($2);

                    if ( defined( $to ) &&  ( $to ne '' ) ) {
                        $line       =~ s/$from/$to/g;
                        $self->{ut} =~ s/$from/$to/g;
                        print "$from -> $to\n" if $self->{debug};
                        increment_word( $self, 'html:numericentity' );
                    }
                }
            }

            # Pull out any email addresses in the line that are marked with <> and have an @ in them

            while ( $line =~ s/(mailto:)?([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+\.[[:alpha:]0-9\-_]+))([\&\)\?\:\/ >\&\;])// )  {
                update_word($self, $2, $encoded, ($1?$1:''), '[\&\?\:\/ >\&\;]', $prefix);
                add_url($self, $3, $encoded, '\@', '[\&\?\:\/]', $prefix);
            }

            # Grab domain names
            while ( $line =~ s/(([[:alpha:]0-9\-_]+\.)+)(com|edu|gov|int|mil|net|org|aero|biz|coop|info|museum|name|pro)([^[:alpha:]0-9\-_\.]|$)/$4/i )  {
                 add_url($self, "$1$3", $encoded, '', '', $prefix);
            }

            # Grab IP addresses

            while ( $line =~ s/(([12]?\d{1,2}\.){3}[12]?\d{1,2})// )  {
                update_word($self, "$1", $encoded, '', '', $prefix);
            }

            # Deal with runs of alternating spaces and letters
            # TODO: find a way to make this (and other similar stuff) highlight
            #       without using the encoded content printer or modifying $self->{ut}

            foreach my $space (' ', '\'', '*', '^', '`' ){
                while ( $line =~ s/ (([A-Z]\Q$space\E){2,15}[A-Z])( |\Q$space\E|[!\?])/ /i ) {
                    my $word = $1;
                    $word    =~ s/\Q$space\E//g;
                    update_word( $self, $word, $encoded, ' ', ' ', '' );
                    increment_word( $self, 'trick:spacedout' );
                }
            }
            
            # Deal with random insertion of . inside words

            while ( $line =~ s/ ([A-Z]+)\.([A-Z]{2,}) / $1$2 /i ) {
                increment_word( $self, 'trick:dottedwords' );
            }

            # Only care about words between 3 and 45 characters since short words like
            # an, or, if are too common and the longest word in English (according to
            # the OED) is pneumonoultramicroscopicsilicovolcanoconiosis

            while ( $line =~ s/([[:alpha:]][[:alpha:]\']{1,44})([_\-,\.\"\'\)\?!:;\/& \t\n\r]{0,5}|$)// ) {
                update_word($self,$1, $encoded, '', '[_\-,\.\"\'\)\?!:;\/ &\t\n\r]', $prefix) if (length $1 >= 3);
            }

            $p += 1024;
        }
    } else {
    	$self->increment_word( 'trick:invisibleink' );
    }
}

# ---------------------------------------------------------------------------------------------
#
# update_tag
#
# Extract elements from within HTML tags that are considered important 'words' for analysis
# such as domain names, alt tags, 
#
# $tag      The tag name
# $arg      The arguments
# $end_tag  Whether this is an end tag or not
# $encoded  1 if this HTML was found inside encoded (base64) text
#
# ---------------------------------------------------------------------------------------------
sub update_tag 
{
    my ( $self, $tag, $arg, $end_tag, $encoded ) = @_;

    $tag =~ s/[\r\n]//g;
    $arg =~ s/[\r\n]//g;

    print "HTML tag $tag with argument " . $arg . "\n" if ($self->{debug});

    # End tags do not require any argument decoding but we do look at them
    # to make sure that we handle /font to change the font color

    if ( $end_tag ) {
        if ( $tag =~ /^font$/i ) {
            $self->{htmlfontcolor} = map_color( $self, 'black' );
        }
        
        return;
    }

	# Count the number of TD elements
	increment_word( $self, 'html:td' ) if ( $tag =~ /^td$/i );
 
    my $attribute;
    my $value;
    
    # These are used to pass good values to update_word

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
            add_url( $self, $value, $encoded, $quote, $end_quote, '' );
            next;
        }
        
        # Tags with href attributes

        if ( $attribute =~ /^href$/i && $tag =~ /^(a|link|base|area)$/i )  {

            # ftp, http, https

            if ( $value =~ /^(ftp|http|https):\/\//i ) {
                add_url($self, $value, $encoded, $quote, $end_quote, '');
                next;
            }
    
            # The less common mailto: goes second, and we only care if this is in an anchor

            if ( $tag =~ /^a$/ && $value =~ /^mailto:([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+?))([>\&\?\:\/]|$)/i )  {
               update_word( $self, $1, $encoded, 'mailto:', ($3?'[\\\>\&\?\:\/]':$end_quote), '' );
               add_url( $self, $2, $encoded, '@', ($3?'[\\\&\?\:\/]':$end_quote), '' );
            }
            next;
        }
        
        # Tags with alt attributes

        if ( $attribute =~ /^alt$/i && $tag =~ /^img$/i )  {
            add_line($self, $value, $encoded, '');
            next;
         }
         
        # Tags with working background attributes

        if ( $attribute =~ /^background$/i && $tag =~ /^(td|table|body)$/i ) {
            add_url( $self, $value, $encoded, $quote, $end_quote, '' );
            next;
        }
        
        # Tags that load sounds

        if ( $attribute =~ /^bgsound$/i && $tag =~ /^body$/i ) {
            add_url( $self, $2, $encoded, $quote, $end_quote, '' );
            next;
        }


        # Tags with colors in them
        if ( ( $attribute =~ /^color$/i ) && ( $tag =~ /^font$/i ) ) {
            update_word( $self, $value, $encoded, $quote, $end_quote, '' );
            $self->{htmlfontcolor} = map_color($self, $value);
			print "Set html font color to $self->{htmlfontcolor}\n" if ( $self->{debug} );
        }
                
        # Tags with background colors

        if ( ( $attribute =~ /^(bgcolor|back)$/i ) && ( $tag =~ /^(td|table|body|tr|th|font)$/i ) ) {
            update_word( $self, $value, $encoded, $quote, $end_quote, '' );
            $self->{htmlbackcolor} = map_color($self, $value);
			print "Set html back color to $self->{htmlbackcolor}\n" if ( $self->{debug} );
        }

        # Tags with a charset

        if ( ( $attribute =~ /^content$/i ) && ( $tag =~ /^meta$/i ) ) {
            if ( $value=~ /charset=(.{1,40})[\"\>]?/ ) {
                update_word( $self, $1, $encoded, '', '', '' );
            }
        }
                
        # Tags with style attributes (this one may impact performance!!!)
        # most container tags accept styles, and the background style may
        # not be in a predictable location (search the entire value)

        if ( $attribute =~ /^style$/i && $tag =~ /^(body|td|tr|table|span|div|p)$/i ) {            
            add_url( $self, $1, $encoded, '[\']', '[\']', '' ) if ( $value =~ /background\-image:[ \t]?url\([ \t]?\'(.*)\'[ \t]?\)/i );
            next;
        }
        
        # Tags with action attributes

        if ( $attribute =~ /^action$/i && $tag =~ /^form$/i )  {
            if ( $value =~ /^(ftp|http|https):\/\//i ) {
                add_url( $self, $value, $encoded, $quote, $end_quote, '' );
                next;
            }
        
            # mailto forms            

            if ( $value =~ /^mailto:([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+?))([>\&\?\:\/])/i )  {
               update_word( $self, $1, $encoded, 'mailto:', ($3?'[\\\>\&\?\:\/]':$end_quote), '' );
               add_url( $self, $2, $encoded, '@', ($3?'[\\\>\&\?\:\/]':$end_quote), '' );
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
# $before       The character that appeared before the URL in the original line
# $after        The character that appeared after the URL in the original line
# $prefix       A string to prefix any words with in the corpus, used for the special
#               identification of values found in for example the subject line
#
# ---------------------------------------------------------------------------------------------
sub add_url
{
    my ($self, $url, $encoded, $before, $after, $prefix) = @_;
      
    my $temp_url = $url;
    my $temp_before;
    my $temp_after;
    my $hostform;   #ip or name
   
    # parts of a URL, from left to right
    my $protocol;   
    my $authinfo;   
    my $host;
    my $port;       
    my $path;       
    my $query;      
    my $hash;       
    
    # Strip the protocol part of a URL (e.g. http://)
    
    $protocol = $1 if ( $url =~ s/^(.*)\:\/\/// ); 
    
    # Remove any URL encoding (protocol may not be URL encoded)
    
    while ( $url =~ /(\%([0-9A-Fa-f][0-9A-Fa-f]))/g ) {
        my $from = "$1";
        my $to   = chr(hex("0x$2"));
        $url =~ s/$from/$to/g;
        $self->{ut} =~ s/$from/$to/g;
        print "$from -> $to\n" if $self->{debug};
        increment_word( $self, "html:encodedurl" );
    }

    # Extract authorization information from the URL (e.g. http://foo@bar.com)
            
    $authinfo = $1 if ( $url =~ s/^([[:alpha:]0-9\-_\.\;\:\&\=\+\$\,]+)(\@|\%40)// );
        
    if ( $url =~ s/^(([[:alpha:]0-9\-_]+\.)+)(com|edu|gov|int|mil|net|org|aero|biz|coop|info|museum|name|pro|[[:alpha:]]{2})([^[:alpha:]0-9\-_\.]|$)/$4/ ) {
        $host = "$1$3";
        $hostform = "name";
    } elsif ( $url =~ /(([^:\/])+)/ ) {
    
        # Some other hostname format found, maybe
        # Read here for reference: http://www.pc-help.org/obscure.htm
        # Go here for comparison: http://www.samspade.org/t/url
                
        my $host_candidate = $1;    # save the possible hostname
        
        my %quads;                  # stores discovered IP address
        
        # temporary values
        my $quad = 1;
        my $number;        
        
        #iterate through the possible hostname, build dotted quad format
        while ($host_candidate =~ s/\G^((0x)[0-9A-Fa-f]+|0[0-7]+|[0-9]+)(\.)?//) {            
            
            my $hex = $2;
            my $quad_candidate = $1; # possible IP quad(s)
            my $more_dots = $3;
            
            if (defined $hex) {
                # hex number
                # trim arbitrary octets that are greater than most significant bit
                $quad_candidate =~ s/.*(([0-9A-F][0-9A-F]){4})$/$1/i;
                $number = hex( $quad_candidate );                
            } elsif ( $quad_candidate =~ /^0([0-7]+)/ )  {
                # octal number
                $number = oct($1);
            } else {
                # assume decimal number
                $number = int($quad_candidate);
                # deviates from the obscure.htm document here, no current browsers overflow
            }     
            
            # No more IP dots?
            if (!defined $more_dots) {
                
                # Expand final decimal/octal/hex to extra quads              
                while ($quad <= 4) {
                    my $shift = ((4 - $quad) * 8);
                    $quads{$quad} = ($number & (hex("0xFF") << $shift) ) >> $shift;
                    $quad++;
                }
            } else {
                # Just plug the quad in, no overflow allowed
                $quads{$quad} = $number if ($number < 256);
                $quad++;
            }
            
            last if ($quad > 4);
            
        }
        $host_candidate =~ s/\r|\n|$//g;
        if ( $host_candidate eq '' && defined $quads{1} && defined $quads{2} && defined $quads{3} && defined $quads{4} && !defined $quads{5} ) {
            #we did actually find an IP address, and not some fake
            $hostform = "ip";
            $host = "$quads{1}.$quads{2}.$quads{3}.$quads{4}";
            $url =~ s/(([^:\/])+)//;
        }
    }
    
    if ( !defined $host || $host eq '' ) {
        print "no hostname found: [$temp_url]\n" if ($self->{debug});
        return 0;
    }    
    
    $port = $1 if ( $url =~ s/^\:(\d+)//);
    $path = $1 if ( $url =~ s/^([\\\/][^\#\?\n]*)($)?// );
    $query = $1 if ( $url =~ s/^[\?]([^\#\n]*|$)?// );
    $hash = $1 if ( $url =~ s/^[\#](.*)$// );
    
    if ( !defined $protocol || $protocol =~ /^(http|https)$/ ) {
        $temp_before = $before;
        $temp_before = "\:\/\/" if (defined $protocol);
        $temp_before = "[\@]" if (defined $authinfo);
              
        $temp_after = $after;
        $temp_after = "[\#]" if (defined $hash);
        $temp_after = "[\?]" if (defined $query);
        $temp_after = "[\\\\\/]" if (defined $path);
        $temp_after = "[\:]" if (defined $port);
        
        update_word( $self, $host, $encoded, $temp_before, $temp_after, $prefix);

        # decided not to care about tld's beyond the verification performed when
        # grabbing $host
        # special subTLD's can just get their own classification weight (eg, .bc.ca)
        # http://www.0dns.org has a good reference of ccTLD's and their sub-tld's if desired

        if ( $hostform eq "name" ) {
            while ( $host =~ s/^([^\.])+\.(.*\.(.*))$/$2/ ) {
                update_word( $self, $2, $encoded, '[\.]', '[<]', $prefix);
            }
        }
    }
    
    # $protocol $authinfo $host $port $query $hash may be processed below if desired
}

# ---------------------------------------------------------------------------------------------
#
# parse_html
#
# Parse a line that might contain HTML information, returns 1 if we are still inside an 
# unclosed HTML tag
#
# $line     A line of text 
# $encoded  1 if this HTML was found inside encoded (base64) text
#
# ---------------------------------------------------------------------------------------------
sub parse_html
{
    my ( $self, $line, $encoded ) = @_;

    my $found = 1;

	$line =~ s/[\r\n]+/ /g;
    $line =~ s/[\t ]+$//;

    print "parse_html: [$line] $self->{in_html_tag}\n" if $self->{debug};
   
    # Remove HTML comments and other tags that begin !

    while ( $line =~ s/<!.*?>// ) {
        increment_word( $self, 'html:comment' );
        print "$line\n" if $self->{debug};
    }

    while ( $found && ( $line ne '' ) ) {
        $found = 0;
        
        $line =~ s/^[\t ]+//;

        # If we are in an HTML tag then look for the close of the tag, if we get it then
        # handle the tag, if we don't then keep building up the arguments of the tag

        if ( $self->{in_html_tag} )  {
            if ( $line =~ s/^(.*?)>// ) {
                $self->{html_arg} .= ' ' . $1;
                $self->{in_html_tag} = 0;
                $self->{html_tag} =~ s/=\n ?//g;
                $self->{html_arg} =~ s/=\n ?//g;
                update_tag( $self, $self->{html_tag}, $self->{html_arg}, $self->{html_end}, $encoded );
                $self->{html_tag} = '';
                $self->{html_arg} = '';
                $found = 1;
                next;
            } else {
                $self->{html_arg} .= ' ' . $line;
                return 1;
            }
        }

        # Does the line start with a HTML tag that is closed (i.e. has both the < and the 
        # > present)?  If so then handle that tag immediately and continue
        
        if ( $line =~ s/^<([\/]?)([A-Za-z]+)([^>]*?)>// )  {
            update_tag( $self, $2, $3, ( $1 eq '/' ), $encoded );
            $found = 1;
            next;
        }

        # Does the line consist of just a tag that has no closing > then set up the global
        # vars that record the tag and return 1 to indicate to the caller that we have an
        # unclosed tag

        if ( $line =~ /^<([\/]?)([^ >]+)([^>]*)$/ )  {
            $self->{html_end}    = ( $1 eq '/' );
            $self->{html_tag}    = $2;
            $self->{html_arg}    = $3;
            $self->{in_html_tag} = 1;
            return 1;
        }

        # There could be something on the line that needs parsing (such as a word), if we reach here
        # then we are not in an unclosed tag and so we can grab everything from the start of the line
        # to the end or the first < and pass it to the line parser

        if ( $line =~ s/^([^<]+)(<|$)/$2/ ) {
            $found = 1;
            add_line( $self, $1, $encoded, '' );
        }
    }
    
    return 0;
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

    # Base64 attachments are loaded into this as we read them

    $self->{base64}       = '';
    
    $self->{in_html_tag} = 0;
    $self->{html_tag}    = '';
    $self->{html_arg}    = '';

    $self->{words}     = {};
    $self->{msg_total} = 0;
    $self->{from}      = '';
    $self->{to}        = '';
    $self->{subject}   = '';
    $self->{ut}        = '';

    $self->{htmlbackcolor} = map_color( $self, 'white' );
    $self->{htmlfontcolor} = map_color( $self, 'black' );

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

            if ($self->{in_headers}) {                
            
                # Check for blank line signifying end of headers
                
                if ( $line =~ /^\r\n/) {
                    $self->{in_headers} = 0;
                    print "Header parsing complete.\n" if $self->{debug};
                }
                                                
                # If we have an email header then just keep the part after the :
                
                if ( $line =~ /^([A-Za-z-]+):[ \t]*([^\n\r]*)/ )  {
                    my $header   = $1;
                    my $argument = $2;
    
                    print "Header ($header) ($argument)\n" if ($self->{debug});
    
                    # Handle the From, To and Cc headers and extract email addresses
                    # from them and treat them as words

                    # For certain headers we are going to mark them specially in the corpus
                    # by tagging them with where they were found to help the classifier
                    # do a better job.  So if you have
                    #
                    # From: foo@bar.com
                    #
                    # then we'll add from:foo@bar.com to the corpus and not just foo@bar.com

                    my $prefix = '';
    
                    if ( $header =~ /^(From|To|Cc|Reply\-To)/i ) {
                        if ( $argument =~ /=\?(.{1,40})\?/ ) {
                            update_word( $self, $1, 0, '', '', 'charset' );
                        }
                        
                        if ( $header =~ /^From/i )  {
                            $encoding     = '';
                            $self->{content_type} = '';
                            $self->{from} = $argument if ( $self->{from} eq '' ) ;
                            $prefix = 'from';
                        }

                        $prefix = 'to' if ( $header =~ /^To/i );
                        $self->{to} = $argument if ( ( $header =~ /^To/i ) && ( $self->{to} eq '' ) );
                        
                        while ( $argument =~ s/<([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+?))>// )  {
                            update_word($self, $1, 0, ';', '&',$prefix);
                            add_url($self, $2, 0, '@', '[&<]',$prefix);
                        }
    
                        while ( $argument =~ s/([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+))// )  {
                            update_word($self, $1, 0, '', '',$prefix);
                            add_url($self, $2, 0, '@', '',$prefix);
                        }
    
                        add_line( $self, $argument, 0, $prefix );
                        next;
                    }
    
                    $self->{subject} = $argument if ( ( $header =~ /^Subject/i ) && ( $self->{subject} eq '' ) );

                    if ( $header =~ /^Subject/i ) {
                        $prefix = 'subject';
                    }

                    # Look for MIME 
                    
                    if ( $header =~ /^Content-Type/i ) { 
                        if ( $argument =~ /multipart\//i ) { 
                            my $boundary = $argument; 
                                                        
                            if ( !( $argument =~ /boundary=(\"([A-Z0-9\'\(\)\+\_\,\-\.\/\:\=\?][A-Z0-9\'\(\)\+_,\-\.\/:=\? ]{0,69})\"|([^\(\)\<\>\@\,\;\:\\\"\/\[\]\?\=]{1,70}))/i )) {
                                $boundary = <MSG>;
                            }
                            
                            if ( $boundary =~ /boundary=(\"([A-Z0-9\'\(\)\+\_\,\-\.\/\:\=\?][A-Z0-9\'\(\)\+_,\-\.\/:=\? ]{0,69})\"|([^\(\)\<\>\@\,\;\:\\\"\/\[\]\?\=]{1,70}))/i ) { 
                                                                
                                $boundary = ($2 || $3);
                                
                                $boundary =~ s/(\+|\/|\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/\\$1/g;                                 
                                                                
                                if ($mime ne '') {
                                    
                                    # Fortunately the pipe character isn't a valid mime boundary character!
                                    
                                    $mime = join('|', $mime, $boundary);
                                } else {
                                    $mime = $boundary;
                                }
                                print "Set mime boundary to " . $mime . "\n" if $self->{debug};
                                next;
                            } 
                        } 

                        if ( $argument =~ /charset=\"?([^\"]{1,40})\"?/ ) {
                            update_word( $self, $1, 0, '' , '', 'charset' );
                        }
                        
                        if ( $argument =~ /^(.*?)(;$)/ ) {
                            print "Set content type to $1\n" if $self->{debug};                        
                            $self->{content_type} = $1; 
                        }
                        next; 
                    }
                        
                    # Look for the different encodings in a MIME document, when we hit base64 we will
                    # do a special parse here since words might be broken across the boundaries
    
                    if ( $header =~ /^Content-Transfer-Encoding/i ) {
                        $encoding = $argument;
                        print "Setting encoding to $encoding\n" if $self->{debug};
                        my $compact_encoding = $encoding;
                        $compact_encoding =~ s/[^A-Za-z0-9]//g;
                        increment_word( $self, "encoding:$compact_encoding" );
                        next;
                    }
    
                    # Some headers to discard
    
                    next if ( $header =~ /^(Thread-Index|X-UIDL|Message-ID|X-Text-Classification|X-Mime-Key)/i );
    
                    add_line( $self, $argument, 0, $prefix );
                    
                    next;
                }
            }
            
            # If we are in a mime document then spot the boundaries
            
            if ( ( $mime ne '' ) && ( $line =~ /^\-\-($mime)(\-\-)?/ ) ) {
                $colorized .= clear_out_base64( $self );
                
                # approach each mime part with fresh eyes
                $encoding = '';
                
                
                if (!defined $2) {
                    print "Hit MIME boundary --$1\n" if $self->{debug};
                    $self->{in_headers} = 1;
                } else {
                    
                    $self->{in_headers} = 0;
                    
                    my $boundary = $1;

                    print "Hit MIME boundary terminator --$1--\n" if $self->{debug};

                    # escape to match escaped boundary characters
                                        
                    $boundary =~ s/(\+|\/|\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/\\$1/g;
                                        
                    my $temp_mime;
                    
                    foreach my $aboundary (split(/\|/,$mime)) {
                        if ($boundary ne $aboundary) {
                            if (defined $temp_mime) {
                                $temp_mime = join('|', $temp_mime, $aboundary);
                            } else {
                                $temp_mime = $aboundary
                            }
                        }                            
                    }
                    
                    $mime = ($temp_mime || '');
                    
                    print "MIME boundary list now $mime\n" if $self->{debug};
                    $self->{in_headers} = 0;
                }
                
                next;
            }
            
            # If we are still in the headers then make sure that we are on a line with whitespace
            # at the start

            if ( $self->{in_headers} ) {
                if ( $line =~ /^[ \t\r\n]/ ) {
                    next;
                }
            }

            # If we are doing base64 decoding then look for suitable lines and remove them 
            # for decoding

            if ( $encoding =~ /base64/i ) {
                $line =~ s/[\r\n]//g;
                $line =~ s/!$//;
                $self->{base64} .= $line;
                
                next;
            }

            next if ( !defined($line) );

            # Look for =?foo? syntax that identifies a charset

            if ( $line =~ /=\?(.{1,40})\?/ ) {
                update_word( $self, $1, 0, '', '', 'charset' );
            }

            # Decode quoted-printable

            if ( $encoding =~ /quoted\-printable/i ) {
                $line       = decode_qp( $line );
                $self->{ut} = decode_qp( $self->{ut} ) if ( $self->{color} );
            }

            parse_html( $self, $line, 0 );
        } 
    }

    # If we reach here and disover that we think that we are in an unclosed HTML tag then there
    # has probably been an error (such as a < in the text messing things up) and so we dump
    # whatever is stored in the HTML tag out
    
    if ( $self->{in_html_tag} ) {
        add_line( $self, $self->{html_tag} . ' ' . $self->{html_arg}, 0, '' );
    }

    $colorized .= clear_out_base64( $self );
    close MSG;
    
    if ( $self->{color} )  {
        $colorized .= $self->{ut} if ( $self->{ut} ne '' );

        $colorized .= "</tt>";
        $colorized =~ s/(\r\n\r\n|\r\r|\n\n)/__BREAK____BREAK__/g;
        $colorized =~ s/[\r\n]+/__BREAK__/g;
        $colorized =~ s/__BREAK__/<br \/>/g;
        
        return $colorized;
    }
}

# ---------------------------------------------------------------------------------------------
#
# clear_out_base64
#
# If there's anything in the {base64} then decode it and parse it, returns colorization
# information to be added to the colorized output
#
# ---------------------------------------------------------------------------------------------
sub clear_out_base64
{
    my ( $self ) = @_;

    my $colorized = '';

    if ( $self->{base64} ne '' ) {
        my $decoded = '';

        $self->{ut}     = '' if $self->{color};
        $self->{base64} =~ s/ //g;
        
        print "Base64 data: " . $self->{base64} . "\n" if ($self->{debug});

        $decoded = decode_base64( $self->{base64} );
        parse_html( $self, $decoded, 1 );

        if ( $decoded =~ /[^[:alpha:]\-\.]$/ )  {
            if ( $self->{color} ) {
                my $splitline = $self->{base64};    
                $splitline =~ s/([^\r\n]{120})/$1\r\n/g;
                $self->{ut} = $splitline;
            }

            $decoded = '';

            if ( $self->{color} )  {
                if ( $self->{ut} ne '' )  {
                    $colorized  = $self->{ut};
                    $self->{ut} = '';
                }
            }
        }
    }
    
    $self->{base64} = '';
    
    return $colorized;
}

1;
