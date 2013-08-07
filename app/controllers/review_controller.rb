require 'redis'
include DataSiftHelper

class ReviewController < ApplicationController
  def search
    render 'review/search'
  end

  def results
    @term = params[:review][:term] || ""
    render 'review/search'
  end

  def search_job_id
    @term = params[:term] || ""
    # @hits = @datasift.start("twitter.text contains \"#{@term}\"") # TODO escape!
    # @id = @datasift.dummy
    @id = DataSiftHelper.search(@term)
    render 'review/search_job_id'
  end

  def search_hits
    @id = params[:id]
    @hits = DataSiftHelper.hits(@id)
    puts "Controller: got #{@hits.count} hits so far."
    render 'review/search_hits'
  end
end
