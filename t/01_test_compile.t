#################################################################
#
#   $Id: 01_test_compile.t,v 1.4 2007-05-16 14:09:09 erwan_lemonnier Exp $
#
#   test that all modules compile
#

use strict;
use warnings;
use Data::Dumper;
use Test::More;
use lib "../lib/";

BEGIN {
    eval "use Module::Pluggable"; plan skip_all => "Module::Pluggable required for testing Hook::Filter" if $@;

    plan tests => 5;

    use_ok('Hook::Filter::Plugins::CallStack');
    use_ok('Hook::Filter::Rule');
    use_ok('Hook::Filter::RulePool');
    use_ok('Hook::Filter::Hooker');
    use_ok('Hook::Filter','hook',[]);
};
