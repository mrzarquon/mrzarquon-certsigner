#
# == Class: certsigner::aws
#
# Provides a script to validate autosign requests
#
# Configures and replaces the autosign value in the puppet config
#
# === Parameters
#
# [*fog_config*]
#   Location on disk where to autosign fog configuration yaml will be placed
#
# [*fog_config_source*]
#   Location in puppet where the autosignfog.yaml file will be sourced from.
#   Use 'puppet:///modules/<<module>>/name.yaml'
#
# [*fog_config_replace*]
#   Boolean to replace the configuation file with the source or not.
#   Mostly to enforce the contents on the server aren't changed outside
#   of puppet's influence
#
# [*autosign_dest*]
#   Location on disk to place the autosign executable script.
#
# [*puppet_user*]
#   User puppet runs under - defaults to $settings::user (puppet on OSS, pe-puppet on PE)
#
# [*puppet_group*]
#   Group puppet runs under - defaults to $settings::group
#
# [*puppet_config*]
#   Location of puppet configuration - defaults to $settings::config
#
# === Examples
#
# include certsigner::aws
#
# === Authors
#    Jeremy T. Bouse <jbouse@debian.org> - autosigner.rb (https://gist.github.com/jbouse/8763661)
#    Chris Barker <github.com/mrzarquon> - Initial module
#    Vincent Janelle <randomfrequency@gmail.com> - Documentation and parameters
#
# === Copyright
#    Copyright 2014 Various, all rights reserved.
#
class certsigner::aws (
  $autosigner = 'autosign.rb',
  $fog_config = '/etc/puppetlabs/puppet/autosignfog.yaml',
  $fog_config_source = 'puppet:///modules/certsigner/autosignfog.yaml',
  $fog_config_replace = false,
  $autosign_dest = '/opt/puppet/bin/autosign.rb',
  $puppet_user = $settings::user,
  $puppet_group = $settings::group,
  $puppet_config = $settings::config
) {

  file { $fog_config:
    ensure  => file,
    owner   => $puppet_user,
    group   => $puppet_group,
    mode    => '0600',
    replace => $fog_config_replace,
    source  => $fog_config_source,
  }

  file { "/opt/puppet/bin/${autosigner}":

  file { $autosign_dest:
    ensure  => file,
    owner   => $puppet_user,
    group   => $puppet_group,
    mode    => '0755',
    source  => "puppet:///modules/certsigner/${autosigner}",
    require => File[$fog_config],
  }

  ini_setting { 'autosign':
    ensure  => present,
    path    => $puppet_config,
    section => 'master',
    setting => 'autosign',
    value   => $autosign_dest,
    require => File[$autosign_dest],
  }

}
