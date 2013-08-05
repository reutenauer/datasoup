class ReviewController < ApplicationController
  def search
    render 'review/search'
  end

  def results
    @term = params[:review][:term] || ""
    render 'review/search'
  end
end
