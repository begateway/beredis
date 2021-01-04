# BeRedis

BeRedis is an abstraction layer above Redis client for usage with sentinel.
It returns just configured standard Redis client object with some methods patches.

Key features:
- Client object creation does not need to specify replicas ip hardcoded, we use config. 
- Client always do `wait` command after any write operation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'beredis'
```

## Usage


Pure Redis style:

``` 
Redis.new
```

``` 
BeRedis.new
```

## Development

This gem is used by high loaded projects. Do not push to master without pull requests if you are not maintainer.
Any versioning should be accepted by Alexander Shostak or Andrey Novikov. 

## License

This is closed software for internal usage. Distribution is not allowed without permission of Alexander Shostak & Alexander Mihailovsky. 
