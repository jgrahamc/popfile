package Classifier::WordMangle;

# ---------------------------------------------------------------------------------------------
#
# WordMangle.pm --- Mangle words for better classification
#
# ---------------------------------------------------------------------------------------------

use strict;

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------

sub new
{
    my $type = shift;
    my $self;

    $self->{stop} = {
          'all', 1, 
          'also', 1, 
          'and', 1, 
          'any', 1, 
          'are', 1, 
          'ask', 1, 
          'but', 1, 
          'can', 1, 
          'com', 1, 
          'did', 1, 
          'edu', 1, 
          'etc', 1, 
          'for', 1, 
          'from', 1, 
          'had', 1, 
          'has', 1, 
          'have', 1, 
          'her', 1, 
          'him', 1, 
          'his', 1, 
          'inc', 1, 
          'its', 1, 
          'it\'s', 1, 
          'ltd', 1, 
          'may', 1, 
          'not', 1, 
          'off', 1, 
          'our', 1, 
          'out', 1, 
          'she', 1, 
          'the', 1, 
          'this', 1, 
          'yes', 1, 
          'yet', 1, 
          'you', 1, 
          'http', 1,
          'https', 1,
          'mailto', 1,
          'com',  1,
          'with',  1,
          'your',  1,
          'that',  1,
          'org',  1,
          'cgi',  1,
          'net',  1,
          'www',  1,
          'src',  1,
          'smtp', 1,
          'nbsp', 1,
          'esmtp', 1,
          'align', 1,
          'valign', 1,
          'width', 1,
          'height', 1,
          'border', 1,
            'abbrev', 1,  
            'acronym', 1,  
            'address', 1,  
            'applet', 1,  
            'area', 1,  
            'author', 1,  
            'banner', 1,  
            'base', 1,  
            'basefont', 1,  
            'bgsound', 1,  
            'big', 1,  
            'blink', 1,  
            'blockquote', 1,  
            'body', 1,  
            'caption', 1,  
            'center', 1,  
            'cite', 1,  
            'code', 1,  
            'col', 1,  
            'colgroup', 1,  
            'del', 1,  
            'dfn', 1,  
            'dir', 1,  
            'div', 1,  
            'embed', 1,  
            'fig', 1,  
            'font', 1,  
            'form', 1,  
            'frame', 1,  
            'frameset', 1,  
            'head', 1,  
            'html', 1,  
            'iframe', 1,  
            'img', 1,  
            'input', 1,  
            'ins', 1,  
            'isindex', 1,  
            'kbd', 1,  
            'lang', 1,  
            'link', 1,  
            'listing', 1,  
            'map', 1,  
            'marquee', 1,  
            'math', 1,  
            'menu', 1,  
            'meta', 1,  
            'multicol', 1,  
            'nobr', 1,  
            'noframes', 1,  
            'note', 1,  
            'overlay', 1,  
            'param', 1,  
            'person', 1,  
            'plaintext', 1,  
            'pre', 1,  
            'range', 1,  
            'samp', 1,  
            'script', 1,  
            'select', 1,  
            'small', 1,  
            'spacer', 1,  
            'spot', 1,  
            'strike', 1,  
            'strong', 1,  
            'sub', 1,  
            'sup', 1,  
            'tab', 1,  
            'table', 1,  
            'tbody', 1,  
            'textarea', 1,  
            'textflow', 1,  
            'tfoot', 1,  
            'thead', 1,  
            'title', 1,  
            'var', 1,  
            'wbr', 1,  
            'xmp', 1,   
            'mon', 1, 
            'tue', 1, 
            'wed', 1, 
            'thu', 1, 
            'fri', 1, 
            'sat', 1, 
            'sun', 1, 
            'jan', 1, 
            'feb', 1, 
            'mar', 1, 
            'apr', 1, 
            'may', 1, 
            'jun', 1, 
            'jul', 1, 
            'aug', 1, 
            'sep', 1, 
            'oct', 1, 
            'nov', 1, 
            'dec', 1, 
            'est', 1, 
            'edt', 1, 
            'cst', 1, 
            'cdt', 1, 
            'pdt', 1, 
            'pst', 1, 
            'gmt', 1, 
            'subject', 1, 
            'date', 1, 
            'localhost', 1, 
            'received', 1, 
          'helo', 1,
          'charset', 1,
          'encoding', 1,
          'htm', 1,
          'mail', 1,
           'alt', 1,
          'cellspacing', 1,
          'bgcolor', 1,
          'serif', 1,
          'sans', 1,
          'helvetica', 1,
          'color', 1,
          'message', 1,
          'path', 1,
          'return', 1,
          'span', 1,
          'mbox', 1,
          'status', 1,
         };

    return bless $self, $type;
}

# ---------------------------------------------------------------------------------------------
#
# mangle
#
# Mangles a word into either the empty string to indicate that the word should be ignored
# or the canonical form
#
# ---------------------------------------------------------------------------------------------

sub mangle
{
    my ($self, $word) = @_;

    # all words are treated as lowercase
    
    $word = lc($word);

    # stop words are ignored
    
    if ( $self->{stop}{$word} ) 
    {
        return '';
    }

    # Long words are ignored also
    if ( length($word) > 45 ) 
    {
        return "";
    }

    return $word;
}

1;
