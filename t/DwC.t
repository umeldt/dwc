use strict;
use warnings;
use utf8;

use Test::More tests => 7;
BEGIN { use_ok('DwC') };

my $dwc = DwC->new({
  institutionCode => "O",
  collectionCode => "L",
  catalogNumber => "1"
});

ok($dwc->triplet eq "O:L:1");

my $output;
open(MEMORY, '>', \$output) or die "Can't open memory file: $!\n";
$dwc->printcsv(\*MEMORY, ['institutionCode','collectionCode','catalogNumber']);
ok($output eq "O\tL\t1\n");

$dwc->validate();
ok($$dwc{error}[0][0] eq "Invalid basisOfRecord");
ok($$dwc{error}[1][0] eq "No occurrenceID");

$$dwc{notdwc} = "Unknown term";
$dwc->unknown();
ok($$dwc{error}[2][0] eq "Unknown term: notdwc");

$$dwc{catalogNumber} = undef;
ok(!eval { $dwc->validate(); });

