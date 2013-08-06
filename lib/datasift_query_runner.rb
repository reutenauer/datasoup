# encoding: UTF-8

require 'yaml'
require 'datasift'
require 'digest'
require 'redis'

class DataSiftQueryRunner
  class StopConsuming < Exception
  end

  attr_reader :results, :user, :output

  def initialize(results = 3)
    @results = results
    datasift_config = File.join(Rails.root, 'config', 'datasift.yml')
    if ENV['DATASIFT_APIKEY']
      # FIXME Why we need that is incomprehensible.  Might be a problem
      # with the DataSift library below.
      @username = ENV['DATASIFT_USERNAME'].each_byte.inject("") { |s, b| s + b.chr }
      @apikey = ENV['DATASIFT_APIKEY'].each_byte.inject("") { |s, b| s + b.chr }
    elsif File.file?(datasift_config)
      dsconfig = YAML::load(File.read(datasift_config))
      @username = dsconfig['username']
      @apikey = dsconfig['apikey']
    else
      raise
    end
    @user = DataSift::User.new(@username, @apikey)
    @output = File.open(File.join(Rails.root, 'public', 'datasoup.txt'), 'a')
  end

  def stop
    # TODO Stop on time
    @output.close
    raise StopConsuming
  end

  def start(query)
    unique_id = Digest::SHA1::hexdigest("datasift_query:#{query}:#{Time.now.to_i}")
    Resque.enqueue(DataSiftQueryJob, unique_id, query) # FIXME Blah
    unique_id
  end

  def dummy
    unique_id = Digest::SHA1::hexdigest("dummy_job:0-query:#{Time.now.to_i}")
    Resque.enqueue(DummyJob, unique_id)
    unique_id
  end

  def hits(unique_id)
    score_list = "datasoup:#{unique_id}:score"
    content_list = "datasoup:#{unique_id}:content"
    klout_list = "datasoup:#{unique_id}:klout"
    l = REDIS.llen(score_list) # TODO check == llen("#{unique_id}:content")
    l.times.inject([]) do |hits, i|
      hits << [REDIS.lindex(score_list, i).to_i, REDIS.lindex(content_list, i), REDIS.lindex(klout_list, i)]
    end
  end

  def balance
    @user.getBalance['credit']
  end
end

class DummyJob
  @queue = :dummy
  include Resque::Plugins::UniqueJob

  def self.perform(unique_id)
    redis = Redis.new
    10.times.inject([]) do |result, i|
      sleep(2)
      redis.rpush("datasoup:#{unique_id}:score", 4 * i - 20)
      redis.rpush("datasoup:#{unique_id}:content", "Result no. #{i} for query.")
    end
  end
end

class DataSiftQueryJob
  @queue = :datasift_query
  include Resque::Plugins::UniqueJob

  def self.perform(unique_id, query)
    puts "DataSiftQuery worker called for query “#{query}” with ID #{unique_id}"
    qr = DataSiftQueryRunner.new
    nb_results = qr.results
    user = qr.user
    output = qr.output
    definition = user.createDefinition(query)
    consumer = definition.getConsumer(DataSift::StreamConsumer::TYPE_HTTP)
    n = 0
    begin
      consumer.consume(true) do |interaction|
        stop if n == nb_results

        if interaction
          if interaction['salience']
            sentiment = interaction['salience']['content']['sentiment']
          else
            sentiment = nil
          end
          if sentiment
            REDIS.rpush("datasoup:#{unique_id}:score", sentiment)
            REDIS.rpush("datasoup:#{unique_id}:content", interaction['interaction']['content'])
            if interaction['klout']
              REDIS.rpush("datasoup:#{unique_id}:klout", interaction['klout']['score'])
            else
              REDIS.rpush("datasoup:#{unique_id}:klout", "nil")
            end
          end
          puts "#{sentiment}: #{interaction['interaction']['content']}"
          output.puts(interaction.inspect)
          n += 1 if sentiment != nil and sentiment != 0
        end
      end
    rescue DataSiftQueryRunner::StopConsuming
    end

  end
end

module DataSiftHelper
  def sentiment_to_grade(score_array)
    grade = ((score_array.average + 20) / 4).round(1)
    "#{grade} / 10"
  end
end
