#/bin/bash

echo "ec2_publicdns=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)"
