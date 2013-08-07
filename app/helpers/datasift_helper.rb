# encoding: UTF-8

require 'yaml'
require 'datasift'
require 'digest'
require 'redis'

module DataSiftHelper
  class StopConsuming < Exception
  end

  # @datasift_config = File.join(Rails.root, 'config', 'datasift.yml')
  @datasift_config = File.expand_path('../../config/datasift.yml', __FILE__)
  if ENV['DATASIFT_APIKEY']
    # FIXME Why we need that is incomprehensible.  Might be a problem
    # with the DataSift library below.
    @username = ENV['DATASIFT_USERNAME'].each_byte.inject("") { |s, b| s + b.chr }
    @apikey = ENV['DATASIFT_APIKEY'].each_byte.inject("") { |s, b| s + b.chr }
  elsif File.file?(@datasift_config)
    dsconfig = YAML::load(File.read(@datasift_config))
    @username = dsconfig['username']
    @apikey = dsconfig['apikey']
  else
    raise
  end
  @user = DataSift::User.new(@username, @apikey)

  def self.user
    @user
  end

  def stopsifting
    # TODO Allow stopping on time too
    @output.close
    raise StopConsuming
  end

  def self.search(search_term)
    unique_id = Digest::SHA1::hexdigest("datasift_query:#{search_term}:#{Time.now.to_i}")
    search_term.gsub(/"/, '\"') # TODO Improve
    query = "twitter.text contains \"#{search_term}\""
    Resque.enqueue(DataSiftQueryJob, unique_id, query) # FIXME Blah
    unique_id
  end

  def dummy
    unique_id = Digest::SHA1::hexdigest("dummy_job:0-query:#{Time.now.to_i}")
    Resque.enqueue(DummyJob, unique_id)
    unique_id
  end

  def self.hits(unique_id)
    score_list = "datasoup:#{unique_id}:score"
    content_list = "datasoup:#{unique_id}:content"
    klout_list = "datasoup:#{unique_id}:klout"
    l = REDIS.llen(score_list) # TODO check == llen("#{unique_id}:content")
    l.times.inject([]) do |hits, i|
      hits << [REDIS.lindex(score_list, i).to_i, REDIS.lindex(content_list, i), REDIS.lindex(klout_list, i)]
    end
  end

  def self.balance
    @user.getBalance['credit']
  end

  def sentiment_to_grade(score_array)
    grade = ((score_array.average + 20) / 4).round(1)
    "#{grade} / 10"
  end
end
