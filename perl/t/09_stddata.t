use strict;
use Test::More;
use Test::Requires qw(JSON);
use t::Util;

use Data::MessagePack;

sub slurp {
    open my $fh, '<:raw', $_[0] or die "failed to open '$_[0]': $!";
    local $/;
    return scalar <$fh>;
}

my @data = @{ JSON::decode_json(slurp("t/std/cases.json")) };

my $mpac1  = slurp("t/std/cases.mpac");
my $mpac2  = slurp("t/std/cases_compact.mpac");

my $mps = Data::MessagePack::Unpacker->new();

my $t = 1;
for my $mpac($mpac1, $mpac2) {
    note "mpac", $t++;

    my $offset = 0;
    my $i = 0;
    while($offset < length($mpac)) {
        $offset += $mps->execute($mpac, $offset);
        is_deeply $mps->data, $data[$i], "data[$i]";
        $mps->reset;
        $i++;
    }
}

done_testing;
