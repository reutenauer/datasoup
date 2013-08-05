# encoding: UTF-8

require 'yaml'
require 'datasift'

class DataSiftQueryRunner
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
    @output = File.open('datasoup.out', 'a')
  end

  def stop
    @output.close
    exit(0)
  end

  def start(query)
    definition = @user.createDefinition(query)
    consumer = definition.getConsumer(DataSift::StreamConsumer::TYPE_HTTP)
    n = 0
    consumer.consume(true) do |interaction|
      stop if n == @results

      if interaction
        if interaction['salience']
          sentiment = interaction['salience']['content']['sentiment']
        else
          sentiment = nil
        end
        puts "Sentiment = #{sentiment}: #{interaction['interaction']['content']}"
        puts ''
        @output.puts(interaction.inspect)
        n += 1 if sentiment != nil and sentiment != 0
      end
    end
  end

  def balance
    @user.getBalance['credit']
  end
end
