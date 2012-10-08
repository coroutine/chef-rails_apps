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


# Look through all of the "rails_apps" data bags
# to see if any of them need SSL. If so, set a flag
# so we'll install that from the apache2 cookbook.
include_mod_ssl = false
app_configs = node['rails_apps'].map do |dbag_item|
  Chef::EncryptedDataBagItem.load("rails_apps", dbag_item)
end

app_configs.each do |app|
  app['stages'].each do |stage_name, stage_data|
    if stage_data['enable_ssl']
      include_mod_ssl = true
    end
  end
end

include_recipe "apache2::default"
include_recipe "apache2::mod_expires"
if include_mod_ssl
  include_recipe "apache2::mod_ssl"
end
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
