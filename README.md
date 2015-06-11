# EbisuConnection

[![Gem Version](https://badge.fury.io/rb/ebisu_connection.svg)](http://badge.fury.io/rb/ebisu_connection) [![Build Status](https://travis-ci.org/tsukasaoishi/ebisu_connection.svg?branch=master)](https://travis-ci.org/tsukasaoishi/ebisu_connection) [![Code Climate](https://codeclimate.com/github/tsukasaoishi/ebisu_connection/badges/gpa.svg)](https://codeclimate.com/github/tsukasaoishi/ebisu_connection)

EbisuConnection supports to connect with Mysql slave servers. It doesn't need Load Balancer.
You can assign a performance weight to each slave server. And slave config is reflected dynamic.
EbisuConnection uses FreshConnection (https://github.com/tsukasaoishi/fresh_connection).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ebisu_connection'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install ebisu_connection
```

## Config

config/database.yml

```yaml
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
```

```slave``` is base config to connect to slave servers.
Others will use the master setting. If you want to change, write in the slave.

Config of each slave server fill out config/slave.yaml

```yaml
production:
  - "slave1, 10"
  - "slave2, 20"
  -
    host: "slave3"
    weight: 30
```

config/slave.yaml is checked by end of action. If config changed, it's reflected dynamic. Application doesn't need restart.

```yaml
"hostname, weight"
```

String format is it. You can write config with hash.

### use multiple slave servers group
If you may want to user multiple slave group, write multiple slave group to config/database.yml. 

```yaml
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

  admin_slave:
    username: slave
    password: slave
    host: admin_slaves
```

Config of each slave server fill out config/slave.yaml

```yaml
production:
  slave:
    - "slave1, 10"
    - "slave2, 20"
    -
      host: "slave3"
      weight: 30
  admin_slave:
    - "slave3, 10"
    - "slave4, 20"
```


And call establish_fresh_connection method in model that access to ```admin_slave``` slave group.

```ruby
class AdminUser < ActiveRecord::Base
  establish_fresh_connection :admin_slave
end
```

The children is access to same slave group of parent.

```ruby
class Parent < ActiveRecord::Base
  establish_fresh_connection :admin_slave
end

class AdminUser < Parent
end

class Benefit < Parent
end
```

AdminUser and Benefit access to ```admin_slave``` slave group.


### Declare model that doesn't use slave db

```ruby
class SomethingModel < ActiveRecord::Base
  master_db_only!
end
```

If model that always access to master servers is exist, You may want to write ```master_db_only!```  in model.
The model that master_db_only model's child is always access to master db.

## Usage

Read query will be access to slave server.

```ruby
Article.where(:id => 1)
Article.count
```

If you want to access to the master server, use read_master.

```ruby
Article.where(:id => 1).read_master
```

It is possible to use readonly(false) instead of read_master, but it will be depricated at future version.

In transaction, Always will be access to master server.

```ruby
Article.transaction do
  Article.where(:id => 1)
end
```


### for Unicorn

```ruby
before_fork do |server, worker|
  ...
  ActiveRecord::Base.clear_all_slave_connections!
  ...
end

after_fork do |server, worker|
  ...
  ActiveRecord::Base.establish_fresh_connection
  ...
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Test

I'm glad that you would do test!
To run the test suite, you need mysql installed.
How to setup your test environment.

```bash
bundle install --path .bundle
bundle exec appraisal install
```

This command run the spec suite for all rails versions supported.

```base
bundle exec appraisal rake test
```

