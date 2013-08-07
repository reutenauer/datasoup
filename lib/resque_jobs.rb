$LOAD_PATH << File.expand_path('../../app/helpers', __FILE__)
require 'datasift_helper'

class DataSiftQueryJob
  @queue = :datasift_query
  include Resque::Plugins::UniqueJob
  include DatasiftHelper

  def self.perform(unique_id, query)
    puts "DataSiftQuery worker called for query “#{query}” with ID #{unique_id}"
    nb_results = 3
    output = File.open(File.join(Rails.root, 'public', 'datasoup.txt'), 'a')

    user = DatasiftHelper.user
    definition = user.createDefinition(query)
    consumer = definition.getConsumer(DataSift::StreamConsumer::TYPE_HTTP)
    n = 0
    begin
      consumer.consume(true) do |interaction|
        stopsifting if n == nb_results

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
    rescue StopConsuming
    end

  end
end
