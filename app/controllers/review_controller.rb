include DatasiftHelper

class ReviewController < ApplicationController
  def search
    @balance = DatasiftHelper.balance
    render 'review/search'
  end

  def results
    @balance = DatasiftHelper.balance
    @term = params[:review][:term] || ""
    render 'review/search'
  end

  def search_job_id
    @term = params[:term] || ""
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
