require 'redis'
include DataSiftHelper

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

  def search_job_id
    @datasift = DataSiftQueryRunner.new
    @term = params[:term] || ""
    # @hits = @datasift.start("twitter.text contains \"#{@term}\"") # TODO escape!
    # @id = @datasift.dummy
    @id = @datasift.start("twitter.text contains \"#{@term}\"")
    render 'review/search_job_id'
  end

  def search_hits
    @datasift = DataSiftQueryRunner.new
    @id = params[:id]
    @hits = @datasift.hits(@id)
    puts "Controller: got #{@hits.count} hits so far."
    render 'review/search_hits'
  end
end
