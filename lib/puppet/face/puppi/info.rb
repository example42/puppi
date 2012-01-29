# require 'puppet'
require 'puppet/face'

Puppet::Face.define(:puppi, '0.0.1') do
  action :info do
    summary "Show info topics"
    description <<-'DESCRIPTION'
      Show dynamic info topics for the puppi::zed modules.
    DESCRIPTION

    option "--report REPORTS" do
      summary "Report output to the defined destinations"
    end

    when_invoked do |args|
      config(options)
      get_data
      get_helper("info")
      run_commands
      report
    end
  end

end
