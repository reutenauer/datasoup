class ReviewController < ApplicationController
  def search
    render 'review/search'
  end

  def results
    @term = params['review']['term'] || ""
    render 'review/results'
  end
end
