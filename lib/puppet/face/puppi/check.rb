# require 'puppet'
require 'puppet/face'

Puppet::Face.define(:puppi, '0.0.1') do
  action :check do
    summary "Run checks"
    description <<-'DESCRIPTION'
      Run checks for the puppi::zed modules.
    DESCRIPTION
    option "--report REPORTS" do
      summary "Report output to the defined destinations"
    end

    when_invoked do |args|
      config(options)
      get_data
      get_helper("check")
      run_commands
      report
    end
  end

end
