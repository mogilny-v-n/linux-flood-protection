#!/bin/bash

# Disable ICMP echo-request and INVALID packages
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p icmp --icmp-type echo-request -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 -m conntrack --ctstate INVALID -j DROP




# Add HTTP server protection and logging to reuse info with fail2ban. Please adjust "hashlimit-upto" and "hashlimit-burst" for your server

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --syn --dport 80 -m hashlimit --hashlimit-mode srcip --hashlimit-name https_limit --hashlimit-upto 5/second --hashlimit-burst 10 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 -p tcp --syn --dport 80 -m limit --limit 5/second --limit-burst 1 -j LOG --log-prefix 'HTTP_FLOOD: ' --log-level info
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 -p tcp --syn --dport 80 -j DROP




# Add HTTPS server protection and logging to reuse info with fail2ban. Please adjust "hashlimit-upto" and "hashlimit-burst" for your server

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --syn --dport 443 -m hashlimit --hashlimit-mode srcip --hashlimit-name https_limit --hashlimit-upto 5/second --hashlimit-burst 10 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 -p tcp --syn --dport 443 -m limit --limit 5/second --limit-burst 1 -j LOG --log-prefix 'HTTPS_FLOOD: ' --log-level info
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 -p tcp --syn --dport 443 -j DROP




# This settings add protection for all TCP/UDP traffic. You should be careful with this settings and adjust "hashlimit-upto" and "hashlimit-burst" for your server  

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 2 -p tcp --syn -m hashlimit --hashlimit-name syn_limit --hashlimit-mode srcip --hashlimit-upto 10/second --hashlimit-burst 20 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 3 -p tcp -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 2 -p udp -m hashlimit --hashlimit-name udp_limit --hashlimit-mode srcip --hashlimit-upto 50/second --hashlimit-burst 100 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 3 -p udp -j DROP




# Reload configuration
firewall-cmd --reload
