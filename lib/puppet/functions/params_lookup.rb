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
Puppet::Functions.create_function(:params_lookup, Puppet::Functions::InternalFunction) do
  dispatch :single do
    scope_param()
    param          'String', :varname
    optional_param 'String', :lookup_type
#    arg_count 1, 3
  end

  def single(scope, varname, lookup_type='')
    value = ''
    modulename = scope["module_name"]

    # OK - Hiera Lookup modulename_varname
    value = call_function('hiera', "#{modulename}_#{varname}", '')
    # value = call_function('lookup', "#{modulename}_#{varname}", String, 'first', '')
    return value if (value != '')

    # OK - Hiera Lookup varname (global)
    value = call_function('hiera', "#{varname}", '') if lookup_type == 'global'
    # value = call_function('lookup', "#{varname}", String, 'first', '') if lookup_type == 'global'
    return value if (not value.nil?) && (value != :undefined) && (value != '')

    # OK - Top Scope Variable Lookup (::modulename_varname)
    catch (:undefined_variable) do
      begin
        value = scope["::#{modulename}_#{varname}"]
      rescue Puppet::ParseError => e
        raise unless e.to_s =~ /.Could not look./
      end
    end
    return value if (not value.nil?) && (value != :undefined) && (value != '')

    # OK - Top Scope Variable Lookup ::varname (global)
    if lookup_type == 'global'
      catch (:undefined_variable) do
        begin
          value = scope["::#{varname}"]
        rescue Puppet::ParseError => e
          raise unless e.to_s =~ /.Could not look./
        end
      end
      return value if (not value.nil?) && (value != :undefined) && (value != '')
    end

    # Set the classname to first namespace when params_lookup used in subclasses
    classname = scope.resource.name.downcase if scope.resource.type == 'Class'

    loaded_classes = closure_scope.catalog.classes

    # TOTEST - legacy params lookup (self::params)
    if loaded_classes.include?("#{classname}::params")
      value = closure_scope["::#{classname}::params::#{varname}"]
      return value if (not value.nil?)
      # return value if (not value.nil?) && (value != :undefined) && (value != '')
    end

    # OK - default params lookup
    if loaded_classes.include?("#{modulename}::params")
      value = closure_scope["::#{modulename}::params::#{varname}"]
      return value if (not value.nil?)
      # return value if (not value.nil?) && (value != :undefined) && (value != '')
    end

    return ''
  end
end
