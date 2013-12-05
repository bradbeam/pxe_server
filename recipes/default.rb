#
# Cookbook Name:: pxe_server
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#

node[:pxe_server][:packages].each do |package|
  package package do
    action :install
  end
end

template "/etc/xinetd.d/tftp" do
  source "tftp.xinetd.erb"
  owner "root"
  group "root"
  mode "0644"
  variables( :tftp_config => node[:pxe_server][:tftp] )
end

directory "/tftpboot" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

link node[:pxe_server][:tftp][:dir] do
  to "/tftpboot"
end

directory "#{node[:pxe_server][:tftp][:dir]}/X86PC/UNDI/pxelinux/pxelinux.cfg" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

# Seemingly complicated way to grep output
files_to_copy = %x(rpm -ql syslinux).split("\n").select{|x| x=~ /(pxelinux.0|menu.c32)/ }
files_to_copy.push("/boot/grub/splash.xpm.gz")
files_to_copy.push("/mnt/cdrom/images/pxeboot/initrd.img")
files_to_copy.push("/mnt/cdrom/images/pxeboot/vmlinuz")

files_to_copy.each do |filename|
  name = ::File.basename(filename)
  file "#{node[:pxe_server][:tftp][:dir]}/X86PC/UNDI/pxelinux/#{name}" do
    action :create
    owner "root"
    group "root"
    mode "0644"
    content ::File.open(filename).read
  end
end

template "/etc/sysconfig/dhcpd" do
  source "dhcpd.sysconfig.erb"
  owner "root"
  group "root"
  mode "0644"
  variables( :dhcpd_args => node[:pxe_server][:dhcpd][:args] )
end

template "/etc/dhcpd.conf" do
  source "dhcpd.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables( :dhcpd => node[:pxe_server][:dhcpd] )
  notifies :restart, "service[dhcpd]"
end

link "/etc/dhcp/dhcpd.conf" do
  to "/etc/dhcpd.conf"
  only_if { ::File.directory?("/etc/dhcp")}
end

template "#{node[:pxe_server][:tftp][:dir]}/X86PC/UNDI/pxelinux/pxelinux.cfg/default" do
  source "default.pxelinux.cfg.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/httpd/conf.d/pxe.conf" do
  source "pxe.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[httpd]"
end

service "httpd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

service "xinetd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

service "dhcpd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end


# #######
# iptables -A MYFW -p udp --dport 69 -s 192.168.100.0/24 -j ACCEPT
# iptables -A MYFW -p udp --dport 68 -s 192.168.100.0/24 -j ACCEPT
# iptables -A MYFW -p tcp --dport 80 -s 192.168.100.0/24 -j ACCEPT
# service iptables save
