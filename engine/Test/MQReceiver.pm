package Test::MQReceiver;

# ---------------------------------------------------------------------------------------------
#
# Test::MQReceiver.  Helper class for the TestMQ.tst suite.
#
# Copyright (c) 2003 John Graham-Cumming
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
    my ( $self, $type, $message, $parameter ) = @_;

    push @{$self->{messages__}}, [ $type, $message, $parameter ];
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

1;
