#!/bin/bash
yum install -y jq awscli

# Get the external IP of the EC2
external_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

# Lookup the current A record for nonic.devopsandplatforms.com
current_IP=$(aws route53 list-resource-record-sets --hosted-zone-id Z10327442G37TL4MXG5ZQ --query "ResourceRecordSets[?Name=='nonic.devopsandplatforms.com.'].ResourceRecords[0].Value" --output text)

# Update fleet1.devopsandplatforms.com with the current IP of nonic.devopsandplatforms.com
if [ "$current_IP" != "None" ]; then
    aws route53 change-resource-record-sets --hosted-zone-id Z10327442G37TL4MXG5ZQ --change-batch '{
            "Changes": [
                    {
                            "Action": "UPSERT",
                            "ResourceRecordSet": {
                                    "Name": "fleet1.devopsandplatforms.com",
                                    "Type": "A",
                                    "TTL": 60,
                                    "ResourceRecords": [
                                            {
                                                    "Value": "'"$current_IP"'"
                                            }
                                    ]
                            }
                    }
            ]
    }'
fi

# Update route53 with EC2 instance's public IP for nonic.devopsandplatforms.com
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

# Update other records with the new external IP
for subdomain in "deb1" "debian"; do
    aws route53 change-resource-record-sets --hosted-zone-id Z10327442G37TL4MXG5ZQ --change-batch '{
            "Changes": [
                    {
                            "Action": "UPSERT",
                            "ResourceRecordSet": {
                                    "Name": "'"$subdomain.devopsandplatforms.com"'",
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
done

