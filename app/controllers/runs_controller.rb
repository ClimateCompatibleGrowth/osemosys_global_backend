class RunsController < ApplicationController
  def index
    @runs = Run.order(id: :desc).limit(10)
  end

  def show
    @run = Run.find(params[:id])
    respond_to do |format|
      format.json
      format.yaml { render 'snakemake_config' }
    end
  end
end
