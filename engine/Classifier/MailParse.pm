package Classifier::MailParse;

# ---------------------------------------------------------------------------------------------
#
# MailParse.pm --- Parse a mail message or messages into words
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;
use locale;
use Classifier::WordMangle;

use MIME::Base64;
use MIME::QuotedPrint;
#require Encode::MIME::Header;

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

    $self->{mangle__} = new Classifier::WordMangle;

    # Hash of word frequences

    $self->{words__}  = {};

    # Total word cout

    $self->{msg_total__} = 0;

    # Internal use for keeping track of a line without touching it

    $self->{ut__}        = '';

    # Specifies the parse mode, 1 means color the output

    $self->{color__}     = 0;

    # This will store the from, to, cc and subject from the last parse
    $self->{from__}      = '';
    $self->{to__}        = '';
    $self->{cc__}        = '';
    $self->{subject__}   = '';

    # This is used to store the words found in the from, to, and subject
    # lines for use in creating new magnets, it is a list of pairs mapping
    # a magnet type to a magnet string, e.g. from => popfile@jgc.org

    $self->{quickmagnets__}      = {};

    # These store the current HTML background color and font color to
    # detect "invisible ink" used by spammers

    $self->{htmlbackcolor__} = map_color( $self, 'white' );
    $self->{htmlbodycolor__} = map_color( $self, 'white' );
    $self->{htmlfontcolor__} = map_color( $self, 'black' );

    # This is a mapping between HTML color names and HTML hexadecimal color values used by the
    # map_color value to get canonical color values

    $self->{color_map__} = { 'aliceblue','f0f8ff', 'antiquewhite','faebd7', 'aqua','00ffff', 'aquamarine','7fffd4', 'azure','f0ffff',
        'beige','f5f5dc', 'bisque','ffe4c4', 'black','000000', 'blanchedalmond','ffebcd', 'blue','0000ff', 'blueviolet','8a2be2',
        'brown','a52a2a', 'burlywood','deb887', 'cadetblue','5f9ea0', 'chartreuse','7fff00', 'chocolate','d2691e', 'coral','ff7f50',
        'cornflowerblue','6495ed', 'cornsilk','fff8dc', 'crimson','dc143c', 'cyan','00ffff', 'darkblue','00008b', 'darkcyan','008b8b',
        'darkgoldenrod','b8860b', 'darkgray','a9a9a9', 'darkgreen','006400', 'darkkhaki','bdb76b', 'darkmagenta','8b008b', 'darkolivegreen','556b2f',
        'darkorange','ff8c00', 'darkorchid','9932cc', 'darkred','8b0000', 'darksalmon','e9967a', 'darkseagreen','8fbc8f', 'darkslateblue','483d8b',
        'darkturquoise','00ced1', 'darkviolet','9400d3', 'deeppink','ff1493', 'deepskyblue','00bfff', 'deepskyblue','2f4f4f', 'dimgray','696969',
        'dodgerblue','1e90ff', 'firebrick','b22222', 'floralwhite','fffaf0', 'forestgreen','228b22', 'fuchsia','ff00ff', 'gainsboro','dcdcdc',
        'ghostwhite','f8f8ff', 'gold','ffd700', 'goldenrod','daa520', 'gray','808080', 'green','008000', 'greenyellow','adff2f',
        'honeydew','f0fff0', 'hotpink','ff69b4', 'indianred','cd5c5c', 'indigo','4b0082', 'ivory','fffff0', 'khaki','f0e68c',
        'lavender','e6e6fa', 'lavenderblush','fff0f5', 'lawngreen','7cfc00', 'lemonchiffon','fffacd', 'lightblue','add8e6',
        'lightcoral','f08080', 'lightcyan','e0ffff', 'lightgoldenrodyellow','fafad2', 'lightgreen','90ee90', 'lightgrey','d3d3d3',
        'lightpink','ffb6c1', 'lightsalmon','ffa07a', 'lightseagreen','20b2aa', 'lightskyblue','87cefa', 'lightslategray','778899',
        'lightsteelblue','b0c4de', 'lightyellow','ffffe0', 'lime','00ff00', 'limegreen','32cd32', 'linen','faf0e6', 'magenta','ff00ff',
        'maroon','800000', 'mediumaquamarine','66cdaa', 'mediumblue','0000cd', 'mediumorchid','ba55d3', 'mediumpurple','9370db',
        'mediumseagreen','3cb371', 'mediumslateblue','7b68ee', 'mediumspringgreen','00fa9a', 'mediumturquoise','48d1cc',
        'mediumvioletred','c71585', 'midnightblue','191970', 'mintcream','f5fffa', 'mistyrose','ffe4e1', 'moccasin','ffe4b5',
        'navajowhite','ffdead', 'navy','000080', 'oldlace','fdf5e6', 'olive','808000', 'olivedrab','6b8e23', 'orange','ffa500',
        'orangered','ff4500', 'orchid','da70d6', 'palegoldenrod','eee8aa', 'palegreen','98fb98', 'paleturquoise','afeeee',
        'palevioletred','db7093', 'papayawhip','ffefd5', 'peachpuff','ffdab9', 'peru','cd853f', 'pink','ffc0cb', 'plum','dda0dd',
        'powderblue','b0e0e6', 'purple','800080', 'red','ff0000', 'rosybrown','bc8f8f', 'royalblue','4169e1', 'saddlebrown','8b4513',
        'salmon','fa8072', 'sandybrown','f4a460', 'seagreen','2e8b57', 'seashell','fff5ee', 'sienna','a0522d', 'silver','c0c0c0',
        'skyblue','87ceeb', 'slateblue','6a5acd', 'slategray','708090', 'snow','fffafa', 'springgreen','00ff7f', 'steelblue','4682b4',
        'tan','d2b48c', 'teal','008080', 'thistle','d8bfd8', 'tomato','ff6347', 'turquoise','40e0d0', 'violet','ee82ee', 'wheat','f5deb3',
        'white','ffffff', 'whitesmoke','f5f5f5', 'yellow','ffff00', 'yellowgreen','9acd32' };

    $self->{content_type__} = '';
    $self->{base64__}       = '';
    $self->{in_html_tag__}  = 0;
    $self->{html_tag__}     = '';
    $self->{html_arg__}     = '';
    $self->{in_headers__}   = 0;
    $self->{first20__}      = '';

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

    if ( defined( $self->{color_map__}{$color} ) ) {
        return $self->{color_map__}{$color};
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

    $self->{words__}{$word} += 1;
    $self->{msg_total__}    += 1;

    print "--- $word ($self->{words__}{$word})\n" if ($self->{debug});
}

