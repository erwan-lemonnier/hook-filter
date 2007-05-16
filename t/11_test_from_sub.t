#################################################################
#
#   $Id: 11_test_from_sub.t,v 1.2 2007-05-16 14:09:09 erwan_lemonnier Exp $
#
#   test from_sub from Hook::Filter
#

package MyTest;

sub testsub1 { return 1; };
sub testsub2 { return 1; };

sub mysub1 { return testsub1(); };
sub mysub2 { return testsub1(); };
sub mysub3 { return testsub2(); };
sub mysub4 { return testsub2(); };

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
    plan tests => 10;

    use_ok('Hook::Filter::Hooker');
    use_ok('Hook::Filter::Rule');
    use_ok('Hook::Filter::RulePool');
}

my ($hook,$rule,$pool);
$pool = Hook::Filter::RulePool::get_rule_pool();

sub testsub1 { return 1; };
sub testsub2 { return 1; };

sub mysub1 { return testsub1(); };
sub mysub2 { return testsub1(); };
sub mysub3 { return testsub2(); };
sub mysub4 { return testsub2(); };

# test match only function name
$pool->add_rule("from_sub('MyTest::mysub1');");

$hook = new Hook::Filter::Hooker;
$hook->filter_sub('main::testsub1');
$hook->filter_sub('MyTest::testsub1');

is(mysub1,undef,"main::sub1 does not match string");
is(mysub2,undef,"main::sub2 does not match string");
is(MyTest::mysub1,1,"MyTest::mysub1 does match string");
is(MyTest::mysub2,undef,"MyTest::sub2 does not match string");

# test match regexp
$hook = Hook::Filter::Hooker->new();
$pool->flush_rules;
$pool->add_rule('from_sub(qr{sub3$})');

$hook->filter_sub('main::testsub2');
$hook->filter_sub('MyTest::testsub2');

is(mysub3,1,"main::sub3 does match string");
is(mysub4,undef,"main::sub4 does not match string");
is(MyTest::mysub3,1,"MyTest::sub3 does match string");
is(MyTest::mysub4,undef,"MyTest::sub4 does not match string");
