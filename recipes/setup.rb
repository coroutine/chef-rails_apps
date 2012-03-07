#
# Cookbook Name:: rails_apps 
# Recipe:: setup
#
# Copyright 2012, Coroutine
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

include_recipe "rvm"

app_configs = []
node['rails_apps'].each do |dbag_item|
  search(:rails_apps, "id:#{dbag_item}") do |item|
    app_config << item
  end
end

app_configs.each do |app|

  appname = app['id']

  # Set up directories for each stage
  app['stages'].each do |stage_name, stage_data|
    
    deploy_user = stage_data['deploy_user'] || "root"
    deploy_group = stage_data['deploy_group'] || "root"
    base_path = "/home/#{deploy_user}/#{appname}/#{stage_name}"    
    instance_name = [appname, stage_name].join("_")
 
    # Create directories for all the apps and their stages
    app_directories = [
      base_path,
      "#{base_path}/releases",
      "#{base_path}/shared",
      "#{base_path}/shared/system",
    ]
    app_directories.each do |dir|
      directory dir do
        owner deploy_user
        group deploy_group
        mode "2755" # set gid so group sticks if it's different than user
        action :create
        recursive true  # mkdir -p
      end
    end
  
    # write database.yml files in a shared directory
    template "#{base_path}/shared/system/database.yml" do
      source "database.yml.erb"
      owner deploy_user
      group deploy_group
      mode "0600"
      variables(
        :stage_name => stage_name,
        :adapter    => stage_data['database']['adapter'],
        :dbname     => stage_data['database']['dbname'],
        :pool       => stage_data['database']['pool'],
        :timeout    => stage_data['database']['timeout'],
        :reconnect  => stage_data['database']['reconnect'],
        :encoding   => stage_data['database']['encoding'],
        :username   => stage_data['database']['username'],
        :password   => stage_data['database']['password']
      )
    end 
 
    # Make sure the deploy_user still owns everything 
    # in their directory.
    bash "Set Directory Owner" do
      user "root"
      cwd "/home/#{deploy_user}"
      code <<-EOH
        chown -R #{deploy_user}:#{deploy_group} *
      EOH
    end
  end 
end
