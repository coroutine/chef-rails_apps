Description
===========
This cookbook defines recipes useful for configuring Rails Apps running on:

* Apache
* Passenger
* RVM

It configures Apache, and sets up the initial directory structure
for the application using values defined in a data bag.

Requirements
============
This cookbook requires the following cookbooks:

* Opscode's [apache2](https://github.com/opscode/cookbooks/tree/master/apache2)
* Fletcher Nichol's [rvm](https://github.com/fnichol/chef-rvm)
* Fletcher Nichol's [rvm_passenger](https://github.com/fnichol/chef-rvm_passenger)

Attributes
==========
This cookbook defines one attribute:
    
    node[:rails_apps] = []

This attribute should specify the data bag items that should be read from the `rails_apps` data bag. You must define this in a role

    default_attributes(
      "rails_apps" => ["item_name"]
    )

Usage
=====
The following recipes are defined:

* `default` - Installs Apache, RVM, and Passenger. You may want override the default attributes for each of these recipes.
* `setup` - creates intial directory structure for rails apps, using a layout similar to that which capistrano would expect.
* `apache_config` - Configures Apache/Passenger.


The `rails_apps` data bag
-------------------------
You should have an `rails_apps` data bag, and each item should contain the following information. Notice each app's `stages` contain database information that will get written to a `database.yml` file.

    "id": "YOUR_APP_NAME",
    "stages": {
        "production": {
            "deploy_user":"USERNAME",
            "deploy_group":"GROUPNAME",
            "hostname":"example.com",
            "aliases":["www.example.com", ],
            "min_instances":0,
            "redirect_from":"",
            "enable":false,
            "enable_ssl":true, 
            "ssl_port":"443",
            "ssl_cert_file":"/path/to/private.crt",
            "ssl_cert_key_file":"/path/to/private.key",
            "ssl_cert_chain_file":"/path/to/ca-bundle",
            "database" : {
                "adapter": "postgresql",
                "dbname":  "DATABASENAME",
                "host": "127.0.0.1",
                "port": 5432,
                "username": "DATABASEUSERNAME",
                "password": "DATABASEPASSWORD"
                "encoding": "unicode",
                "reconnect": "true",
                "pool":"25",
                "timeout":"5000"
            }
        }
    }

Apps directories will be owned by `deploy_user`:`deploy_group`. The directory structure for each app will be as follows:

    /home/deploy_user/app_name/stage_name

License and Author
==================

Author:: Brad Montgomery (<bmontgomery@coroutine.com>)

Copyright 2012, Coroutine.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

