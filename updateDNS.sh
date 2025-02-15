#!/bin/sh
# This script gets the external IP of your systems then connects to the Gandi
# LiveDNS API and updates your dns record with the IP.

#Install jq if it itsn't installed yet
pkg -y install jq

# Gandi LiveDNS API KEY
API_KEY=""

# Domain hosted with Gandi
DOMAIN=""

# Subdomain to update DNS
SUBDOMAIN=""

# Interface to query
INTERFACE="pppoe0"
# Get external IP address
# Using ipinfo: 
#EXT_IP=$(curl -s ipinfo.io/ip)  

#Using Assigned ip adress

EXT_IP=$(ifconfig $INTERFACE | grep "inet " | awk '{print $2}')

#Get the current Zone for the provided domain
CURRENT_ZONE_HREF=$(curl -s -H "Authorization: Bearer $API_KEY" https://dns.api.gandi.net/api/v5/domains/$DOMAIN | jq -r '.zone_records_href')


# Update the A Record of the subdomain using PUT
curl -D- -X PUT -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"rrset_name\": \"$SUBDOMAIN\",
             \"rrset_type\": \"A\",
             \"rrset_ttl\": 1200,
             \"rrset_values\": [\"$EXT_IP\"]}" \
        $CURRENT_ZONE_HREF/$SUBDOMAIN/A
