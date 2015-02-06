#
# Cookbook Name:: application_ruby
# Provider:: passenger_nginx
#
# Copyright 2014, realzeit GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include Chef::DSL::IncludeRecipe

action :before_compile do

  package "apt-transport-https"
  package "ca-certificates"

  node.override[:nginx][:default_site_enabled] = false
  node.override[:nginx][:source][:modules] = [
    'nginx::passenger',
    'nginx::http_ssl_module',
    'nginx::http_gzip_static_module',
    'nginx::http_stub_status_module'
  ]
  node.override[:nginx][:passenger][:version] = new_resource.passenger_version
  node.override[:nginx][:passenger][:ruby] = new_resource.passenger_ruby
  node.override[:nginx][:passenger][:root] = new_resource.passenger_root
  node.override[:nginx][:source][:passenger][:version] = new_resource.passenger_version
  node.override[:nginx][:source][:passenger][:ruby] = new_resource.passenger_ruby
  node.override[:nginx][:source][:passenger][:root] = new_resource.passenger_root

  include_recipe "nginx::source"
  include_recipe "nginx::passenger"

  unless new_resource.server_aliases
    server_aliases = [ "#{new_resource.application.name}.#{node['domain']}", node['fqdn'] ]
    if node.has_key?("cloud")
      server_aliases << node['cloud']['public_hostname']
    end
    new_resource.server_aliases server_aliases
  end

  r = new_resource
  new_resource.restart_command do
    directory "#{r.application.path}/current/tmp" do
      recursive true
    end
    file "#{r.application.path}/current/tmp/restart.txt" do
      action :touch
    end
  end unless new_resource.restart_command

end

action :before_deploy do

  new_resource = @new_resource

  %w(log pids system config cached-copy vendor_bundle).each do |dir|
    directory "#{new_resource.application.path}/shared/#{dir}" do
      owner new_resource.owner
      group new_resource.group
      mode '0755'
      recursive true
    end
  end

  #%w(current/public).each do |dir|
  #  directory "#{new_resource.application.path}/#{dir}" do
  #    owner new_resource.owner
  #    group new_resource.group
  #    mode '0755'
  #    recursive true
  #  end
  #end

  template "#{node.nginx.dir}/sites-available/#{new_resource.application.name}.conf" do
    cookbook new_resource.cookbook_name.to_s
    #source "nginx.conf.erb"
    source new_resource.webapp_template || "#{new_resource.application.name}.conf.erb"
    mode "0644"
    variables({
      app_name: new_resource.application.name,
      app_root: new_resource.application.path,
      port: new_resource.port || "80",
      enable_ssl: new_resource.enable_ssl || false,
      ssl_port: new_resource.ssl_port || "443",
      server_name: "#{new_resource.application.name}.#{node['domain']}"
    })
  end

  nginx_site "#{new_resource.application.name}.conf"

end

action :before_migrate do
end

action :before_symlink do
end

action :before_restart do
end

action :after_restart do
end
