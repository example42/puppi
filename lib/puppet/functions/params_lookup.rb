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
Puppet::Functions.create_function(:params_lookup) do
  dispatch :single do
    param 'String', :var_name
    arg_count 1, 3
  end

  def single(var_name)

    value = ''
    module_name = parent_module_name

    # Hiera Lookup
    value = call_function('hiera', ["#{module_name}_#{var_name}", ''])
    return value if (not value.nil?) && (value != :undefined) && (value != '')

    value = call_function('hiera', ["#{var_name}", '']) if arguments[1] == 'global'
    return value if (not value.nil?) && (value != :undefined) && (value != '')

    # Top Scope Variable Lookup (::modulename_varname)
    catch (:undefined_variable) do
      begin
        value = lookupvar("::#{module_name}_#{var_name}")
      rescue Puppet::ParseError => e
        raise unless e.to_s =~ /^Undefined variable /
      end
    end
    return value if (not value.nil?) && (value != :undefined) && (value != '')

    # Look up ::varname (only if second argument is 'global')
    if arguments[1] == 'global'
      catch (:undefined_variable) do
        begin
          value = lookupvar("::#{var_name}")
        rescue Puppet::ParseError => e
          raise unless e.to_s =~ /^Undefined variable /
        end
      end
      return value if (not value.nil?) && (value != :undefined) && (value != '')
    end

    # needed for the next two lookups
    classname = self.resource.name.downcase
    loaded_classes = catalog.classes

    # self::params class lookup for default value
    if loaded_classes.include?("#{classname}::params")
      value = lookupvar("::#{classname}::params::#{var_name}")
      return value if (not value.nil?) && (value != :undefined) && (value != '')
    end

    # Params class lookup for default value
    if loaded_classes.include?("#{module_name}::params")
      value = lookupvar("::#{module_name}::params::#{var_name}")
      return value if (not value.nil?) && (value != :undefined) && (value != '')
    end

    return ''
  end
end
