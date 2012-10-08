Description
===========
This cookbook defines recipes useful for configuring Rails Apps running on:

* Apache
* Passenger
* RVM

It configures Apache, and sets up the initial directory structure
for the application using values defined in an *encrypted* data bag.

Requirements
============
This cookbook requires the following cookbooks:

* Opscode's [apache2](https://github.com/opscode/cookbooks/tree/master/apache2)
* Fletcher Nichol's [rvm](https://github.com/fnichol/chef-rvm)
* Fletcher Nichol's [rvm_passenger](https://github.com/fnichol/chef-rvm_passenger)

You will also need to create a _shared key_ for the encrypted data bag. Read *Usage* 
for more information.

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

* `default` - Installs Apache, RVM, and Passenger. You may want override the default attributes for each of these recipes. Also installs several Apache modules: `mod_expires`, `mod_xsendfile`, and `mod_ssl` (if any of the data bags specify `enable_ssl`)
* `setup` - creates intial directory structure for rails apps, using a layout similar to that which capistrano would expect.
* `apache_config` - Configures Apache/Passenger.

Set up an Encrypted Data Bag
----------------------------
This cookbook reaquires an *encrypted* data bag named `rails_apps`. This requires that the Chef Server 
and all nodes have a shared secret key. *You'll need to make sure each node has a copy of the key in
the default location*: `/etc/chef/encrypted_data_bag_secret`. You'll also need a copy on 
your managment system. You can generate a key by running the following command:

    openssl rand -base64 512 | tr -d '\r\n' > ~/.chef/encrypted_data_bag_secret

Now, create a regular data bag if you haven't already:

    knife data bag create rails_apps 

Then, create an encrypted item for your app: 

    knife data bag create rails_apps <appname> --secret-file ~/.chef/encrypted_data_bag_secret

Each value in the JSON file will be encrypted. You can save this file locally by running:

    knife data bag show rails_apps <appname> -Fj > data_bags/rails_apps/<appname>.json

You can also edit existing data bags by running:

    knife data bag edit rails_apps <appname> --secret-file ~/.chef/encrypted_data_bag_secret

The `rails_apps` data bag
-------------------------
Each item in the `rails_apps` data bag should contain the following information. Notice 
each app's `stages` contain database information that will get written to a `database.yml` file.

    "id": "UNIQUE_DATA_BAG_ID",
    "appname":"YOUR_APP_NAME",
    "stages": {
        "production": {
            "deploy_user":"USERNAME",
            "deploy_group":"GROUPNAME",
            "hostname":"example.com",
            "aliases":["www.example.com", ],
            "min_instances":0,
            "redirect_from":"",
            "enable":false,
            "ip_address":"192.168.0.1",  # may also be "*",
            "enable_send_file_allow_above":false,   # see XSendFile notes below
            "send_file_path":"/home/deploy/shared/files",
            "enable_ssl":true, 
            "ssl_port":"443",
            "ssl_cert_file":"CONTENT-OF-SSL-CERT-FILE-AS-AN-ARRAY",
            "ssl_cert_key_file":"CONTENT-OF-SSL-CERT-KEY-FILE-AS-AN-ARRAY",
            "ssl_cert_chain_file":"CONTENT-OF-SSL-CERT-BUNDLE-FILE-AS-AN-ARRAY",
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
    
### XSendFile Notes:
The `enable_send_file_allow_above` attribute adds the `XSendFileAllowAbove on` declaration to the apache config.  By default, we do not include this delcaration as 
it's deprecated in modern versions of XSendFile.  Typically, this should only be enabled when provisioning nodes with older distros.

The `send_file_path` attribute adds the `XSendFilePath <absolute path>` declaration to the apache config.  This is the current method for defining paths from which files
are sent.  This method supersedes `XSendFileAllowAbove`.

### SSL notes: 
The `ssl_cert_file`, `ssl_cert_key_file`, and `ssl_cert_chain_file`, entries must be listed as an array, where each line of text in the file is an element in the array. For example:

    "ssl_cert_file":[
        '-----BEGIN CERTIFICATE-----', 
        'MIID1DCCArwCCQCmIu63Dgum5zANBgkqhkiG9w0BAQUFADCBqzELMAkGA1UEBhMC', 
        'pEHhcc5trTnv+L8R0i7wlsxW6B0M3BROFrDQa8fZsmFbUTSlIqExC+gsxF7OkzGr', 
            # ...
        'VwSASh4x2fcll27jmyc1BgfLcIIrvYJMzyPF+epzsvLL3DuVHodRm8zTM7JIQnT8', 
        '8DCBC4i2TeH+OV6jLZegXEmsvukWVgzL', 
        '-----END CERTIFICATE-----'
    ]

If your app does not use SSL certs, you can omit `ssl_port`, `ssl_cert_file`, `ssl_cert_key_file`, and `ssl_cert_chain_file`, though you *should* include `enable_ssl:false`.

### Application Directories
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

