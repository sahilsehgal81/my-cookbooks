#
# Cookbook Name:: hadoops
# Recipe:: default
#
# Copyright 2014, InspiredTechies.com
# Creator: Sahil Sehgal
#
# All rights reserved - Do Not Redistribute
#
#include_recipe 'yum'

package 'openssl' do
action :install
end

bash 'grant key access' do
code <<-EOF
ssh-keygen -t rsa -P ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 authorized_keys
EOF
end

remote_file "#{Chef::Config[:file_cache_path]}/hadoop-1.2.1.tar.gz" do
source "http://mirrors.ibiblio.org/apache/hadoop/common/hadoop-1.2.1/hadoop-1.2.1.tar.gz"
mode '0755'
not_if "which hadoop"
end

if node['hadoop']['ext_dir']
  directory node['hadoop']['ext_dir'] do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end
  ext_dir_prefix = "EXTENSION_DIR=#{node['hadoop']['ext_dir']}"
end


bash 'Install hadoop' do
	cwd Chef::Config[:file_cache_path]
 	code <<-EOF
	tar -xvf hadoop-1.2.1.tar.gz
	cp -r hadoop-1.2.1 /usr/local/hadoop
	EOF
end

directory node['hadoop']['temp_dir'] do
  	owner 'root'
 	group 'root'
	mode '0755'
  	recursive true
end

template_file "/usr/local/hadoop/conf/core-site.xml" do
  	source 'core-site.xml.erb'
  	mode "0644"
end	
	
template_file "/usr/local/hadoop/conf/mapred-site.xml" do
 	 source 'mapred-site.xml.erb'
	  mode "0644"
end  

execute "hadoop namenode -format" do
	command "hadoop namenode -format"
end

execute "service hadoop start" do
	command "sh /usr/local/hadoop/bin/start-all.sh"
end

execute "service hadoop stop" do
	command "sh /usr/local/hadoop/bin/stop-all.sh"
end
