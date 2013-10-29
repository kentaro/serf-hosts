#!/usr/bin/env perl

use strict;
use warnings;
use Fcntl qw(:flock);
use File::Temp qw(tempfile);
use File::Copy;

my $file = $ARGV[0] || 'etc/hosts';
my ($name, $address, $role) = split(/\s+/, <STDIN>);
my $event = $ENV{SERF_EVENT};

if ($event eq 'member-join') {
    open my $fh, ">> ${file}" or die $!;

    {
        flock($fh, LOCK_EX);
        print $fh "${address}\t${name}\n";
        flock($fh, LOCK_UN);
    }

    close $fh;
}
elsif (
    $event eq 'member-leave' ||
    $event eq 'member-failed'
) {
    open my $fh, "< ${file}" or die $!;
    my ($tmp_fh, $tmp_file) = tempfile();

    {
        flock($fh, LOCK_EX);
        while (<$fh>) {
            if ($_ !~ /${name}$/) {
                print $tmp_fh $_;
            }
        }
        flock($fh, LOCK_UN);
    }

    close $fh;

    File::Copy::move($tmp_file, $file) or
        die "Failed to move ${tmp_file} to ${file}";
    close $tmp_fh;
}