# ---------------------------------------------------------------------------------------------
#
# update_pseudoword
#
# Updates the word frequency for a pseudoword, note that this differs from update_word
# because it does no word mangling
#
# $prefix       The pseudoword prefix (e.g. header)
# $word         The pseudoword (e.g. Mime-Version)
# $encoded      Whether this was found inside encoded text
# $literal      The literal text that generated this pseudoword
#
# ---------------------------------------------------------------------------------------------

sub update_pseudoword
{
    my ( $self, $prefix, $word, $encoded, $literal ) = @_;

    my $mword = "$prefix:$word";

    if ( $self->{color__} ) {
        if ( $encoded == 1 )  {
            $literal =~ s/</&lt;/g;
            $literal =~ s/>/&gt;/g;
            my $color = $self->{bayes__}->get_color($mword);
            my $to    = "<b><font color=\"$color\"><a title=\"$mword\">$literal</a></font></b>";
            $self->{ut__} .= $to . ' ';
        }
    } else {
        $self->increment_word( $mword );
    }
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

    my $mword = $self->{mangle__}->mangle($word);

    if ( $mword ne '' )  {
        $mword = $prefix . ':' . $mword if ( $prefix ne '' );

        if ( $prefix =~ /(from|to|cc|subject)/i ) {
            push @{$self->{quickmagnets__}{$prefix}}, $word;
        }

        if ( $self->{color__} ) {
            my $color = $self->{bayes__}->get_color($mword);
            if ( $encoded == 0 )  {
                $after = '&' if ( $after eq '>' );
                if ( !( $self->{ut__} =~ s/($before)\Q$word\E($after)/$1<b><font color=\"$color\">$word<\/font><\/b>$2/ ) ) {
                	print "Could not find $word for colorization\n" if ( $self->{debug} );
                }
            } else {
                $self->{ut__} .= "<font color=\"$color\">$word<\/font> ";
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

    if ( $self->{htmlfontcolor__} ne $self->{htmlbackcolor__} ) {
        while ( $p < length($bigline) ) {
            my $line = substr($bigline, $p, 1024);

            # mangle up html character entities
            # these are just the low ISO-Latin1 entities
            # see: http://www.w3.org/TR/REC-html32#latin1
            # TODO: find a way to make this (and other similar stuff) highlight
            #       without using the encoded content printer or modifying $self->{ut__}

            while ( $line =~ m/(&(\w{3,6});)/g ) {
                my $from = $1;
                my $to   = $entityhash{$2};

                if ( defined( $to ) ) {
                    $to         = chr($to);
                    $line       =~ s/$from/$to/g;
                    $self->{ut__} =~ s/$from/$to/g;
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
                        $self->{ut__} =~ s/$from/$to/g;
                        print "$from -> $to\n" if $self->{debug};
                        $self->update_pseudoword( 'html', 'numericentity', $encoded, $from );
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

            foreach my $space (' ', '\'', '*', '^', '`', '  ', '\38', '.' ){
                while ( $line =~ s/( |^)(([A-Z]\Q$space\E){2,15}[A-Z])( |\Q$space\E|[!\?,])/ /i ) {
                    my $original = "$1$2$4";
                    my $word = $2;
                    print "$word ->" if $self->{debug};
                    $word    =~ s/[^A-Z]//gi;
                    print "$word\n" if $self->{debug};
                    $self->update_word( $word, $encoded, ' ', ' ', $prefix);
                    $self->update_pseudoword( 'trick', 'spacedout', $encoded, $original );
                }
            }

            # Deal with random insertion of . inside words

            while ( $line =~ s/ ([A-Z]+)\.([A-Z]{2,}) / $1$2 /i ) {
                $self->update_pseudoword( 'trick', 'dottedwords', $encoded, "$1$2" );
            }

            # Only care about words between 3 and 45 characters since short words like
            # an, or, if are too common and the longest word in English (according to
            # the OED) is pneumonoultramicroscopicsilicovolcanoconiosis

            while ( $line =~ s/([[:alpha:]][[:alpha:]\']{1,44})([_\-,\.\"\'\)\?!:;\/& \t\n\r]{0,5}|$)// ) {
                if ( ( $self->{in_headers__} == 0 ) && ( $self->{first20count__} < 20 ) ) {
                    $self->{first20count__} += 1;
                    $self->{first20__} .= " $1";
                }

                update_word($self,$1, $encoded, '', '[_\-,\.\"\'\)\?!:;\/ &\t\n\r]', $prefix) if (length $1 >= 3);
            }

            $p += 1024;
        }
    } else {
        if ( $bigline =~ /[^ \t]/ ) {
            $self->update_pseudoword( 'trick', 'invisibleink', $encoded, $bigline );
	}
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
            $self->{htmlfontcolor__} = map_color( $self, 'black' );
        }

	# If we hit a table tag then any font information is lost
	
	if ( $tag =~ /^(table|td|tr|th)$/i ) {
	    $self->{htmlfontcolor__} = map_color( $self, 'black' );
	    $self->{htmlbackcolor__} = $self->{htmlbodycolor__};
	}

        return;
    }

    # Count the number of TD elements
    $self->update_pseudoword('html', 'td', $encoded, $tag ) if ( $tag =~ /^td$/i );

    my $attribute;
    my $value;

    # These are used to pass good values to update_word

    my $quote;
    my $end_quote;

    # Strip the first attribute while there are any attributes
    # Match the closing attribute character, if there is none
    # (this allows nested single/double quotes),
    # match a space or > or EOL

    my $original;

    while ( $arg =~ s/[ \t]*((\w+)[ \t]*=[ \t]*([\"\'])?(.*?)(\3|($|([ \t>]))))//i ) {
        $original  = $1;
        $attribute = $2;
        $value     = $4;
        $quote     = '';
        $end_quote = '[\> \t\&\n]';
        if (defined $3) {
            $quote     = $3;
            $end_quote = $3;
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

            # "CID:" links refer to an origin-controlled attachment to a html email.
            # Adding strings from these, even if they appear to be hostnames, may or
            # may not be beneficial

            if ($value =~ /^cid\:/i )
            {
                # TODO: Decide what to do here, ignoring CID's for now
            } else {

                my $host = add_url( $self, $value, $encoded, $quote, $end_quote, '', 1 );

                # If the host name is not blank (i.e. there was a hostname in the url
                # and it was an image, then if the host was not this host then report
                # an off machine image

                if ( ( $host ne '' ) && ( $tag =~ /^img$/i ) ) {
        	    if ( $host ne 'localhost' ) {
                        $self->update_pseudoword( 'html', 'imgremotesrc', $encoded, $original );
        	    }
                }

                next;
            }

            add_url( $self, $value, $encoded, $quote, $end_quote, '' );
            next;
        }

        # Tags with href attributes

        if ( $attribute =~ /^href$/i && $tag =~ /^(a|link|base|area)$/i )  {

            # Look for mailto:'s

            if ($value =~ /^mailto:/i) {
                if ( $tag =~ /^a$/ && $value =~ /^mailto:([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+?))([>\&\?\:\/]|$)/i )  {
                   update_word( $self, $1, $encoded, 'mailto:', ($3?'[\\\>\&\?\:\/]':$end_quote), '' );
                   add_url( $self, $2, $encoded, '@', ($3?'[\\\&\?\:\/]':$end_quote), '' );
                }
            } else {

                # Anything that isn't a mailto is probably an URL

                $self->add_url($value, $encoded, $quote, $end_quote, '');
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
            $self->{htmlfontcolor__} = map_color($self, $value);
			print "Set html font color to $self->{htmlfontcolor__}\n" if ( $self->{debug} );
        }

        if ( ( $attribute =~ /^text$/i ) && ( $tag =~ /^body$/i ) ) {
            update_word( $self, $value, $encoded, $quote, $end_quote, '' );
            $self->{htmlfontcolor__} = map_color($self, $value);
			print "Set html font color to $self->{htmlfontcolor__}\n" if ( $self->{debug} );
        }

        # The width and height of images

        if ( ( $attribute =~ /^(width|height)$/i ) && ( $tag =~ /^img$/i ) ) {
            $attribute = lc( $attribute );
            $self->update_pseudoword( 'html', "img$attribute$value", $encoded, $original );
        }

        # Font sizes

        if ( ( $attribute =~ /^size$/i ) && ( $tag =~ /^font$/i ) ) {
            $self->update_pseudoword( 'html', "fontsize$value", $encoded, $original );
        }

        # Tags with background colors

        if ( ( $attribute =~ /^(bgcolor|back)$/i ) && ( $tag =~ /^(td|table|body|tr|th|font)$/i ) ) {
            update_word( $self, $value, $encoded, $quote, $end_quote, '' );
            $self->{htmlbackcolor__} = map_color($self, $value);
			print "Set html back color to $self->{htmlbackcolor__}\n" if ( $self->{debug} );

            $self->{htmlbodycolor__} = $self->{htmlbackcolor__} if ( $tag =~ /^body$/i );
        }

        # Tags with a charset

        if ( ( $attribute =~ /^content$/i ) && ( $tag =~ /^meta$/i ) ) {
            if ( $value=~ /charset=([^ ]{1,40})[\"\>]?/ ) {
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
# $noadd        If defined indicates that only parsing should be done, no word updates
#
# Returns the hostname
#
# ---------------------------------------------------------------------------------------------
sub add_url
{
    my ($self, $url, $encoded, $before, $after, $prefix, $noadd) = @_;

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

    $protocol = $1 if ( $url =~ s/^([^:]*)\:\/\/// );

    # Remove any URL encoding (protocol may not be URL encoded)

    my $oldurl   = $url;
    my $percents =  ( $url =~ s/(%([0-9A-Fa-f]{2}))/chr(hex("0x$2"))/ge );

    if ( $percents > 0 ) {
        $self->update_pseudoword( 'html', 'encodedurl', $encoded, $oldurl ) if ( !defined( $noadd ) );
    }

    # Extract authorization information from the URL (e.g. http://foo@bar.com)

    $authinfo = $1 if ( $url =~ s/^(([[:alpha:]0-9\-_\.\;\:\&\=\+\$\,]+)(\@|\%40))+// );

    $self->update_pseudoword( 'html', 'authorization', $encoded, $oldurl ) if ( defined( $authinfo ) && ( $authinfo ne '' ) );

    if ( $url =~ s/^(([[:alpha:]0-9\-_]+\.)+)(com|edu|gov|int|mil|net|org|aero|biz|coop|info|museum|name|pro|[[:alpha:]]{2})([^[:alpha:]0-9\-_\.]|$)/$4/i ) {
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

    if ( !defined( $host ) || ( $host eq '' ) ) {
        print "no hostname found: [$temp_url]\n" if ($self->{debug});
        return '';
    }

    $port = $1 if ( $url =~ s/^\:(\d+)//);
    $path = $1 if ( $url =~ s/^([\\\/][^\#\?\n]*)($)?// );
    $query = $1 if ( $url =~ s/^[\?]([^\#\n]*|$)?// );
    $hash = $1 if ( $url =~ s/^[\#](.*)$// );

    if ( !defined( $protocol ) || ( $protocol =~ /^(http|https)$/ ) ) {
        $temp_before = $before;
        $temp_before = "\:\/\/" if (defined $protocol);
        $temp_before = "[\@]" if (defined $authinfo);

        $temp_after = $after;
        $temp_after = "[\#]" if (defined $hash);
        $temp_after = "[\?]" if (defined $query);
        $temp_after = "[\\\\\/]" if (defined $path);
        $temp_after = "[\:]" if (defined $port);

        update_word( $self, $host, $encoded, $temp_before, $temp_after, $prefix) if ( !defined( $noadd ) );

        # decided not to care about tld's beyond the verification performed when
        # grabbing $host
        # special subTLD's can just get their own classification weight (eg, .bc.ca)
        # http://www.0dns.org has a good reference of ccTLD's and their sub-tld's if desired

        if ( $hostform eq "name" ) {
            while ( $host =~ s/^([^\.])+\.(.*\.(.*))$/$2/ ) {
                update_word( $self, $2, $encoded, '[\.]', '[<]', $prefix) if ( !defined( $noadd ) );
            }
        }
    }

    # $protocol $authinfo $host $port $query $hash may be processed below if desired
    return $host;
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

    $line =~ s/[\r\n]+//gm;

    print "parse_html: [$line] " . $self->{in_html_tag__} . "\n" if $self->{debug};

    # Remove HTML comments and other tags that begin !

    while ( $line =~ s/(<!.*?>)// ) {
        $self->update_pseudoword( 'html', 'comment', $encoded, $1 );
        print "$line\n" if $self->{debug};
    }

    while ( $found && ( $line ne '' ) ) {
        $found = 0;

        # If we are in an HTML tag then look for the close of the tag, if we get it then
        # handle the tag, if we don't then keep building up the arguments of the tag

        if ( $self->{in_html_tag__} )  {
            if ( $line =~ s/^(.*?)>// ) {
                $self->{html_arg__} .= $1;
                $self->{in_html_tag__} = 0;
                $self->{html_tag__} =~ s/=\n ?//g;
                $self->{html_arg__} =~ s/=\n ?//g;
                update_tag( $self, $self->{html_tag__}, $self->{html_arg__}, $self->{html_end}, $encoded );
                $self->{html_tag__} = '';
                $self->{html_arg__} = '';
                $found = 1;
                next;
            } else {
                $self->{html_arg__} .= $line;
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
            $self->{html_tag__}    = $2;
            $self->{html_arg__}    = $3;
            $self->{in_html_tag__} = 1;
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

    # Variables to save header information to while parsing headers

    my $header = '';
    my $argument = '';

    # Clear the word hash

    $self->{content_type__} = '';

    # Used to return a colorize page

    my $colorized = '';

    # Base64 attachments are loaded into this as we read them

    $self->{base64__}       = '';

    # Variable to note that the temporary colorized storage is "frozen",
    # and what type of freeze it is (allows nesting of reasons to freeze
    # colorization)

    $self->{in_html_tag__} = 0;

    $self->{html_tag__}    = '';
    $self->{html_arg__}    = '';

    $self->{words__}        = {};
    $self->{msg_total__}    = 0;
    $self->{from__}         = '';
    $self->{to__}           = '';
    $self->{cc__}           = '';
    $self->{subject__}      = '';
    $self->{ut__}           = '';
    $self->{quickmagnets__} = {};

    $self->{htmlbackcolor__} = map_color( $self, 'white' );
    $self->{htmlfontcolor__} = map_color( $self, 'black' );

    $self->{in_headers__} = 1;

    $self->{first20__}      = '';
    $self->{first20count__} = 0;

    $colorized .= "<tt>" if ( $self->{color__} );

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

            if ($self->{color__}) {

                if (!$self->{in_html_tag__}) {
                    $colorized .= $self->{ut__};
                    $self->{ut__} = '';
                }

                $self->{ut__} .= splitline($line, $encoding);
            }

            if ($self->{in_headers__}) {

                # temporary colorization while in headers is handled within parse_header

                $self->{ut__} = '';

                # Check for blank line signifying end of headers

                if ( $line =~ /^(\r\n|\r|\n)/) {

                     # Parse the last header
                    ($mime,$encoding) = $self->parse_header($header,$argument,$mime,$encoding);

                    # Clear the saved headers
                    $header   = '';
                    $argument = '';

                    $self->{ut__} .= splitline( "\015\012", 0 );

                    $self->{in_headers__} = 0;
                    print "Header parsing complete.\n" if $self->{debug};

                    next;
                }


                # If we have an email header then just keep the part after the :

                if ( $line =~ /^([A-Za-z-]+):[ \t]*([^\n\r]*)/ )  {

                    # Parse the last header

                    ($mime,$encoding) = $self->parse_header($header,$argument,$mime,$encoding) if ($header ne '');

                    # Save the new information for the current header

                    $header   = $1;
                    $argument = $2;
                    next;
                }

                # Append to argument if the next line begins with whitespace (isn't a new header)

                if ( $line =~ /^([\t ].*?)(\r\n|\r|\n)/ ) {
                    $argument .= "\015\012" . $1;
                }
                next;
            }

            # If we are in a mime document then spot the boundaries

            if ( ( $mime ne '' ) && ( $line =~ /^\-\-($mime)(\-\-)?/ ) ) {

                # approach each mime part with fresh eyes

                $encoding = '';

                if (!defined $2) {
                    print "Hit MIME boundary --$1\n" if $self->{debug};
                    $self->{in_headers__} = 1;
                } else {

                    $self->{in_headers__} = 0;

                    my $boundary = $1;

                    print "Hit MIME boundary terminator --$1--\n" if $self->{debug};

                    # escape to match escaped boundary characters

                    $boundary =~ s/(.*)/\Q$1\E/g;

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
                    $self->{in_headers__} = 0;
                }

                next;
            }

            # If we are still in the headers then make sure that we are on a line with whitespace
            # at the start

            if ( $self->{in_headers__} ) {
                if ( $line =~ /^[ \t\r\n]/ ) {
                    next;
                }
            }

            # If we are doing base64 decoding then look for suitable lines and remove them
            # for decoding

            if ( $encoding =~ /base64/i ) {
                $line =~ s/[\r\n]//g;
                $line =~ s/!$//;
                $self->{base64__} .= $line;

                next;
            }

            next if ( !defined($line) );

            # Look for =?foo? syntax that identifies a charset

            if ( $line =~ /=\?([^ ]{1,40})\?/ ) {
                update_word( $self, $1, 0, '', '', 'charset' );
            }

            # Decode quoted-printable

            if ( $encoding =~ /quoted\-printable/i ) {
                $line       = decode_qp( $line );
                $line       =~ s/[\r\n]+$//g;
                $self->{ut__} = decode_qp( $self->{ut__} ) if ( $self->{color__} );
            }

            parse_html( $self, $line, 0 );
        }
    }

    # If we reach here and disover that we think that we are in an unclosed HTML tag then there
    # has probably been an error (such as a < in the text messing things up) and so we dump
    # whatever is stored in the HTML tag out

    if ( $self->{in_html_tag__} ) {
        add_line( $self, $self->{html_tag__} . ' ' . $self->{html_arg__}, 0, '' );
    }

    $colorized .= clear_out_base64( $self );
    close MSG;

    $self->{in_html_tag__} = 0;

    if ( $self->{color__} )  {
        $colorized .= $self->{ut__} if ( $self->{ut__} ne '' );

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
# If there's anything in the {base64__} then decode it and parse it, returns colorization
# information to be added to the colorized output
#
# ---------------------------------------------------------------------------------------------
sub clear_out_base64
{
    my ( $self ) = @_;

    my $colorized = '';

    if ( $self->{base64__} ne '' ) {
        my $decoded = '';

        $self->{ut__}     = '' if $self->{color__};
        $self->{base64__} =~ s/ //g;

        print "Base64 data: " . $self->{base64__} . "\n" if ($self->{debug});

        $decoded = decode_base64( $self->{base64__} );
        parse_html( $self, $decoded, 1 );

        print "Decoded: " . $decoded . "\n" if ($self->{debug});

        $self->{ut__} = "<b>Found in encoded data:</b> " . $self->{ut__} if ( $self->{color__} );

            if ( $self->{color__} )  {
                if ( $self->{ut__} ne '' )  {
                    $colorized  = $self->{ut__};
                    $self->{ut__} = '';
            }
        }
    }

    $self->{base64__} = '';

    return $colorized;
}

# ---------------------------------------------------------------------------------------------
#
# decode_string - Decode MIME encoded strings used in the header lines in email messages
#
# $mystring     - The string that neeeds decode
#
# Return the decoded string, this routine recognizes lines of the form
#
# =?charset?[BQ]?text?=
#
# A B indicates base64 encoding, a Q indicates quoted printable encoding
# ---------------------------------------------------------------------------------------------
sub decode_string
{
    # I choose not to use "$mystring = MIME::Base64::decode( $1 );" because some spam mails
    # have subjects like: "Subject: adjpwpekm =?ISO-8859-1?Q?=B2=E1=A4=D1=AB=C7?= dopdalnfjpw".
    # Therefore, it will be better to store the decoded text in a temporary variable and substitute
    # the original string with it later. Thus, this subroutine returns the real decoded result.

    my ( $self, $mystring ) = @_;

    my $decode_it = '';

    while ( $mystring =~ /=\?[\w-]+\?(B|Q)\?(.*)\?=/ig ) {
        if ($1 eq "B") {
            $decode_it = decode_base64( $2 );
            $mystring =~ s/=\?[\w-]+\?B\?(.*)\?=/$decode_it/i;
        } elsif ($1 eq "Q") {
           $decode_it = $2;
           $decode_it =~ s/\_/=20/g;
           $decode_it = decode_qp( $decode_it );
           $mystring =~ s/=\?[\w-]+\?Q\?(.*)\?=/$decode_it/i;
        }
    }

    return $mystring;
}

# ---------------------------------------------------------------------------------------------
#
# get_header - Returns the value of the from, to, subject or cc header
#
# $header      Name of header to return (note must be lowercase)
#
# ---------------------------------------------------------------------------------------------
sub get_header
{
    my ( $self, $header ) = @_;

    return $self->{$header . '__'};
}


# ---------------------------------------------------------------------------------------------
#
# parse_header - Performs parsing operations on a message header
#
# $header       Name of header being processed
# $argument     Value of header being processed
# $mime         The presently saved mime boundaries list
# $encoding     Current message encoding
#
# ---------------------------------------------------------------------------------------------
sub parse_header
{
    my ($self, $header, $argument, $mime, $encoding) = @_;

    print "Header ($header) ($argument)\n" if ($self->{debug});

    if ( $self->{color__} ) {
        my $color     = $self->{bayes__}->get_color( "header:$header" );

        my $fix_argument = $argument;
        $fix_argument =~ s/</&lt;/g;
        $fix_argument =~ s/>/&gt;/g;

        $self->{ut__} =  "<b><font color=\"$color\">$header</font></b>: $fix_argument\015\012";
    }

    # After a discussion with Tim Peters and some looking at emails
    # I'd received I discovered that the header names (case sensitive) are
    # very significant in identifying different types of mail, for example
    # much spam uses MIME-Version, MiME-Version and Mime-Version

    $self->update_pseudoword( 'header', $header, 0, $header );

    # Check the encoding type in all RFC 2047 encoded headers

    if ( $argument =~ /=\?([^ ]{1,40})\?(Q|B)/i ) {
            update_word( $self, $1, 0, '', '', 'charset' );
    }

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

    if ( $header =~ /^(From|To|Cc|Reply\-To)$/i ) {

        # These headers at least can be decoded

        $argument = $self->decode_string( $argument );

        if ( $argument =~ /=\?([^ ]{1,40})\?/ ) {
            update_word( $self, $1, 0, '', '', 'charset' );
        }

        if ( $header =~ /^From$/i )  {
            $self->{from__} = $argument if ( $self->{from__} eq '' ) ;
            $prefix = 'from';
            push @{$self->{quickmagnets__}{$prefix}}, $argument if ($argument ne '');
        }

        if ( $header =~ /^To$/i ) {
            $prefix = 'to';
            $self->{to__} = $argument if ( $self->{to__} eq '' );
        }

        if ( $header =~ /^Cc$/i ) {
            $prefix = 'cc';
            $self->{cc__} = $argument if ( $self->{cc__} eq '' );
        }

        while ( $argument =~ s/<([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+?))>// )  {
            update_word($self, $1, 0, ';', '&',$prefix);
            add_url($self, $2, 0, '@', '[&<]',$prefix);
        }

        while ( $argument =~ s/([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+))// )  {
            update_word($self, $1, 0, '', '',$prefix);
            add_url($self, $2, 0, '@', '',$prefix);
        }

        add_line( $self, $argument, 0, $prefix );
        return ($mime, $encoding);
    }

    if ( $header =~ /^Subject$/i ) {
        $prefix = 'subject';
        $argument = $self->decode_string( $argument );
        $self->{subject__} = $argument if ( ( $self->{subject__} eq '' ) );
    }

    $self->{date__} = $argument if ( $header =~ /^Date/i );

    # Look for MIME

    if ( $header =~ /^Content-Type$/i ) {
        if ( $argument =~ /charset=\"?([^\" ]{1,40})\"?/ ) {
            update_word( $self, $1, 0, '' , '', 'charset' );
        }

        if ( $argument =~ /^(.*?)(;)/ ) {
            print "Set content type to $1\n" if $self->{debug};
            $self->{content_type__} = $1;
        }

        if ( $argument =~ /multipart\//i ) {
            my $boundary = $argument;

            if ( $boundary =~ /boundary= ?(\"([A-Z0-9\'\(\)\+\_\,\-\.\/\:\=\?][A-Z0-9\'\(\)\+_,\-\.\/:=\? ]{0,69})\"|([^\(\)\<\>\@\,\;\:\\\"\/\[\]\?\=]{1,70}))/i ) {

                $boundary = ($2 || $3);

                $boundary =~ s/(.*)/\Q$1\E/g;

                if ($mime ne '') {

                    # Fortunately the pipe character isn't a valid mime boundary character!

                    $mime = join('|', $mime, $boundary);
                } else {
                    $mime = $boundary;
                }
                print "Set mime boundary to " . $mime . "\n" if $self->{debug};
                return ($mime, $encoding);
            }
        }
        return ($mime, $encoding);
    }

    # Look for the different encodings in a MIME document, when we hit base64 we will
    # do a special parse here since words might be broken across the boundaries

    if ( $header =~ /^Content-Transfer-Encoding$/i ) {
        $encoding = $argument;
        print "Setting encoding to $encoding\n" if $self->{debug};
        my $compact_encoding = $encoding;
        $compact_encoding =~ s/[^A-Za-z0-9]//g;
        $self->update_pseudoword( 'encoding', $compact_encoding, 0, $encoding );
        return ($mime, $encoding);
    }

    # Some headers to discard

    return ($mime, $encoding) if ( $header =~ /^(Thread-Index|X-UIDL|Message-ID|X-Text-Classification|X-Mime-Key)$/i );

    # Some headers should never be RFC 2047 decoded

    $argument = $self->decode_string($argument) unless ($header =~ /^(Revceived|Content\-Type|Content\-Disposition)$/i);

    add_line( $self, $argument, 0, $prefix );

    return ($mime, $encoding);
}


# ---------------------------------------------------------------------------------------------
#
# splitline - Escapes characters so a line will print as plain-text within a HTML document.
#
# $line         The line to escape
# $encoding     The value of any current encoding scheme
#
# ---------------------------------------------------------------------------------------------

sub splitline
{
    my ($line, $encoding) = @_;
    $line =~ s/([^\r\n]{100,120} )/$1\r\n/g;
    $line =~ s/([^ \r\n]{120})/$1\r\n/g;

    $line =~ s/</&lt;/g;
    $line =~ s/>/&gt;/g;

    if ( $encoding =~ /quoted\-printable/i ) {
        $line =~ s/=3C/&lt;/g;
        $line =~ s/=3E/&gt;/g;
    }

    $line =~ s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;

    return $line;
}

# GETTERS/SETTERS

sub first20
{
   my ( $self ) = @_;

   return $self->{first20__};
}

sub quickmagnets
{
   my ( $self ) = @_;

   return $self->{quickmagnets__};
}

1;


