require 'uri'

Puppet::Parser::Functions::newfunction(:jdbc_oracle_parse, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Returns information about an Oracle JDBC URI

    This function expects two arguments, an Oracle JDBC string and the part of the uri you want to retrieve.

    Example:
    $db_host = jdbc_oracle_parse($jdbc_string,host)

    Given an Oracle JDBC string like: jdbc:oracle:thin:dblogin/Pass0@oe-db-01.example.local:1521/dbname
    You obtain the following results according to the second argument:
    scheme   : oracle
    client   : thin
    user     : dblogin
    password : Pass0
    host     : oe-db-01.example.local
    port     : 1521
    db       : dbname

    Tested against these JDBC string:
    jdbc:oracle:thin:dblogin/Pass0@//oe-db-01.example.local
    jdbc:oracle:thin:dblogin/Pass0@//oe-db-01.example.local:1521/dbname
    jdbc:oracle:thin:dblogin/Pass0@//oe-db-01.example.local:1521
    jdbc:oracle:thin:@//oe-db-01.example.local
    jdbc:oracle:thin:@//oe-db-01.example.local:1521
    jdbc:oracle:thin:@//oe-db-01.example.local:1521/dbname
    jdbc:oracle:thin:@oe-db-01.example.local
    jdbc:oracle:thin:dblogin/Pass0@oe-db-01.example.local:1521/dbname
    jdbc:oracle:@oe-db-01.example.local
    jdbc:oracle:dblogin/Pass0@oe-db-01.example.local:1521/dbname
  ENDHEREDOC
  raise ArgumentError, ("jdbc_parse(): wrong number of arguments (#{args.length}; must be 2)") if args.length != 2
  url = args[0]

  matches = /^jdbc:(\w+):(\w*):*(\w*)\/*(\w*)@\/*\/*([^:]+):*(\d*)\/*(\w*)$/.match(url)

  case args[1]
    when 'scheme' then matches[1]
    when 'client' then matches[2]
    when 'user' then matches[3]
    when 'password' then matches[4]
    when 'host' then matches[5]
    when 'port' then matches[6]
    when 'db' then matches[7]
    else url
  end
end
