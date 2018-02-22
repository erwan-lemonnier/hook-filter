Module Version: 0.10

# NAME

Hook::Filter - A runtime firewall for subroutine calls

# DESCRIPTION

Hook::Filter is a runtime firewall for subroutine calls.

Hook::Filter lets you wrap one or more subroutines with a filter that either forwards calls to the subroutine or blocks them, depending on a number of rules that you define yourself. Each rule is simply one line of Perl code that must evaluate to false (block the call) or true (allow it).

The filtering rules are fetched from a file, called the rules file, or they can be injected dynamically at runtime.

Each time a call is made to one of the filtered subroutines, all the filtering rules are eval-ed, and if one of them returns true, the call is forwarded, otherwise it is blocked. If no rules are defined, all calls are forwarded by default.

Filtering rules are very flexible. You can block or allow calls to a subroutine based on things such as the caller's identity, the values of the arguments passed to the subroutine, the structure of the call stack, or basically any other test that can be implemented in Perl.

# SYNOPSIS

To filter calls to the local subroutines mydebug, myinfo and to Some::Other::Module::mywarn:

    use Hook::Filter hook => [ "mydebug" ,"myinfo", "Some::Other::Module::mywarn" ];
    
To filter calls to the local subroutine _debug, and import filtering rules from the file ~/debug.rules:

    use Hook::Filter hook => '_debug', rules => '~/debug.rules';
    
The rule file ~/debug.rules could contain the following rules:

    # allow calls to 'mydebug' from within module 'My::Filthy:Attempt'
    subname eq 'mydebug' && from =~ /^My::Filthy::Attempt/

    # allow calls only from within a specific subroutine
    from eq 'My::Filthy::Attempt::func'

    # allow calls only if the subroutine's 2nd argument matches /bob/
    args(1) =~ /bob/

    # all other calls to 'myinfo', 'mydebug' or 'mywarn' will be skipped
    
You could also inject those rules dynamically at runtime:

    use Hook::Filter::RulePool qw(get_rule_pool);

    get_rule_pool->add_rule("subname eq 'mydebug' && from =~ /^My::Filthy::Attempt/");
                 ->add_rule("from =~ /^My::Filthy::Attempt::func$/");
                 ->add_rule("args(1) =~ /bob/");
                 
To see which test functions can be used in rules, see Hook::Filter::Plugins::Library.

# RULES

## SYNTAX

A rule is a string containing one line of valid perl code that returns either true or false when eval-ed. This line of code is usually made of boolean operators combining functions that are exported by the modules located under Hook::Filter::Plugins::. See those modules for more details.

If you specify a rule file with the import parameter rules, the rules will be parsed out of this file according to the following syntax:

any line starting with # is a comment.
any empty line is ignored.
any other line is considered to be a rule, ie a valid line of perl code that can be eval-ed.
Each time one of the filtered subroutines is called, all loaded rules are eval-ed until one returns true or all returned false. If one returns true, the call is forwarded to the filtered subroutine, otherwise it is skipped and a return value spoofed: either undef or an empty list, depending on the context.

