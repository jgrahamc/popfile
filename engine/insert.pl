# ---------------------------------------------------------------------------------------------
#
# insert.pl --- Inserts a mail message into a specific class
#
# Copyright (c) 2002 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

use strict;

if ( $#ARGV >= 1 )
{
    my $class    = $ARGV[0];
    
    # Make sure that the extract directory exists
    print "1. Creating extraction directory\n";
    mkdir( 'corpus' );
    
    # Create the appropriate class directory
    print "2. Creating $class directory\n";
    mkdir( "corpus/$class" );
    
    my $pattern = $ARGV[1];
    my @files   = glob $pattern;

    foreach my $file (@files)
    {
        # Parse the mailfile and remove junk that isn't useful
        print "3. Parsing $file\n";

        open MAILFILE, "<$file";
        open EXTRACTED, ">>corpus/$class/sample";

        while ( <MAILFILE> )
        {
            if ( /[^ ]+: / ) 
            {
                if ( ( /From: (.*)/ ) || ( /Subject: (.*)/ ) || ( /Cc: (.*)/i ) || ( /To: (.*)/ ) ) 
                {
                    print EXTRACTED "$1\r\n";
                }

                next;
            }

            if ( ( ! /^[^ ]+: / ) && ( ! /^[^ ]{50}/ ) && ( ! /^\t/ ) )
            {
                print EXTRACTED $_;

                next;
            }
        }

        close EXTRACTED;
        close MAILFILE;
    }
    
    # Done
    print "4. Done\n";
}
else
{
    print "Error: wrong number of command line arguments\n\n";
    print "insert class mailfile - parses mailfile and classifies it as 'class'\n\n";
}
