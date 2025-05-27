# Supermicro-IPMI-Monitoring-Grfana
Templated dashboard for telegraf & influxdb.
The dashboard can monitor SSD status rams, cpus, system tempareture, psus status etc of supermicro node servesr.
Change the hdd.sh and ipmiserver.conf ipmi ips, their username and password,db name and db password.
Set the hdd.sh path in ipmiserver.conf under [[inputs.exec]]
Give permission to .sh file > chmod +x name.sh

list #to chek server measuremnets use below commands 

ipmitool -I lan -H 192.168.0.27 -U Username -P 'Password' sdr 

sudo -u telegraf /etc/path/disk.sh

sudo telegraf --config /etc/path/Supermicro.conf --debug

sudo telegraf --config /etc/path/Supermicro.conf --test | grep -i hdd

tail -f /var/log/path/telegraf.log
SELECT * FROM hdd_status LIMIT 5 #check db data after selecting database.
Once you get this data you are ready to import dashboard.
