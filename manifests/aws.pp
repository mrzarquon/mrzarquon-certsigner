class certsigner::aws {

  file { '/etc/puppetlabs/puppet/autosignfog.yaml':
    ensure  => file,
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0600',
    replace => false,
    source  => 'puppet:///modules/certsigner/autosignfog.yaml',
  }
  
  file { '/opt/puppet/bin/autosign.rb':
    ensure  => file,
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0755',
    source  => 'puppet:///modules/certsigner/autosign.rb',
    require => File['/etc/puppetlabs/puppet/autosignfog.yaml'],
  }

  ini_setting { 'autosign':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'autosign',
    value   => '/opt/puppet/bin/autosign.rb',
    require => File['/opt/puppet/bin/autosign.rb'],
  }

}
