#!/bin/bash

if [ ! -d /etc/yum.repos.d ]; then
  mkdir -p /etc/yum.repos.d
fi

cat > /etc/yum.repos.d/pe_repo.repo <<REPO
[puppetlabs-pepackages]
name=Puppet Labs PE Packages \$releasever - \$basearch
baseurl=https://hostname:8140/packages/current/el-6-x86_64
enabled=1
gpgcheck=1
sslverify=False
proxy=_none_
gpgkey=https://hostname:8140/packages/GPG-KEY-puppetlabs
REPO

yum -y install pe-agent

if [ ! -d /etc/puppetlabs/puppet ]; then
  mkdir -p /etc/puppetlabs/puppet
fi

/opt/puppet/bin/erb > /etc/puppetlabs/puppet/csr_attributes.yaml <<END
extension_requests:
  pp_instance_id: <%= %x{curl http://169.254.169.254/latest/meta-data/instance-id} %>
END

/opt/puppet/bin/puppet config set server hostname --section agent
/opt/puppet/bin/puppet config set environment production --section agent
/opt/puppet/bin/puppet config set certname $(curl http://169.254.169.254/latest/meta-data/instance-id) --section agent

/opt/puppet/bin/puppet resource service pe-puppet ensure=running enable=true
