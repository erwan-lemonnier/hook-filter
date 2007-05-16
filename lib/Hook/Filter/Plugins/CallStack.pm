#################################################################
#
#   Hook::Filter::Plugin::CallStack - Functions for testing a subroutine's call stack
#
#   $Id: CallStack.pm,v 1.1 2007-05-16 12:34:12 erwan_lemonnier Exp $
#
#   060302 erwan Created
#   070516 erwan Renamed into CallStack + added from
#

package Hook::Filter::Plugins::CallStack;

use strict;
use warnings;
use Carp qw(croak);
use Data::Dumper;
use Hook::Filter::Hooker;

#----------------------------------------------------------------
#
#   register - return a list of the tests available in this plugin
#

sub register {
    return qw(from from_pkg from_sub is_sub);
}

#----------------------------------------------------------------
#
#   from - returns the fully qualified name of the caller
#

sub from {
    return get_caller_package."::".get_caller_subname;
}

#----------------------------------------------------------------
#
#   _match_or_die - generic match function used by all test functions in here
#

sub _match_or_die {
    my($func,$value,$match) = @_;

    if (!defined $func || !defined $value || !defined $match || scalar @_ != 3) {
	die "BUG: got wrong arguments in _match_or_die. ".Dumper(@_);
    }

    if (ref \$match eq 'SCALAR') {
	return $value eq $match;
    } elsif (ref $match eq 'Regexp') {
	return $value =~ $match;
    } else {
	die "$func: invalid argument, should be a scalar or a regexp.\n";
    }
}

#----------------------------------------------------------------
#
#   from_pkg - check if the calling package matches the provided regular expression
#

sub from_pkg {
    return _match_or_die('from_pkg',get_caller_package,$_[0]);
}

#----------------------------------------------------------------
#
#   from_sub - check if the calling package matches the provided regular expression
#

sub from_sub {
    return _match_or_die('from_sub',get_caller_subname,$_[0]);
}

#----------------------------------------------------------------
#
#   is_sub - check that sub currently called matches the provided regular expression
#

sub is_sub {
    return _match_or_die('is_sub',get_subname,$_[0]);
}

1;

__END__

=head1 NAME

Hook::Filter::Plugin::CallStack - Functions for testing a subroutine's call stack

=head1 DESCRIPTION

A library of functions testing various
aspects of a subroutine's call stack. Those functions should be used inside
Hook::Filter rules, and only there.

=head1 SYNOPSIS

Exemples of rules using test functions from Hook::Filter::Plugin::Location:

    # allow all subroutine calls made from inside function 'do_this' from package 'main'
    from =~ /main::do:this/

    # same as above
    from_sub('main::do_this')

    # allow all subroutine calls made from inside a function whose complete name matches /^Test::log.*/
    from_sub(qr{^Test::Log.*})

    # allow subroutine call if the called subroutine is 'MyModule::register'
    is_sub('MyModule::register')

    # allow subroutine call if the called subroutine matches /^My.*::register$/'
    is_sub(qr{^My.*::register$})

    # allow subroutine call if made from inside the module 'MyModule::Child'
    from_pkg('MyModule::Child')

    # allow subroutine call if made from inside a module whose name matches /^MyModule::Plugins::.*/
    from_pkg(qr{^MyModule::Plugins::.*})

=head1 INTERFACE - PLUGIN STRUCTURE

Like all plugin modules under Hook::Filter::Plugins, Hook::Filter::Plugins::CallStack
implements the class method C<< register() >>:

=over 4

=item B<register>()

Return the names of the test functions implemented in Hook::Filter::Plugins::Location. Used
by internally by Hook::Filter::Rule.

=back

=head1 INTERFACE - TEST FUNCTIONS

The following functions are only exported into Hook::Filter::Rule and
shall only be used inside filter rules.

=over 4

=item B<from>

Return the fully qualified name of the caller of the filtered subroutine.

=item B<is_sub>(I<$scalar>)

Return true if the fully qualified name of the currently filtered subroutine, for whom the rule
containing C<< is_sub >> is being eval-ed, equals I<$scalar>. Return false otherwise.

=item B<is_sub>(I<$regexp>)

Return true if the fully qualified name of the currently filtered subroutine, for whom the rule
containing C<< is_sub >> is being eval-ed, matches I<$regexp>. Return false otherwise.

=item B<from_sub>(I<$scalar>)

Return true if the fully qualified name of the subroutine that called the currently filtered
subroutine equals I<$scalar>. Return false otherwise.

=item B<from_sub>(I<$regexp>)

Return true if the fully qualified name of the subroutine that called the currently filtered
subroutine matches I<$regexp>. Return false otherwise.

=item B<from_pkg>(I<$scalar>)

Return true if the name of the package from which the filtered subroutine was called
is I<$scalar>. Return false otherwise.

=item B<from_pkg>(I<$regexp>)

Return true if the name of the package from which the filtered subroutine was called
matches I<$regexp>. Return false otherwise.

=back

=head1 DIAGNOSTICS

No diagnostics. Any bug in those test functions would cause a warning emitted by Hook::Filter::Rule.

=head1 BUGS AND LIMITATIONS

See Hook::Filter

=head1 SEE ALSO

See Hook::Filter, Hook::Filter::Rule, Hook::Filter::Hooker.

=head1 VERSION

$Id: CallStack.pm,v 1.1 2007-05-16 12:34:12 erwan_lemonnier Exp $

=head1 AUTHOR

Erwan Lemonnier C<< <erwan@cpan.org> >>.

=head1 LICENSE

See Hook::Filter.

=cut



