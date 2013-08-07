require 'redis'
include DatasiftHelper

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
    @id = DatasiftHelper.search(@term)
    render 'review/search_job_id'
  end

  def search_hits
    @id = params[:id]
    @hits = DatasiftHelper.hits(@id)
    puts "Controller: got #{@hits.count} hits so far."
    render 'review/search_hits'
  end
end
