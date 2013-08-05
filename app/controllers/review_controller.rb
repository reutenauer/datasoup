class ReviewController < ApplicationController
  def search
    render 'review/search'
  end

  def results
    @term = params[:term] || ""
    render 'review/results'
  end
end
