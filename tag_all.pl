#!/usr/bin/perl
use strict;
use warnings;
use lib "lib/";
require Hook::Filter;

my $tag = "VERSION_".$Hook::Filter::VERSION;
$tag =~ s/\.//;
print "-> tagging files with tag [$tag]\n";

`cat MANIFEST | grep -v MANIFEST | grep -v META.yml | xargs cvs tag $tag`;

