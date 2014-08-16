#!/bin/bash

PE_MASTER='ip-10-98-7-62.ap-southeast-2.compute.internal'

if [ ! -d /etc/yum.repos.d ]; then
  mkdir -p /etc/yum.repos.d
fi

curl -sk https://${PE_MASTER}:8140/packages/current/el-6-x86_64.repo > /etc/yum.repos.d/el-6-x86_64.repo

yum -y install pe-agent

if [ ! -d /etc/puppetlabs/puppet ]; then
  mkdir -p /etc/puppetlabs/puppet
fi

/opt/puppet/bin/erb > /etc/puppetlabs/puppet/csr_attributes.yaml <<END
extension_requests:
  pp_instance_id: <%= %x{curl -s http://169.254.169.254/latest/meta-data/instance-id} %>
END

declare -x PUPPET='/opt/puppet/bin/puppet'

$PUPPET config set server ${PE_MASTER} --section agent
$PUPPET config set environment production --section agent
$PUPPET config set certname $(curl -s http://169.254.169.254/latest/meta-data/instance-id) --section agent

$PUPPET resource service pe-puppet ensure=running enable=true
sleep 120
$PUPPET agent -t
