#
# params_lookup.rb
#
# This function lookups for a variable value in various locations
# following this order
# - Hiera backend, if present
# - ::varname (if option abs_lookup is true)
# - ::modulename_varname
# - ::modulename::params::varname
# - The value set with the "default" option
#
# It's based on a suggestion of Dan Bode on how to better manage
# Example42 NextGen modules params lookups.
# Code has been written with the decisive help of Brice Figureau,
# Peter Meier and Ohad Levy during the Fosdem 2012 days (thanks guys)
#
# Alessandro Franceschi al@lab42.it
# 
module Puppet::Parser::Functions
  newfunction(:params_lookup, :type => :rvalue, :doc => <<-EOS
This fuction looks for the given variable name in a set of different sources:
- Hiera, if available ('varname' if option abs_lookup is true)
- Hiera, if available ('modulename_varname')
- ::varname (if option abs_lookup is true)
- ::modulename_varname
- ::modulename::params::varname
- The value set with the "default" option
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "params_lookup(): Define at least the variable name " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    value = :undef
    var_name = arguments[0]
    # options = { 'default' => :undef, 'abs_lookup' => false }.merge(arguments[1] || {}) 
    module_name = parent_module_name
    if Puppet::Parser::Functions.function('hiera')
      value = function_hiera("#{var_name}",:undef) if arguments[1] == 'global'
      value = function_hiera("#{module_name}_#{var_name}",:undef) 
    end
    if value == :undef
      value = lookupvar("::#{var_name}") if arguments[1] == 'global'
      value = lookupvar("::#{module_name}_#{var_name}")
      value = lookupvar("::#{module_name}::params::#{var_name}") if value == :undef
    end
    
    return value
  end
end

# vim: set ts=2 sw=2 et :
