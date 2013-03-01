#
# Cookbook Name:: rails_apps
# Recipe:: create_pg_users_and_dbs
#
# Copyright 2013, Coroutine LLC
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
#
# --------------------------------------
# Sample Item from the specified Databag
# --------------------------------------
# {
#    "id": "postgresql_setup_wfp",
#    "users": [
#        {
#            "username":"some_user",
#            "password":"some_password",
#            "superuser": "true",
#        }
#    ],
#    "databases": [
#        {
#            "name":"some_db",
#            "owner":"some_user",
#            "template":"template0",
#            "encoding": "UTF8",
#            "locale": "en_US.utf8"
#        }
#    ]
# }
# --------------------------------------


# Fetch the setup items from the Databag; It contains things like Database users,
# passwords, DB names and encoding.
setup_items = []
node['rails_apps'].each do |dbag_item|
  # NOTE: shared secret must be in "/etc/chef/encrypted_data_bag_secret"
  Chef::Log.info("fetching #{dbag_item} from Encrypted 'rails_apps' data bag")
  i = Chef::EncryptedDataBagItem.load("rails_apps", dbag_item)
  Chef::Log.info("found #{i}")
  setup_items << i
end

# We use a mix of psql commands and SQL statements to create users.
#
# To Create a User:
#     sudo -u postgres createuser -s some_user
#
# To set their password:
#     sudo -u postgres psql -c "ALTER USER some_user WITH PASSWORD 'secret';"
#
# To create a Database
#     sudo -u postgres createdb -E UTF8 -O some_user \
#          -T template0 database_name --local=en_US.utf8
#
# To make these idempotent, we test for existing users/databases;
# Test for existing DB:
#     sudo -u postgres psql -l | grep database_name
#
# Test for existing Users
#     sudo -u postgres psql -c "\du" | grep some_user

setup_items.each do |setup|
  setup["stages"].each do |stage, stage_config|
    db_config = stage_config['database']
    user_name = db_config['username']
    db_name   = db_config['dbname']

    create_user_command = begin
        ["sudo -u postgres createuser #{user_name}",
        " --no-superuser", "--no-createdb", "--no-createrole", ";"].join(' ')
    end

    set_user_password = begin
        "sudo -u postgres psql -c \"ALTER USER #{user_name} " +
        "WITH PASSWORD '#{db_config['password']}';\""
    end

    bash "create_user" do
      user "root"
      code <<-EOH
        #{create_user_command}
        #{set_user_password}
      EOH
      not_if "sudo -u postgres psql -c \"\\du\" | grep #{user_name}"
    end

    create_database_command = begin
      ["sudo -u postgres createdb #{db_name}",
        "--owner=#{user_name} ", "--encoding=#{db_config['encoding']}",
        "--locale=#{db_config['locale']}", "--template=#{db_config['template']}"].join(' ')
    end

    bash "create_database" do
      user "root"
      code <<-EOH
        #{create_database_command}
      EOH
      not_if "sudo -u postgres psql -l | grep #{db_name}"
    end
  end

end
