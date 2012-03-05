worker_processes 3
timeout 30
preload_app true

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end

  if defined?(Redis)
    REDIS.quit
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end

  sleep 1
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end

  if defined?(Redis)
    uri = URI.parse(ENV["REDISTOGO_URL"])
    REDIS = Redis.connect(:host => uri.host, :port => uri.port, :password => uri.password)
    Resque.redis = Redis.connect(:host => uri.host, :port => uri.port, :password => uri.password)
    Rails.logger.info('Connected to Redis')
  end
  
  if defined?(Dalli) && Rails.application.config.action_controller.perform_caching
    Rails.cache.reset
  end
  
end