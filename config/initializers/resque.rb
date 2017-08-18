Resque.redis = Redis.new(:url => 'redis://localhost:6379')
Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
Resque.logger = Logger.new("#{Rails.root}/log/resque.log")
