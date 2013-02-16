maintainer       "tlowrimore"
maintainer_email "tlowrimore@coroutine.com"
license          "Apache 2.0"
description      "Configures Rails Apps with Apache/Passenger/RVM"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.10"

recipe           "rails_apps::default", "Installs Apache, RVM, and Passenger"
recipe           "rails_apps::setup", "Creates directory structure for Rails apps"
recipe           "rails_apps::apache_config", "Configures Apache, Passenger"
recipe           "rails_apps::logrotate", "Sets up logrotate for Rails logs"
recipe           "rails_apps::create_pg_users_and_dbs", "Creates Postgresql objects for Rails apps"

depends "apache2"
depends "rvm"
depends "rvm_passenger"

recommends "logrotate"

%w{ ubuntu debian }.each do |os|
  supports os
end
