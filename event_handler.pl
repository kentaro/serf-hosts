#!/usr/bin/env perl
use strict;
use warnings;

my ($name, $address, $role) = split(/\s+/, <STDIN>);
my $event = $ENV{SERF_EVENT};

if ($event eq 'member-join') {
    open my $fh, ">> etc/hosts" or die $!;
    print $fh "${address}\t${name}\n";
    close $fh;
}
elsif (
    $event eq 'member-leave' ||
    $event eq 'member-failed'
) {
    my $content = '';

    open my $fh, "< etc/hosts" or die $!;
    while (<$fh>) {
        if ($_ !~ /${name}$/) {
            $content .= $_;
        }
    }
    close $fh;

    open  $fh, "> etc/hosts" or die $!;
    print $fh $content;
    close $fh;
}

