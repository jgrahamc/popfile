package Test::SimpleTemplate;

# ----------------------------------------------------------------------------
#
# A helper class for testing template use
#
# Copyright (c) 2001-2004 John Graham-Cumming
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
# ----------------------------------------------------------------------------


#----------------------------------------------------------------------------
# new
#
#   Class new() function
#----------------------------------------------------------------------------
sub new
{
    my $type = shift;

    $self->{params__} = {};

    return bless $self, $type;
}

#----------------------------------------------------------------------------
# param
#
#   A re-implementation of HTML::Template->param() that does nothing except
#   blindly modify an internal hash without ever dying or failing
#   All three calling modes of HTML::Template->param() are supported
#   (parameterless, value get, value set)
#----------------------------------------------------------------------------

sub param
{
    my $self = shift;

    $params = $self->{params__};

    return keys(%{$params}) unless scalar(@_);

    my $first = shift;
    my $type = ref $first;

    # the one-parameter case - could be a parameter value request or a
    # hash-ref.
    if (!scalar(@_) and !length($type)) {

        return undef unless (exists($params->{$first}) and
                             defined($params->{$first}));

        return $params->{$first};
    }

    if (!scalar(@_)) {
        push( @_, %$first );
    } else {
        unshift( @_, $first );
    }


    my %hash = @_;

    # Take each input and copy it into our params__ hash

    foreach my $key ( keys( %hash ) ) {
        $self->{params__}->{$key} = $hash{$key};
    }
}

1;