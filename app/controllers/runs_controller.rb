class RunsController < ApplicationController
  def index
    @runs = Run.all.limit(10)
  end
end
