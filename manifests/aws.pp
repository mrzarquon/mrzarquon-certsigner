class certsigner::aws (
  $autosigner = 'autosign.rb',
) {

  #if $autosigner == 'autosign_classify.rb' {
  #  include certsigner::hieraclassifier
  #}


  file { '/etc/puppetlabs/puppet/autosignfog.yaml':
    ensure  => file,
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0600',
    replace => false,
    source  => 'puppet:///modules/certsigner/autosignfog.yaml',
  }
  
  file { "/opt/puppet/bin/${autosigner}":
    ensure  => file,
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0755',
    source  => "puppet:///modules/certsigner/${autosigner}",
    require => File['/etc/puppetlabs/puppet/autosignfog.yaml'],
  }

  ini_setting { 'autosign':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'autosign',
    value   => "/opt/puppet/bin/${autosigner}",
    require => File["/opt/puppet/bin/${autosigner}"],
  }

}
