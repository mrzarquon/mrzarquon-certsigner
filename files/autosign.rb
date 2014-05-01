#!/opt/puppet/bin/ruby

require 'etc'

ENV['HOME'] = Etc.getpwuid(Process.uid).dir
ENV['FOG_RC'] = '/etc/puppetlabs/puppet/autosignfog.yaml'

require 'fog'
require 'puppet'
require 'puppet/ssl/certificate_request'

clientcert = ARGV.pop

csr = Puppet::SSL::CertificateRequest.from_s(STDIN.read)
pp_instance_id = csr.request_extensions.find { |a| a['oid'] == 'pp_instance_id' }
instance_id = pp_instance_id['value']

retcode = 0

ec2 = Fog::Compute.new( :provider => :aws)
server = ec2.servers.find { |s| s.id == instance_id }

if csr.name != clientcert
  retcode = 1
elsif not server
  retcode = 2
elsif server.state != 'running'
  retcode = 3
end

exit retcode
