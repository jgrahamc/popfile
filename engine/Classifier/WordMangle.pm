package Classifier::WordMangle;

# ---------------------------------------------------------------------------------------------
#
# WordMangle.pm --- Mangle words for better classification
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

#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------

sub new
{
    my $type = shift;
    my $self;

    $self->{stop__} = {};

    bless $self, $type;

    $self->load_stopwords();

    return $self;
}

# ---------------------------------------------------------------------------------------------
#
# load_stopwords, save_stopwords - load and save the stop word list in the stopwords file
#
# ---------------------------------------------------------------------------------------------
sub load_stopwords
{
    my ($self) = @_;

    if ( open STOPS, "<stopwords" ) {
        delete $self->{stop__};
        while ( <STOPS> ) {
            s/[\r\n]//g;
            $self->{stop__}{$_} = 1;
        }

        close STOPS;
    }
}

sub save_stopwords
{
    my ($self) = @_;

    if ( open STOPS, ">stopwords" ) {
        for my $word (keys %{$self->{stop__}}) {
            print STOPS "$word\n";
        }

        close STOPS;
    }
}

# ---------------------------------------------------------------------------------------------
#
# mangle
#
# Mangles a word into either the empty string to indicate that the word should be ignored
# or the canonical form
#
# $word         The word to either mangle into a nice form, or return empty string if this word
#               is to be ignored
# $allow_colon  Set to any value allows : inside a word, this is used when mangle is used
#               while loading the corpus in Bayes.pm but is not used anywhere else, the colon
#               is used as a separator to indicate special words found in certain lines
#               of the mail header
#
# $ignore_stops If defined ignores the stop word list
#
# ---------------------------------------------------------------------------------------------
sub mangle
{
    my ($self, $word, $allow_colon, $ignore_stops) = @_;

    # All words are treated as lowercase

    $word = lc($word);

    # Stop words are ignored

    return '' if ( ( $self->{stop__}{$word} ) && ( !defined( $ignore_stops ) ) );

    # Remove characters that would mess up a Perl regexp and replace with .

    $word =~ s/(\+|\/|\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/\./g;

    # Long words are ignored also

    return '' if ( length($word) > 45 );

    # Ditch long hex numbers

    return '' if ( $word =~ /^[A-F0-9]{8,}$/i );

    # Colons are forbidden inside words, we should never get passed a word
    # with a colon in it here, but if we do then we strip the colon.  The colon
    # is used as a separator between a special identifier and a word, see MailParse.pm
    # for more details

    $word =~ s/://g if ( !defined( $allow_colon ) );

    return $word;
}

# ---------------------------------------------------------------------------------------------
#
# add_stopword, remove_stopword
#
# Adds or removes a stop word
#
# $stopword    The word to add or remove
#
# Returns 1 if successful, or 0 for a bad stop word
# ---------------------------------------------------------------------------------------------

sub add_stopword
{
    my ( $self, $stopword ) = @_;

    $stopword = $self->mangle( $stopword, 0, 1 );

    if ( $stopword =~ /[^[:lower:]\-_\.\@0-9]/i ) {
        return 0;
    }

    if ( $stopword ne '' ) {
        $self->{stop__}{$stopword} = 1;
        $self->save_stopwords();

       return 1;
    }

    return 0;
}

sub remove_stopword
{
    my ( $self, $stopword ) = @_;

    $stopword = $self->mangle( $stopword, 0, 1 );

    if ( $stopword =~ /[^[:lower:]\-_\.\@0-9]/i ) {
        return 0;
    }

    if ( $stopword ne '' ) {
        delete $self->{stop__}{$stopword};
        $self->save_stopwords();

        return 1;
    }

    return 0;
}

# GETTER/SETTERS

sub stopwords
{
    my ( $self, $value ) = @_;

    if ( defined( $value ) ) {
        %{$self->{stop__}} = %{$value};
    }

    return keys %{$self->{stop__}};
}

1;
