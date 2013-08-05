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
    render 'review/dummy'
  end
end
