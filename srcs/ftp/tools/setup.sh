#!/bin/bash

# Create FTP user if doesn't exist
if ! id -u $FTP_USER > /dev/null 2>&1; then
    useradd -m -d /home/$FTP_USER $FTP_USER
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
fi

# Create WordPress directory if it doesn't exist
mkdir -p /var/www/html
chown -R $FTP_USER:$FTP_USER /var/www/html

# Configure vsftpd
cat > /etc/vsftpd.conf << EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
pasv_enable=YES
pasv_min_port=21000
pasv_max_port=21010
pasv_address=0.0.0.0
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
allow_writeable_chroot=YES
EOF

# Add FTP user to allowed users list
echo $FTP_USER > /etc/vsftpd.userlist

# Start vsftpd
exec /usr/sbin/vsftpd /etc/vsftpd.conf
