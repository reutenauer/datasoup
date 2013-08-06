if ENV['REDISTOGO_URL']
  Resque.redis = ENV['REDISTOGO_URL']
end
