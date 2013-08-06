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
    @id = id
    @hits = @datasift.hits(id)
    render 'review/dummy'
  end
end
