#
# Cookbook Name:: rails_apps 
# Recipe:: default
#
# Copyright 2012, Coroutine LLC
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

include_recipe "apache2::default"
include_recipe "apache2::mod_expires"
include_recipe "apache2::mod_xsendfile"
include_recipe "rvm::system"
include_recipe "rvm_passenger::default"
include_recipe "rvm_passenger::apache2"

# NOTE: Set up a role, and define all the attributes required
# by the above recipes. For example:
#
# default_attributes "rvm" => {"install_pkgs" => %w"openssl zlib"}
# override_attributes(
#   "rvm" => {
#     "default_ruby"      => "ruby-1.9.3",
#     "user_default_ruby" => "ruby-1.9.3",
#     "rubies"            => ["1.9.3"]
#   },  
#   "rvm_passenger" => {
#     "version"           => "3.0.11",
#     "default_ruby"      => "ruby-1.9.3",
#     "rvm_ruby"          => "ruby-1.9.3",
#   }
# )
