#!/bin/bash
# Fix DNS and clipboard for UTM Debian VM
# Run: sudo ./fix-dns.sh

set -e

echo "=== Fixing clipboard (SPICE) ==="
apt install -y spice-vdagent
systemctl enable spice-vdagentd
systemctl start spice-vdagentd

echo "=== Fixing DNS ==="

# Quick fix: add Google DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf > /dev/null

# Make persistent via systemd-resolved
if [ -f /etc/systemd/resolved.conf ]; then
    echo "Configuring systemd-resolved..."
    sudo sed -i 's/^#DNS=.*/DNS=8.8.8.8 8.8.4.4/' /etc/systemd/resolved.conf
    sudo sed -i 's/^#FallbackDNS=.*/FallbackDNS=1.1.1.1/' /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved 2>/dev/null || true
fi

# Test connectivity
echo "Testing connectivity..."
if ping -c 2 google.com > /dev/null 2>&1; then
    echo "DNS working! You can now run apt."
else
    echo "Warning: Still no connectivity. Check VM network settings."
    exit 1
fi
