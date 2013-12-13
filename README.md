# EbisuConnection

EbisuConnection supports to connect with Mysql slave servers. It doesn't need Load Balancer.
You can assign a performance weight to each slave server. And slave config is reflected dynamic. 
EbisuConnection uses FreshConnection (https://github.com/tsukasaoishi/fresh_connection).

## Installation

EbisuConnection has tested Rails3.2.16 and Rails4.0.2.

Add this line to your application's Gemfile:

    gem 'ebisu_connection'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ebisu_connection

## Config

config/database.yml

    production:
      adapter: mysql2
      encoding: utf8
      reconnect: true
      database: kaeru
      pool: 5
      username: master
      password: master
      host: localhost
      socket: /var/run/mysqld/mysqld.sock

      slave:
        username: slave
        password: slave
        host: slave

slave is base config to connect to slave servers.
Others will use the master setting. If you want to change, write in the slave.

Config of each slave server fill out config/slave.yaml

    production:
      - "slave1, 10"
      - "slave2, 20"
      -
        host: "slave3"
        weight: 30

config/slave.yaml is checked by end of action. If config changed, it's reflected dynamic. Application doesn't need restart.

    "hostname, weight"

String format is it. You can write config with hash.

### Only master models

config/initializers/ebisu_connection.rb

    EbisuConnection::ConnectionManager.ignore_models = %w|Model1 Model2|

If models that ignore access to slave servers is exist, You can write model name at EbisuConnection::ConnectionManager.ignore models.

## Usage

Read query will be access to slave server.

    Article.where(:id => 1)
    Article.count

If you want to access to master saver, use readonly(false).

    Article.where(:id => 1).readonly(false)

In transaction, Always will be access to master server.

    Article.transaction do
      Article.where(:id => 1)
    end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
