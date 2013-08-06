# encoding: UTF-8

require 'yaml'
require 'datasift'

class DataSiftQueryRunner
  class StopConsuming < Exception
  end

  def initialize(results = 3)
    @results = results
    if ENV['DATASIFT_APIKEY']
    datasift_config = File.join(Rails.root, 'config', 'datasift.yml')
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
    hits = []
    definition = @user.createDefinition(query)
    consumer = definition.getConsumer(DataSift::StreamConsumer::TYPE_HTTP)
    n = 0
    begin
      consumer.consume(true) do |interaction|
        stop if n == @results

        if interaction
          if interaction['salience']
            sentiment = interaction['salience']['content']['sentiment']
          else
            sentiment = nil
          end
          hits << [sentiment, interaction['interaction']['content']] if sentiment
          @output.puts(interaction.inspect)
          n += 1 if sentiment != nil and sentiment != 0
        end
      end
    rescue StopConsuming
    end

    hits
  end

  def dummy
    Resque.enqueue(DummyJob)
  end

  def balance
    @user.getBalance['credit']
  end
end

class DummyJob
  @queue = :dummy
  include Resque::Plugins::UniqueJob

  def self.perform
    10.times.inject([]) do |result, i|
      sleep(2)
      result << [4 * i - 20, "Result no. #{i} for query."]
    end
  end
end
