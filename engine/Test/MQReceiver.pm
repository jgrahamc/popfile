package Test::MQReceiver;

# ---------------------------------------------------------------------------------------------
#
# Test::MQReceiver.  Helper class for the TestMQ.tst suite.
#
# Copyright (c) 2003-2004 John Graham-Cumming
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

sub new
{
    my $type = shift;
    my $self;

    # This is a queue of the messages that have been delivered to
    # this class.  It is read and cleared with the read method

    $self->{messages__} = ();

    return bless $self, $type;
}


# ---------------------------------------------------------------------------------------------
#
# deliver
#
# Called to deliver a message from the MQ.
#
# ---------------------------------------------------------------------------------------------
sub deliver
{
    my ( $self, $type, @message ) = @_;

    push @{$self->{messages__}}, [ $type, \@message ];
}

# ---------------------------------------------------------------------------------------------
#
# read
#
# Reads the queue of messages received and clears it
#
# ---------------------------------------------------------------------------------------------
sub read
{
    my ( $self ) = @_;

    my @messages = @{$self->{messages__}};

    $self->{messages__} = ();

    return @messages;
}

sub name
{
    return 'mqreceiver';
}

1;
