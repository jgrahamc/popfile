# ---------------------------------------------------------------------------------------------
#
# Devel::TestCoverage - Module to measure code coverage in the test suite
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
# ---------------------------------------------------------------------------------------------

package Devel::TestCoverage;

package DB;

# This hash will store a count of the number of times each line is executed # in each file,
# it is in fact a hash of hashes used as
# $count{filename}{linenumber}
my %count;

# This is called when we begin the code coverage (or debugging) session
BEGIN
{
	# We want to look inside subroutines so tell the debugger to trace into
	# them

	$DB::trace = 1;
}

# Perl will call this function for every line of code it executes.  We keep
# a count for each time a line is executed
sub DB
{
	# The caller function we till us what line of code, in which file and
	# package called us
	my ($package, $file, $line) = caller;

	# A specific line in a specific file just got executed, we remove
	# certain references to eval code that we wont have traced into
	$count{$file}{$line} += 1 if ( ( $file =~ /\(eval/ ) == 0 );
}

END
{
        # This hash will map file names of POPFile modules to coverage
        my %files;

	# Print out information for each file
	for my $file (keys %count)	
	{
	    if ( ( $file =~ /^[^\/]/ ) && ( $file ne 'tests.pl' ) && !( $file =~ /^Test\// ) ) {
		my $current_line   = 0;
                my $block_executed = 0;
		
		open SOURCE_FILE, "<$file";
		
		# Read in each line of the source file and keep track of whether 
		# it was executed or not using a new couple of keys in the 
		# %count hash for each file: total_lines, total_executable_lines 
		# and total_executed
		while (<SOURCE_FILE>)
		{
			# Keep count of the total number of lines in this file
			$current_line              += 1;
			$count{$file}{total_lines} += 1;
			
			# We do not count lines that are blank or exclusively 
			# comments or just have braces on them or
			# just an else or just a subroutine definition
			if ( ( ( /^\s*\#/                   == 0 ) &&
                               ( /^\s*$/                    == 0 ) &&
                               ( /^\s*(\{|\}|else|\s)+\s*$/ == 0 ) &&
                               ( /^\s*sub \w+( \{)?\s*$/    == 0 ) &&
                               ( /^\s*package /             == 0 ) ) || ( $block_executed ) ) {
		            $count{$file}{total_executable_lines} += 1;
				
			    # If this line was executed then keep count of
			    # that fact
				
                            if ( ( $count{$file}{$current_line} > 0 ) || ( $block_executed ) ) {
			        $count{$file}{total_executed} += 1;

                                # Check to see if the special comment PROFILE BLOCK START is on the line
                                # and if so set the block mode where we count lines as being executed
                                # in the block if the first line was

   		                if ( /\# PROFILE BLOCK START/ ) {
                                    $block_executed = 1;
		                }

   		                if ( /\# PROFILE BLOCK STOP/ ) {
                                    $block_executed = 0;
		                }
			    } else {
#                                print "$file:$current_line $_" if ( $file =~/MailParse/);
                            }
			}

		}
		
                $files{$file} = int(100 * $count{$file}{total_executed} / $count{$file}{total_executable_lines}) unless ( $count{$file}{total_executable_lines} == 0 );
		
		close SOURCE_FILE;
          }
     }

	foreach my $file (sort {$files{$b} <=> $files{$a}} keys %files) {
	    print sprintf( "Coverage of %-32s %d%%\n", "$file...", $files{$file});
	}
}

1;
