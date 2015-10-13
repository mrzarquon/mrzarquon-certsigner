#!/opt/puppetlabs/puppet/bin/ruby
require 'puppet'
require 'puppet/ssl/certificate_request'
require 'aws-sdk-core'

certname = ARGV.pop
csr = Puppet::SSL::CertificateRequest.from_s(STDIN.read)

# because we aren't loading all of puppet we don't have the full mappings
# keeping it simple, just using their OID numbers
# https://docs.puppetlabs.com/puppet/latest/reference/ssl_attributes_extensions.html#puppet-specific-registered-ids

instance_id = csr.request_extensions.find { |a| a['oid'] == '1.3.6.1.4.1.34380.1.1.2' }['value']
ami_id = csr.request_extensions.find { |a| a['oid'] == '1.3.6.1.4.1.34380.1.1.3' }['value']
aws_region = csr.request_extensions.find { |a| a['oid'] == '1.3.6.1.4.1.34380.1.1.18' }['value']

returncode = 100

ec2 = Aws::EC2::Client.new( region: aws_region )

server = ec2.describe_instances({
  instance_ids: [instance_id],
  filters: [
    {
      name: 'instance-state-name',
      values: ['running']
    },
  ],
})

tags = server.reservations[0].instances[0].tags
image_id = server.reservations[0].instances[0].image_id

# we are checking to see if this instance has already been signed
# a future update would add a puppet_cert_signed tag with $fingerprint-timestamp
# before exiting when returncode = 0
if tags.include?('puppet_cert_signed')
  signed = true
else
  signed = false
end

# lets make sure we can get a positive match also, this assumes you are using
# pp_image_name in csr_attributes.yaml
if image_id == ami_id
  ami_match = true
else
  ami_match = false
end

# the only time we can sign this cert is if this instance hasn't been given a signed
# cert before and we match on the instance in AWS also
if signed != true && ami_match == true
  returncode = 0
else
  returncode = 200
end

exit returncode
