require 'puppet'
require 'puppet/face'

Puppet::Face.define(:puppi, '0.0.1') do
  action :log do
    summary "Tail logs"
    description <<-'DESCRIPTION'
      Tail logs for the puppi::zed modules.
    DESCRIPTION

    when_invoked do |args|
      config(options)
      get_data
      get_helper("log")
      run_commands
      report
    end
  end

end
