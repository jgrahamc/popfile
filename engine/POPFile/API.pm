package POPFile::API;

# ----------------------------------------------------------------------------
#
# API.pm --  The API to POPFile available through XML-RPC
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

sub new
{
    my $type = shift;
    my $self;

    # This will store a reference to the classifier object

    $self->{c} = 0;
        
    bless $self, $type;
    return $self;
}


# I'm generally against doing obscure things in Perl because it makes the code
# hard to read, but since this entire file is a bunch of wrappers for the
# API in Classifier::Bayes I'm going to do something really odd looking for the
# sake of readability here.
#
# Take for example the get_session_key wrapper for get_session_key.
# It contains the line:
#
#    shift->{c}->get_session_key( @_ )
#
# What this does is the following:
#
# 1. The parameters for get_session_key are as usual in @_.  The first
#    parameter (since this is an object) is a reference to this object.
#
# 2. We use 'shift' to get the reference to us (in all other places I
#    would call this $self).
#
# 3. We have a object variable called 'c' that contains a reference to the
#    Classifier::Bayes object we need to make the real call in.
#
# 4. So shift->{c} is a reference to Classifier::Bayes and hence we can do
#    shift->{c}->get_session_key() to call the real API.
#
# 5. shift has also popped the first parameter off of @_ leaving the rest of
#    the parameters for get_session_key in @_.  Hence we can just pass in @_
#    for all the parameters.
#
# 6. return is optional in Perl, so for the sake of horizontal space here I
#    omit it.

sub get_session_key            { shift->{c}->get_session_key( @_ ); }
sub release_session_key        { shift->{c}->release_session_key( @_ ); }
sub classify                   { shift->{c}->classify( @_ ); }
sub is_pseudo_bucket           { shift->{c}->is_pseudo_bucket( @_ ); }
sub is_bucket                  { shift->{c}->is_bucket( @_ ); }
sub get_bucket_word_count      { shift->{c}->get_bucket_word_count( @_ ); }
sub get_word_count             { shift->{c}->get_word_count( @_ ); }
sub get_count_for_word         { shift->{c}->get_count_for_word( @_ ); }
sub get_bucket_unique_count    { shift->{c}->get_bucket_unique_count( @_ ); }
sub get_unique_word_count      { shift->{c}->get_unique_word_count( @_ ); }
sub get_bucket_color           { shift->{c}->get_bucket_color( @_ ); }
sub set_bucket_color           { shift->{c}->set_bucket_color( @_ ); }
sub get_bucket_parameter       { shift->{c}->get_bucket_parameter( @_ ); }
sub set_bucket_parameter       { shift->{c}->set_bucket_parameter( @_ ); }
sub create_bucket              { shift->{c}->create_bucket( @_ ); }
sub delete_bucket              { shift->{c}->delete_bucket( @_ ); }
sub rename_bucket              { shift->{c}->rename_bucket( @_ ); }
sub add_messages_to_bucket     { shift->{c}->add_messages_to_bucket( @_ ); }
sub add_message_to_bucket      { shift->{c}->add_message_to_bucket( @_ ); }
sub remove_message_from_bucket { shift->{c}->remove_message_from_bucket( @_ ); }
sub clear_bucket               { shift->{c}->clear_bucket( @_ ); }
sub clear_magnets              { shift->{c}->clear_magnets( @_ ); }
sub create_magnet              { shift->{c}->create_magnet( @_ ); }
sub delete_magnet              { shift->{c}->delete_magnet( @_ ); }
sub magnet_count               { shift->{c}->magnet_count( @_ ); }
sub add_stopword               { shift->{c}->add_stopword( @_ ); }
sub remove_stopword            { shift->{c}->remove_stopword( @_ ); }
sub get_html_colored_message   { shift->{c}->get_html_colored_message( @_); }

# These APIs return lists and need to be altered to arrays before returning
# them through XMLRPC otherwise you get the wrong result.

sub get_buckets                { [ shift->{c}->get_buckets( @_ ) ]; }
sub get_pseudo_buckets         { [ shift->{c}->get_pseudo_buckets( @_ ) ]; }
sub get_all_buckets            { [ shift->{c}->get_all_buckets( @_ ) ]; }
sub get_buckets_with_magnets   { [ shift->{c}->get_buckets_with_magnets( @_ ) ]; }
sub get_magnet_types_in_bucket { [ shift->{c}->get_magnet_types_in_bucket( @_ ) ]; }
sub get_magnets                { [ shift->{c}->get_magnets( @_ ) ]; }
sub get_magnet_types           { [ shift->{c}->get_magnet_types( @_ ) ]; }
sub get_stopword_list          { [ shift->{c}->get_stopword_list( @_ ) ]; }
sub get_bucket_word_list       { [ shift->{c}->get_bucket_word_list( @_ ) ]; }
sub get_bucket_word_prefixes   { [ shift->{c}->get_bucket_word_prefixes( @_ ) ]; }

# This API is used to add a message to POPFile's history, process the message
# and do all the things POPFile would have done if it had received the message
# through its proxies.
#
# Pass in the name of file to read and a file to write.  The read file
# will be processed and the out file created containing the processed
# message.
#
# Returns the same output as classify_and_modify (which contains the
# slot ID for the newly added message, the classification and magnet
# ID).  If it fails it returns undef.

sub handle_message
{
    my ( $self, $session, $in, $out ) = @_;

    # Convert the two files into streams that can be passed to the
    # classifier

    open IN, "<$in" or return undef;
    open OUT, ">$out" or return undef;

    my @result = $self->{c}->classify_and_modify(
        $session, \*IN, \*OUT, undef );

    close OUT;
    close IN;

    return @result;
}

1;
