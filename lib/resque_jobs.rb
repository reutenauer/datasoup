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
  include DataSiftHelper

  def self.perform(unique_id, query)
    puts "DataSiftQuery worker called for query “#{query}” with ID #{unique_id}"
    nb_results = 3
    output = File.open(File.join(Rails.root, 'public', 'datasoup.txt'), 'a')

    user = DataSiftHelper.user
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
