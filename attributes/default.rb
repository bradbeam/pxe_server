default[:pxe_server][:packages] = [ "tftp-server", "dhcp", "syslinux", "httpd" ]

default[:pxe_server][:tftp][:dir] = "/var/lib/tftpboot"
default[:pxe_server][:tftp][:socket_type] = "dgram"
default[:pxe_server][:tftp][:protocol] = "udp"
default[:pxe_server][:tftp][:wait] = "yes"
default[:pxe_server][:tftp][:user] = "root"
default[:pxe_server][:tftp][:server] = "/usr/sbin/in.tftpd"
default[:pxe_server][:tftp][:server_args] = "-s #{node[:pxe_server][:tftp][:dir]}"
default[:pxe_server][:tftp][:disable] = "no"
default[:pxe_server][:tftp][:per_source] = "11"
default[:pxe_server][:tftp][:cps] = "100 2"
default[:pxe_server][:tftp][:flags] = "IPv4"

default[:pxe_server][:dhcpd][:args] = "eth1"
default[:pxe_server][:dhcpd][:subnet] = "192.168.100.0"
default[:pxe_server][:dhcpd][:netmask] = "255.255.255.0"
default[:pxe_server][:dhcpd][:domainname] = "example.com"
default[:pxe_server][:dhcpd][:routers] = "192.168.100.1"
default[:pxe_server][:dhcpd][:dns_servers] = "192.168.100.1"
default[:pxe_server][:dhcpd][:subnetmask] = "255.255.255.0"
default[:pxe_server][:dhcpd][:range] = "192.168.100.100 192.168.100.254"

#default[:pxe_server][:]