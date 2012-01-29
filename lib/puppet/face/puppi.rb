require 'puppet'
require 'puppet/face'


Puppet::Face.define(:puppi, '0.0.1') do
  license "Apache 2"
  copyright "Lab42", 2012
  author "Alessandro Franceschi <al@lab42.it>"
  summary "Provides Puppi actions"
  description <<-'DESCRIPTION'
    Puppi is a tool that manages applications deployments and provides a
    way to use Puppet knowledge on the system directly via a command line
    tool. The Puppi face is a new implementation of the Puppi shell script
    that aims to integrate seamlessly with any kind of existing module.
  DESCRIPTION
 
  examples <<-'EXAMPLES'
    # Run all the checkes for the system
    ] puppet puppi check
 
    # Show all the dynamic info topics for all the modules
    ] puppet puppi info
 
    # Show dynamic info for apache
    ] puppet puppi info apache
 
    # Tails all the known logs
    ] puppet puppi log
  EXAMPLES
 
  notes <<-'NOTES'
    * This is preliminary work. Do not expect much from it
    * For the moment ;-)
  NOTES

=begin
  option "--force TRUE|FALSE" do
    summary "Force steps execution even when one fails"
  end

  option "--interactive" do
    summary "Ask for confirmation before executing each step"
  end

  option "--test" do
    summary "Make a dry-run. Just show the commands to be executed"
  end

  option "--debug" do
    summary "Enable debug mode"
  end

  option "--report REPORTS" do
    summary "Report output to the defined destinations"
  end

  option "--show YES|NO|FAIL" do
    summary "Show output: always, never, only for failed steps"
  end

  option "--override parameter=value,parameter=value" do
    summary "Override puppi data"
  end
=end


  def config(options)
=begin
    @force  = options[:force] 
    @interactive = false unless options.has_key?[:interactive]
    @test = false unless options.has_key?[:test]
    @debug = false unless options.has_key?[:debug]
    @report = options[:report]
    @show = true unless options.has_key?[:show]
    @override = options[:override]
=end
  end

  def get_data
    Puppet.notice "Retrieving Puppi data... #TODO"
  end

  def get_helper(action)
    Puppet.notice "Retrieving Puppi helpers... #TODO"
  end

  def run_commands
    Puppet.notice "Running commands... #TODO"
  end

  def report
    Puppet.notice "Reporting... #TODO"
  end

end
