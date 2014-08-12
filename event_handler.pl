#!/usr/bin/env perl

use strict;
use warnings;
use Fcntl qw(:flock);
use File::Temp qw(tempfile);
use File::Copy;

while (<STDIN>) {
    chomp;
    my @member_fields = split("\t", $_);
    die "fields must include 4 elements" unless @member_fields == 4;

    my $file = $ARGV[0] || 'etc/hosts';
    my ($name, $address, undef, undef) = @member_fields;
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
        close $tmp_fh;

        chmod 0644, $tmp_file or
            die "Failed to change permission of ${tmp_file} into 0644";

        File::Copy::move($tmp_file, $file) or
            die "Failed to move ${tmp_file} to ${file}";
    }
}
