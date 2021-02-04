class BeRedisConfig
  include Singleton

  attr_reader :config

  def self.cluster_mode?
    BeRedisConfig.instance.config_loaded? && !BeRedisConfig.instance.nodes.empty?
  end

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

  def unload!
    @config = nil
  end
end

