require 'redis'

class ReviewController < ApplicationController
  def search
    @datasift = DataSiftQueryRunner.new
    render 'review/search'
  end

  def results
    @datasift = DataSiftQueryRunner.new
    @term = params[:review][:term] || ""
    render 'review/search'
  end

  def dummy
    @datasift = DataSiftQueryRunner.new
    @term = params[:term] || ""
    # @hits = @datasift.start("twitter.text contains \"#{@term}\"") # TODO escape!
    id = @datasift.dummy
    redis = Redis.new
    score_list = "#{unique_id}:score"
    content_list = "#{unique_id}:content"
    l = redis.llen(score_list) # TODO check == llen("#{unique_id}:content")
    @hits = l.times.inject([]) do |hits, i|
      hits << [redis.lindex(score_list, i, redis.lindex(content_list, i)]
    end
    render 'review/dummy'
  end
end
