#################################################################
#
#   $Id: 12_test_from_pkg.t,v 1.3 2007-05-16 14:36:51 erwan_lemonnier Exp $
#
#   test from_sub
#

package MyTest1;

sub mytest1 { return 1; };
sub mysub1 { return mytest1(); };

1;

package MyTest1::Child;

sub mytest1 { return 1; };
sub mysub1 { return mytest1(); };

1;

package main;

use strict;
use warnings;
use Data::Dumper;
use Test::More;
use lib "../lib/";

BEGIN {
    eval "use Module::Pluggable"; plan skip_all => "Module::Pluggable required for testing Hook::Filter" if $@;
    eval "use File::Spec"; plan skip_all => "File::Spec required for testing Hook::Filter" if $@;
    plan tests => 12;

    use_ok('Hook::Filter::Hooker','filter_sub');
    use_ok('Hook::Filter::Rule');
    use_ok('Hook::Filter::RulePool','get_rule_pool');
}

my ($rule,$pool);
$pool = get_rule_pool;

sub mytest1 { return 1; };
sub mysub1 { return mytest1(); };

# test match package name
$rule = Hook::Filter::Rule->new("from_pkg('MyTest1');");
$pool->add_rule($rule);

filter_sub('main::mytest1');
filter_sub('MyTest1::mytest1');
filter_sub('MyTest1::Child::mytest1');

is(mysub1,undef,                 "main::mysub1 does not match string");
is(MyTest1::mysub1,1,            "MyTest1::mysub1 does match string");
is(MyTest1::Child::mysub1,undef, "MyTest1::Child::mysub1 does not match string");

# test match regexp
#$pool->flush_rules();
$rule = Hook::Filter::Rule->new('from_pkg(qr{^MyTest1})');
$pool->add_rule($rule);

is(mysub1,undef,             "main::mysub1 does not match string (after flush/reload)");
is(MyTest1::mysub1,1,        "MyTest1::mysub1 does match string (after flush/reload)");
is(MyTest1::Child::mysub1,1, "MyTest1::Child::mysub1 does match string (after flush/reload)");

# test flush_rules
#$pool->flush_rules();
$pool->add_rule("1");

is(mysub1,1,                 "main::mysub1 does match string (after new flush/reload)");
is(MyTest1::mysub1,1,        "MyTest1::mysub1 does match string (after new flush/reload)");
is(MyTest1::Child::mysub1,1, "MyTest1::Child::mysub1 does match string (after new flush/reload)");

