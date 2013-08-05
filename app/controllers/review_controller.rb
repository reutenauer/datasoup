class ReviewController < ApplicationController
  def search
    @datasift = DataSiftQueryRunner.new
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
