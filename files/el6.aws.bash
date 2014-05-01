#!/bin/bash

PE_MASTER='ip-10-98-7-62.ap-southeast-2.compute.internal'

if [ ! -d /etc/yum.repos.d ]; then
  mkdir -p /etc/yum.repos.d
fi

cat > /etc/yum.repos.d/pe_repo.repo <<REPO
[puppetlabs-pepackages]
name=Puppet Labs PE Packages \$releasever - \$basearch
baseurl=https://${PE_MASTER}:8140/packages/current/el-6-x86_64
enabled=1
gpgcheck=1
sslverify=False
proxy=_none_
gpgkey=https://${PE_MASTER}:8140/packages/GPG-KEY-puppetlabs
REPO

yum -y install pe-agent

if [ ! -d /etc/puppetlabs/puppet ]; then
  mkdir -p /etc/puppetlabs/puppet
fi

/opt/puppet/bin/erb > /etc/puppetlabs/puppet/csr_attributes.yaml <<END
extension_requests:
  pp_instance_id: <%= %x{curl -s http://169.254.169.254/latest/meta-data/instance-id} %>
END

/opt/puppet/bin/puppet config set server ${PE_MASTER} --section agent
/opt/puppet/bin/puppet config set environment production --section agent
/opt/puppet/bin/puppet config set certname $(curl -s http://169.254.169.254/latest/meta-data/instance-id) --section agent

/opt/puppet/bin/puppet resource service pe-puppet ensure=running enable=true
