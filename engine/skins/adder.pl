my @dirs = glob '*';

foreach my $dir (@dirs) {
   next if ( $dir eq 'CVS' );
   next if ( $dir eq 'blue' );
   next if ( $dir eq 'adder.pl' );
   next if ( $dir =~ /\./ );

   print "Doing $dir\n";
   my $rc = system( "cvs add $dir" ) >> 8;
   print "Failed on add $dir" if ( $rc != 0 );
   $rc = system( "cvs add $dir/*" ) >> 8;
   print "Failed on add $dir/*" if ( $rc != 0 );
}
