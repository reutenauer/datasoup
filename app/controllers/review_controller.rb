class ReviewController < ApplicationController
  def search
    render 'review/search'
  end

  def results
    @term = params[:review][:term] || ""
    render 'review/search'
  end

  def dummy
    @term = params[:term] || ""
    render 'review/dummy'
  end
end
