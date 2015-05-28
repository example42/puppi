#
# params_lookup.rb
#
# Puppet 4 implementation
#
# This function lookups for a variable value in various locations
# following this order (first match is returned)
# - Hiera backend (if present) for modulename_varname
# - Hiera backend (if present) for varname (if second argument is 'global')
# - Top Scope Variable ::modulename_varname
# - Top Scope Variable ::varname (if second argument is 'global')
# - Module default: ::modulename::params::varname
#
# Alessandro Franceschi al@lab42.it
#
#Puppet::Functions.create_function(:params_lookup, Puppet::Functions::InternalFunction) do
Puppet::Functions.create_function(:params_lookup) do
  dispatch :single do
#    scope_param
    param          'String', :var_name
    optional_param 'String', :lookup_type
#    arg_count 1, 3
  end

  def single(var_name, lookup_type='')
  # def single(scope, var_name, lookup_type='')

    value = ''
    # module_name = closure_scope.parent_module_name
    # module_name = scope.lookupvar('parent_module_name')
    module_name = 'test_params'

    # Hiera Lookup
    value = call_function('hiera', "#{module_name}_#{var_name}" , '')
    return value if (value != '')

    value = call_function('hiera', "#{var_name}", '') # if :lookup_type == 'global'
    return value if value
    # return value if (not value.nil?) && (value != :undefined) && (value != '')

    # Top Scope Variable Lookup (::modulename_varname)
    catch (:undefined_variable) do
      begin
        #value = scope.lookupvar("::#{module_name}_#{var_name}")
        value = closure_scope["::#{module_name}_#{var_name}"]
      rescue Puppet::ParseError => e
        raise unless e.to_s =~ /^Undefined variable /
      end
    end
    return value if (not value.nil?) && (value != :undefined) && (value != '')

    # Look up ::varname (only if second argument is 'global')
    if :lookup_type == 'global'
      catch (:undefined_variable) do
        begin
          value = closure_scope.lookupvar("::#{var_name}")
        rescue Puppet::ParseError => e
          raise unless e.to_s =~ /^Undefined variable /
        end
      end
      return value if (not value.nil?) && (value != :undefined) && (value != '')
    end

    # needed for the next two lookups
    classname = module_name
    # classname = scope.self.resource.name.downcase TODO

    loaded_classes = closure_scope.catalog.classes

    # self::params class lookup for default value
    if loaded_classes.include?("#{classname}::params")
      value = closure_scope.lookupvar("::#{classname}::params::#{var_name}")
      return value if (not value.nil?) && (value != :undefined) && (value != '')
    end

    # Params class lookup for default value
    if loaded_classes.include?("#{module_name}::params")
      value = closure_scope.lookupvar("::#{module_name}::params::#{var_name}")
      return value if (not value.nil?) && (value != :undefined) && (value != '')
    end

    return ''
  end
end
