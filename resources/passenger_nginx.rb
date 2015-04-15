#
# Cookbook Name:: application_ruby
# Resources:: passenger_nginx
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

include ApplicationCookbook::ResourceBase

attribute :server_aliases, :kind_of => [Array, NilClass], :default => nil
# Actually defaults to "#{application.name}.conf.erb", but nil means it wasn't set by the user
attribute :webapp_template, :kind_of => [String, NilClass], :default => nil
attribute :port, :kind_of => String, :default => "80"
attribute :ssl_port, :kind_of => String, :default => "443"
attribute :enable_ssl, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil
attribute :passenger_version, :kind_of => String, :default => "5.0.6"
attribute :passenger_ruby, :kind_of => String, :default => "/usr/bin/ruby"
attribute :passenger_root, :kind_of => String, :default => nil
