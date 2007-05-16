#!/usr/local/bin/perl
#################################################################
#
#   $Id: 01_test_compile.t,v 1.2 2007-05-16 11:48:05 erwan_lemonnier Exp $
#
#   @author       erwan lemonnier
#   @description  test that all modules under Hook::Filter do compile
#   @system       pluto
#   @function     base
#

use strict;
use warnings;
use Data::Dumper;
use Test::More;
use lib "../lib/";

BEGIN {
    eval "use Module::Pluggable"; plan skip_all => "Module::Pluggable required for testing Hook::Filter" if $@;

    plan tests => 4;

    use_ok('Hook::Filter::Rule');
    use_ok('Hook::Filter::RulePool');
    use_ok('Hook::Filter::Hooker');
    use_ok('Hook::Filter','hook',[]);
};
