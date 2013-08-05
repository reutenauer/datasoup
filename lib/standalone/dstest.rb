# encoding: UTF-8

require 'yaml'
require 'datasift'

class DataSiftQueryRunner
  def initialize
    dsconfig = YAML::load(File.read(File.join(Rails.root, 'config', 'datasift.yml')))
    @username = dsconfig['username']
    @apikey = dsconfig['apikey']
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
      stop if n == 3

      if interaction
        puts interaction['interaction']['content']
        puts ''
        @output.puts(interaction.inspect)
      end

      n += 1
    end
  end
end
