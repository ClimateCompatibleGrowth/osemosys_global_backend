class RunsController < ApplicationController
  def index
    @runs = Run.order(id: :desc).limit(10)
  end
end
