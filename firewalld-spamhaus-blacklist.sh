#!/bin/bash

URL="https://www.spamhaus.org/drop/drop.txt"
TMP_FILE="/tmp/spamhaus_drop.txt"
IPSET="spamhaus_drop"

curl -fsSL "$URL" |
    awk '!/^;/ && NF {print $1}' |
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$' \
    > "$TMP_FILE"

if [ ! -s "$TMP_FILE" ]; then
    echo "ERROR: Spamhaus list is empty"
    exit 1
fi

# Create ipset if it doesn't exist
if ! firewall-cmd --permanent --get-ipsets | grep -qx "$IPSET"; then
    firewall-cmd --permanent \
        --new-ipset="$IPSET" \
        --type=hash:net \
        --family=inet

    firewall-cmd --reload
fi

# Flush current entries
ipset flush "$IPSET"

# Load new entries
ipset restore <<EOF
$(awk -v set="$IPSET" '{print "add " set " " $1}' "$TMP_FILE")
EOF

echo "Spamhaus DROP list updated: $(wc -l < "$TMP_FILE") networks"

rm -f "$TMP_FILE"
