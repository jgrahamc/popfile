#!/usr/bin/perl
# ----------------------------------------------------------------------------
#
# update_tld.pl - Utility to update TLD test file
#
# Copyright (c) 2001-2011 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
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

#!/usr/bin/perl

use strict;
use LWP::Simple;

# Download TLD list

my $tld_text = get("http://data.iana.org/TLD/tlds-alpha-by-domain.txt");

#print $tld_text;

my @tld_list = split( /\n/, $tld_text );
#print @tld_list;

# Create test mail files

open my $mail, ">TestMails/TestMailParse099.msg" or die @!;
open my $word, ">TestMails/TestMailParse099.wrd" or die @!;
open my $class, ">TestMails/TestMailParse099.cls" or die $@;
open my $color, ">TestMails/TestMailParse099.cam" or die $@;

print $mail "Subject: TLD test\n\n";
print $word "subject:tld 1\nsubject:test 1\nheader:Subject 1\n";
print $class "spam\n";
print $color "Subject: [spam] TLD test\n";
print $color "X-Text-Classification: spam\n";
print $color "X-POPFile-Link: http://127.0.0.1:8080/jump_to_message?view=popfile0=0.msg\n\n";

foreach my $tld (@tld_list) {
    # Skip comment
    next if ( $tld =~ /^#/ );

    # Skip IDN (internationalized domain names)
    next if ( $tld =~ /^XN--/ );

    $tld = lc $tld;
    print $mail "or.$tld\n";
    print $word "or.$tld 1\n";
    print $word ".$tld 1\n";
    print $color "or.$tld\n";
}

close $mail;
close $word;
close $class;
close $color;

exit 0;

1;
