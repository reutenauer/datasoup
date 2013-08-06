require 'redis'

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
    # @hits = @datasift.start("twitter.text contains \"#{@term}\"") # TODO escape!
    @id = @datasift.dummy
    render 'review/dummy.txt'
  end

  def dummy2
    @datasift = DataSiftQueryRunner.new
    @id = params[:id]
    @hits = @datasift.hits(@id)
    puts "Controller: got #{@hits.count} hits so far."
    render 'review/dummy2'
  end
end
