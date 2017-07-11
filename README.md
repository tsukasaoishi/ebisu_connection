# EbisuConnection
[![Gem Version](https://badge.fury.io/rb/ebisu_connection.svg)](http://badge.fury.io/rb/ebisu_connection) [![Build Status](https://travis-ci.org/tsukasaoishi/ebisu_connection.svg?branch=master)](https://travis-ci.org/tsukasaoishi/ebisu_connection) [![Code Climate](https://codeclimate.com/github/tsukasaoishi/ebisu_connection/badges/gpa.svg)](https://codeclimate.com/github/tsukasaoishi/ebisu_connection)

EbisuConnection allows access to replica servers.  
You could assign a performance weight to each replica server.

```
Rails ------------ Master DB
             |
             | 
             +---- Replica1 DB (weight 10)
             |
             |
             +---- Replica2 DB (weight 20)
```

If you could put a load balancer in front of replica servers, should use [FreshConnection](https://github.com/tsukasaoishi/fresh_connection).

## Usage
### Access to Replica
Read query goes to the replica server.

```ruby
Article.where(:id => 1)
```

### Access to Master
If read query want to access to the master server, use `read_master`.  
In before version 0.3.1, can use `readonly(false)`.

```ruby
Article.where(:id => 1).read_master
```

In transaction, All queries go to the master server.

```ruby
Article.transaction do
  Article.where(:id => 1)
end
```

Create, Update and Delete queries go to the master server.

```ruby
article = Article.create(...)
article.title = "FreshConnection"
article.save
article.destory
```

## Support ActiveRecord version
EbisuConnection supports ActiveRecord version 4.2 or later.
If you are using Rails 4.1 or 4.0, you can use EbisuConnection version 2.1.0 or before.
If you are using Rails 3.2, could use EbisuConnection version 1.0.0 or before.

## Support DB
EbisuConnection supports MySQL and PostgreSQL.

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

  replica:
    username: replica
    password: replica
    host: replica
```

```replica``` is a config to connect to replica servers.  
Others will use the master server settings.  
  
Config of each replica server fill out to `config/replica.yml`

```yaml
production:
  - "replica1, 10"
  - "replica2, 20"
  -
    host: "replica3"
    weight: 30
```

```yaml
"hostname, weight"
```

String format is it. You can write config with hash.

### use multiple replica servers group
If you may want to user multiple replica group, write multiple replica group to config/database.yml. 

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

  replica:
    username: replica
    password: replica
    host: replica

  admin_replica:
    username: replica
    password: replica
    host: admin_replica
```

Config of each replica server fill out to `config/replica.yml`

```yaml
production:
  replica:
    - "replica1, 10"
    - "replica2, 20"
    -
      host: "replica3"
      weight: 30
  admin_replica:
    - "replica4, 10"
    - "replica5, 20"
```

And call establish_fresh_connection method in model that access to ```admin_replica``` replica group.

```ruby
class AdminUser < ActiveRecord::Base
  establish_fresh_connection :admin_replica
end
```

The children is access to same replica group of parent.

```ruby
class Parent < ActiveRecord::Base
  establish_fresh_connection :admin_replica
end

class AdminUser < Parent
end

class Benefit < Parent
end
```

AdminUser and Benefit access to ```admin_replica``` replica group.


### Declare model that doesn't use replica db

```ruby
class SomethingModel < ActiveRecord::Base
  master_db_only!
end
```

If model that always access to master servers is exist, You may want to write ```master_db_only!```  in model.
The model that master_db_only model's child is always access to master db.

### for Unicorn

```ruby
before_fork do |server, worker|
  ...
  ActiveRecord::Base.clear_all_replica_connections!
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
./bin/setup
```

This command run the spec suite for all rails versions supported.

```base
./bin/test
```

