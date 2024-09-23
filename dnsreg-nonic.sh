#!/bin/bash
yum install -y jq awscli

# Get the external IP of the EC2
external_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

# Update route53 with EC2 instance's public IP
aws route53 change-resource-record-sets --hosted-zone-id Z10327442G37TL4MXG5ZQ --change-batch '{
        "Changes": [
                {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                                "Name": "nonic.devopsandplatforms.com",
                                "Type": "A",
                                "TTL": 60,
                                "ResourceRecords": [
                                        {
                                                "Value": "'"$external_IP"'"
                                        }
                                ]
                        }
                }
        ]
}'

aws route53 change-resource-record-sets --hosted-zone-id Z10327442G37TL4MXG5ZQ --change-batch '{
        "Changes": [
                {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                                "Name": "deb1.devopsandplatforms.com",
                                "Type": "A",
                                "TTL": 60,
                                "ResourceRecords": [
                                        {
                                                "Value": "'"$external_IP"'"
                                        }
                                ]
                        }
                }
        ]
}'

aws route53 change-resource-record-sets --hosted-zone-id Z10327442G37TL4MXG5ZQ --change-batch '{
        "Changes": [
                {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                                "Name": "debian.devopsandplatforms.com",
                                "Type": "A",
                                "TTL": 60,
                                "ResourceRecords": [
                                        {
                                                "Value": "'"$external_IP"'"
                                        }
                                ]
                        }
                }
        ]
}'
