This is a first pass at a cloud seeding module.

adding "certsigner::aws" will install the autosign broker for AWS on your CA.

edit the /etc/puppetlabs/puppet/autosignfog.yaml file to include your aws credentials and region per the documentation: http://docs.puppetlabs.com/pe/latest/cloudprovisioner_configuring.html#configuring

See the example el6.aws.bash script for a possible User Data script to used when deploying in cloud formations or through other AWS means.

Originally inspired by jblouse[https://github.com/jbouse]'s gist: https://gist.github.com/jbouse/8763661
