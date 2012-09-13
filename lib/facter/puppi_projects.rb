Facter.add("puppi_projects") do
  setcode do
    Facter::Util::Resolution.exec('source /etc/puppi/puppi.conf ; ls $projectsdir | tr \'\n\' \',\' | sed \'s/,$//\'')
  end
end
