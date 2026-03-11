#!/bin/bash
# Capture the output of the SAML GUI to parse the cookie
eval $(gp-saml-gui --gateway ragw.salisbury.edu | grep -E '^(HOST|USER|COOKIE|OS)=')

if [ -z "$COOKIE" ]; then
    echo "Failed to acquire SAML cookie."
    exit 1
fi

# Pass the cookie into openconnect
echo "$COOKIE" | sudo openconnect --protocol=gp \
    --useragent='PAN GlobalProtect' \
    --user="$USER" \
    --os="$OS" \
    --usergroup=gateway:prelogin-cookie \
    --passwd-on-stdin "$HOST"

# OLD
# sudo openconnect --protocol=gp SERVER -u "DOMAIN\username"