If a rule dies/croaks/confess upon being eval-ed (f.ex. when you left a syntax error in the rule's string), it will be assumed to have returned true. This is a form of fail-safe policy. You will also get a warning message with a complete diagnostic.

## RULE POOL

All rules are stored in a rule pool. You can use this pool to access and manipulate rules during runtime.

There are 2 mechanisms to load rules into the pool:

Rules can be imported from a file at INIT time. Just specify the path and name of this file with the import parameter rules, and fill this file with rules as shown in SYNOPSIS.
Rules can also be injected dynamically at runtime. The following code injects a rule that is always true, hence always allowing calls to the filtered subroutines:

    use Hook::Filter::RulePool qw(get_rule_pool);
    get_rule_pool->add_rule("1");
    
Rules can all be flushed at runtime:

    get_rule_pool->flush_rules();
    
For other operations on rules, see the modules Hook::Filter::RulePool and Hook::Filter::Rule.

## PASS ALL CALLS BY DEFAULT

If no rules are registered in the rule pool, or if all registered rules die/croak when eval-ed, the default behaviour is to allow all calls to the filtered subroutines.

That would happen for example if you specify no rule file via the import parameter rules and register no rules dynamically afterward.

To change this default behaviour, just add one default rule that always returns false:

    use Hook::Filter::RulePool qw(get_rule_pool);
    get_rule_pool->add_rule("0");
    
All calls to the filtered subroutines are then blocked by default, as long as no rule evals to true.

# EXTENDING THE PLUGIN LIBRARY

The default plugin Hook::Filter::Plugins::Library offers a number of functions that can be used inside the filter rules, but you may want to extend this library with your own functions.

You can easily do that by writing a new plugin module having the same structure as Hook::Filter::Plugins::Library and placing it under Hook/Filter/Plugins/. See Hook::Filter::Hooker and Hook::Filter::Plugins::Library for details on how to do that.

# INTERFACE

Hook::Filter exports no functions, but Hook::Filter accepts the following import parameters:

## rules => $rules_file

Optional. Specify the complete path to a rule file. This import parameter can be used only once in a program (usually in package main) independently of how many times Hook::Filter is used. The file is parsed at INIT time.

See the RULES section for details.

Example:

    # look for rules in the local file 'my_rules'
    use Hook::Filter rules => 'my_rules';
    
## hook => $subname1 or hook => [$subname1,$subname2...]

Mandatory. Specify which subroutines to filter. $subname can either be a fully qualified name or just the name of a subroutine located in the current package.

Examples:

    # filter function debug() in the current package
    use Hook::Filter hook => 'debug';

    # filter function debug() in an other package
    use Hook::Filter hook=> 'Other::Package::debug';

    # do both at once
    use Hook::Filter hook=> [ 'Other::Package::debug', 'debug' ];

# DIAGNOSTICS

Passing wrong arguments to Hook::Filter's import parameters will cause it to croak.
The import parameter hook must be used at least once otherwise Hook::Filter croaks with an error message.
An IO error when opening the rule file causes Hook::Filter to die.
An error in a filter rule will be reported with a perl warning.

# RESTRICTIONS

## SECURITY

Hook::Filter gives anybody with write permissions toward the rule file the possibility to inject code into your application. This can be highly dangerous! Protect your filesystem.

## CAVEATS

Return values: when a call to a subroutine is allowed, the input and output arguments of the subroutine are forwarded without modification. But when the call is blocked, the subroutine's return value is simulated and will be undef in SCALAR context and an empty list in ARRAY context. Therefore, DO NOT filter subroutines whose return values are significant for the rest of your code.
Speed: Hook::Filter evaluates all filter rules for each call to a filtered subroutine, which is slow. It would therefore be very unappropriate to filter a heavily used subroutine in speed requiring applications.

## THREADS

Hook::Filter is not thread safe.

## KEEP IT SIMPLE

The concept of blocking/allowing subroutine calls dynamically is somewhat unusual and fun. Don't let yourself get too excited though. Doing that kind of dynamic stuff makes your code harder to understand for non-dynamic developers, hence reducing code stability.

## USING Hook::Filter VIA REQUIRE/EVAL

If you do something like:

    eval "use Hook::Filter hook => 'some_sub'";
    
You will get a 'Too late to run INIT block' warning, and the subroutine some_sub will not be filtered.

There is unfortunately no simple way to fix that.

A rather ugly work-around would be to run explicitly the private function _filter_subs from Hook::Filter:

    {
        no warnings 'void';
        eval "use Hook::Filter hook => 'some_sub', qw(filter_subs)";
    }
    ...

    # later on, call filter_subs explicitly
    Hook::Filter::_filter_subs;
    
# USE CASE

Why would one need a firewall for subroutine calls? Here are a couple of relevant use cases:

A large application logs a lot of information. You want to implement a logging policy to limit the amount of logged information, but you don't want to modify the logging code. You do that by filtering the functions defined in the logging API with Hook::Filter, and by defining a rule file that implements your logging policy.
A large application crashes regularly so you decide to turn on debugging messages system wide with full verbosity. You get megazillions of log messages. Instead of greping your way through them or starting your debugger, you use Hook::Filter to filter the function that logs debug messages and define tailored rules that allow only relevant debug messages to be logged.

# SEE ALSO

See Hook::Filter::Rule, Hook::Filter::RulePool, Hook::Filter::Plugins::Library, Hook::Filter::Hooker. See even Hook::WrapSub, Log::Localized, Log::Log4perl, Log::Dispatch.

# BUGS AND LIMITATIONS

Please report any bugs or feature requests to bug-hook-filter@rt.cpan.org, or through the web interface at http://rt.cpan.org.

# AUTHOR

Written by Erwan Lemonnier <erwan@cpan.org> based on inspiration received during the 2005 Nordic Perl Workshop. Kind thanks to Claes Jakobsson & Jerker Montelius for their suggestions and support!

# LICENSE

See the LICENSE file included in this distribution.
