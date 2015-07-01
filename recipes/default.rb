#
# Cookbook Name:: craftcake
# Recipe:: default
#
# Copyright 2015, yellowfive.com
#
# All rights reserved - Do Not Redistribute
#

package 'java' do
  package_name 'java-1.8.0-openjdk'
  action :install
end

directory "/var/minecraft" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

remote_file "/var/minecraft/minecraft_server.jar" do
  source "https://s3.amazonaws.com/Minecraft.Download/versions/1.8.7/minecraft_server.1.8.7.jar"
  mode '0755'
  notifies :restart, 'service[minecraft]', :delayed
  notifies :run, 'ruby_block[sleep]', :immediately
end

cookbook_file '/var/minecraft/eula.txt' do
  source 'eula.txt'
  mode '0755'
end

template "/var/minecraft/ops.json" do
  source 'ops.json.erb'
  mode '0755'
  variables :ops_settings => node['craftcake']['ops']
  action :create
  notifies :restart, 'service[minecraft]', :delayed
end

template "/etc/init.d/minecraft" do
  source "minecraft.erb"
  mode '0755'
  notifies :restart, 'service[minecraft]', :delayed
end

service 'minecraft' do
  supports :restart => true
  action :start
end

ruby_block "sleep" do
  block do
    sleep(30)
  end
  supports :run => true
  action :nothing
end