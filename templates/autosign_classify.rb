#!/opt/puppet/bin/ruby

require 'etc'

ENV['HOME'] = Etc.getpwuid(Process.uid).dir
ENV['FOG_RC'] = '/etc/puppetlabs/puppet/autosignfog.yaml'

require 'fog'
require 'puppet'
require 'puppet/ssl/certificate_request'

clientcert = ARGV.pop

csr = Puppet::SSL::CertificateRequest.from_s(STDIN.read)

# if you use the pp_instance_id embedded cert we will use that
# otherwise we will assume you want us to use certname
if csr.request_extensions.find { |a| a['oid'] == 'pp_instance_id' }
  instance_id = csr.request_extensions.find { |a| a['oid'] == 'pp_instance_id' }['value']
else
  instance_id = clientcert
end
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

classes = server.tags['puppet_classes'].delete(' ').split(",")

unless classes.nil?
  classyaml = { "classes" => classes }
  File.open("/etc/puppetlabs/puppet/environments/production/data/clientcert/#{clientcert}.yaml", 'w') { |f| f.write classyaml.to_yaml }
end

exit retcode
