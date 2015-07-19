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
    param          'String', :varname
    optional_param 'String', :lookup_type
#    arg_count 1, 3
  end

  def single(varname, lookup_type='')

    value = ''
    # TOFIX: Get $module_name
    # modulename = closure_scope["module_name"]
    modulename = 'exim'

    # Hiera Lookup
    # OK
    value = call_function('hiera', "#{modulename}_#{varname}" , '')
    return value if (value != '')

    # OK
    value = call_function('hiera', "#{varname}", '') if lookup_type == 'global'
    return value if (not value.nil?) && (value != :undefined) && (value != '')

    # Top Scope Variable Lookup (::modulename_varname)
    # OK - TOFIX Warning message
    catch (:undefined_variable) do
      begin
        value = closure_scope["::#{modulename}_#{varname}"]
      rescue Puppet::ParseError => e
        raise unless e.to_s =~ /^Undefined variable /
      end
    end
    return value if (not value.nil?) && (value != :undefined) && (value != '')

    # Look up ::varname (only if second argument is 'global')
    # OK
    if lookup_type == 'global'
      catch (:undefined_variable) do
        begin
          value = closure_scope["::#{varname}"]
        rescue Puppet::ParseError => e
          raise unless e.to_s =~ /^Undefined variable /
        end
      end
      return value if (not value.nil?) && (value != :undefined) && (value != '')
    end

    # needed for the next two lookups
    # TODO: Set the correct classname when params_lookup used in subclasses
    classname = modulename
    # classname = scope.self.resource.name.downcase 

    loaded_classes = closure_scope.catalog.classes

    # self::params class lookup for default value
    # TOTEST
    if loaded_classes.include?("#{classname}::params")
      value = closure_scope["::#{classname}::params::#{varname}"]
      return value if (not value.nil?)
      # return value if (not value.nil?) && (value != :undefined) && (value != '')
    end

    # Params class lookup for default value
    # OK
    if loaded_classes.include?("#{modulename}::params")
      value = closure_scope["::#{modulename}::params::#{varname}"]
      return value if (not value.nil?)
      # return value if (not value.nil?) && (value != :undefined) && (value != '')
    end

    return ''
  end
end
