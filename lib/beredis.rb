require "beredis/version"
require 'redis'
require 'forwardable'
require 'singleton'
require 'json'

class BeRedisConfig
  include Singleton

  attr_reader :config

  def load_config(json)
    @config = JSON.parse(json, symbolize_names: true)
  end

  def nodes
    if config_loaded?
      @config[:nodes]
    else
      []
    end
  end

  def config_loaded?
    !@config.nil?
  end
end

class BeRedis < Redis
  # We do not use method_missing because of mutex locking bug
  MIN_REPLICAS_SYNC = 1
  REDIS_SYNC_TIMEOUT = 1000

  REDIS_WRITE_METHODS = [ :lpush, :lpushx, :rpush, :rpushx, :lpop, :rpop, :rpoplpush, :_bpop, :blpop, :brpop,
                          :brpoplpush, :lset, :linsert, :ltrim, :sadd, :spop, :smove, :sinter, :sinterstore,
                          :sunion, :sunionstore, :zadd, :zincrby, :zrem, :zpopmax,
    :zpopmin, :bzpopmax, :bzpopmin, :unlink, :rename, :zremrangebyrank,:zremrangebyscore, :zinterstore, :zunionstore,
    :hset, :hsetnx, :hmset, :mapped_hmset, :hdel, :hincrby, :hincrbyfloat, :pfadd, :pfmerge, :geoadd,
    :xadd, :xtrim, :xdel, :xgroup, :xreadgroup, :xack, :xclaim, :xpending, :bgrewriteaof, :bgsave,
    :flushall, :flushdb, :persist, :expire, :expireat, :pexpire, :pexpireat, :del, :move, :renamenx, :decr,
    :decrby, :incr, :incrby, :incrbyfloat, :set, :setex, :psetex, :setnx, :mset, :mapped_mset, :msetnx, :mapped_msetnx,
    :setbit, :setrange
  ]

  REDIS_VANILLA_METHODS = [:bitpos, :getset, :strlen, :llen,
                           :exists?, :time, :lindex, :lrange, :lrem,
                           :scard, :srem, :srandmember, :sismember, :smembers, :sdiff, :sdiffstore,
                           :zcard, :zscore, :zrange, :monitor, :zrevrange, :zrank, :zrevrank,
                           :zlexcount, :zrangebylex, :zrevrangebylex, :zrangebyscore, :zrevrangebyscore,
                           :zcount, :hlen, :hget, :hmget, :mapped_hmget, :hexists, :hkeys, :hvals, :hgetall,
                           :publish,
                           :subscribed?, :subscribe, :subscribe_with_timeout, :unsubscribe, :psubscribe,
                           :psubscribe_with_timeout, :punsubscribe, :pubsub,
                           :watch, :unwatch, :pipelined, :multi, :discard,
                           :script, :evalsha,
                           :scan_each, :hscan, :hscan_each, :zscan, :zscan_each, :sscan,
                           :sscan_each, :pfcount, :geohash, :georadius, :georadiusbymember, :geopos,
                           :geodist, :xinfo, :xrange, :xrevrange, :xlen, :xread,
                           :inspect, :sentinel, :method_missing, :asking, :connection,
                           :id, :call, :dup, :keys, :sort, :select, :echo, :type, :dump, :synchronize, :cluster, :client,
                           :restore, :config, :scan, :with_reconnect, :without_reconnect, :connected?, :disconnect!, :queue,
                           :commit, :exec, :quit, :auth, :ping,
                           :get, :dbsize, :debug,
                           :info, :lastsave, :save, :shutdown, :slaveof, :slowlog,
                           :ttl, :sync, :pttl, :migrate, :exists, :object, :randomkey,  :close,
                           :mget, :mapped_mget,
                           :getrange, :getbit, :append, :bitcount, :bitop, :eval, :mon_try_enter, :try_mon_enter,
                           :mon_enter, :mon_exit, :mon_synchronize, :new_cond,

                           # :instance_of?, :public_send,
                           # :instance_variable_get, :instance_variable_set, :instance_variable_defined?,
                           # :remove_instance_variable, :private_methods, :kind_of?, :instance_variables, :tap,
                           # :method, :public_method, :singleton_method, :is_a?, :extend, :define_singleton_method, :to_enum,
                           # :enum_for, :<=>, :===, :=~, :!~, :eql?, :respond_to?, :freeze, :display, :send,
                           # :to_s, :nil?, :hash, :class, :singleton_class, :clone, :itself, :taint, :tainted?, :untaint,
                           # :untrust, :trust, :untrusted?, :methods, :protected_methods, :frozen?,
                           # :public_methods, :singleton_methods, :!, :==, :!=, :equal?, :instance_eval,
                           #:instance_exec
  ]

  extend Forwardable
  def_delegators :@client, *REDIS_VANILLA_METHODS

  def initialize(*args)
    if cluster_mode?
      @client = Redis.new(cluster: BeRedisConfig.instance.nodes)
    else
      STDERR.puts "="*40
      STDERR.puts "WARNING! BeRedis not in cluster mode"
      STDERR.puts "="*40
      @client = Redis.new(*args)
    end
    @client
  end

  def cluster_mode?
    BeRedisConfig.instance.config_loaded? && !BeRedisConfig.instance.nodes.empty?
  end

  REDIS_WRITE_METHODS.each do |method_name|
    define_method(method_name) do |*args, &block|
      result = @client.set(*args)
      @client.wait(MIN_REPLICAS_SYNC, REDIS_SYNC_TIMEOUT) if cluster_mode?
      result
    end
  end
end
