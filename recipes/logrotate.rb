#
# Cookbook Name:: rails_apps 
# Recipe:: logrotate
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

# only try this if we've got the 'logrotate' recipe available:
if node['recipes'].include?('logrotate') || 
   node['recipes'].include?('logrotate::default')
 
  logs = [] # wild-card path for rails logs
  
  # if we've explicitly defined a logrotate set, use that; otherwise, 
  # default to setup set.
  apps = node['logrotate_apps'].empty? ? node['rails_apps'] : node['logrotate_apps'] 
  
  apps.each do |dbag_item|
    app_config = Chef::EncryptedDataBagItem.load("rails_apps", dbag_item)
    appname = app_config['appname']
    app_config['stages'].each do |stage_name, stage_data|
      deploy_user = stage_data['deploy_user'] || "root"
      logs << "/home/#{deploy_user}/#{appname}/#{stage_name}/shared/log/*.log"
    end
  end

  logrotate_app "rails_apps" do
    cookbook "logrotate"
    path logs
    frequency "daily"
    create "644 root adm"
    rotate 7  # logs are removed after being rotated this many times
  end

  logs.each do |log|
    Chef::Log.info("Configured logrotate for #{log}")
  end

else

  Chef::Log.warn("The logrotate recipe is not available, so we're not rotating rails logs!")

end
