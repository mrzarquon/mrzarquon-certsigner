#!/opt/puppetlabs/bin/ruby

require 'puppetdb'
require 'aws-sdk-core'
require 'yaml'

client = PuppetDB::Client.new({:server => 'http://localhost:8080'})

# get list certificates on disk that have pp_instance_id in them
# for every certificate with pp_instance_id see if they are running
# for certificates without a running pp_instance_id, clean the cert
# optionally deactivate the node

awscertificates = client.request(
    'fact-contents',
    [:'=', 'path',
      [ "trusted", "extensions", "pp_instance_id" ])

puts awscertificates
