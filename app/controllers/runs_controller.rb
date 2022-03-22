class RunsController < ApplicationController
  def index
    @runs = Run.order(id: :desc).limit(10)
  end

  def show
    @run = Run.find_by(slug: params[:slug])

    render_not_found and return unless @run

    respond_to do |format|
      format.json
      format.yaml { render 'snakemake_config' }
    end
  end

  def create
    @run = Run.new(run_params)
    if @run.save
      render :show
    else
      render json: { errors: @run.errors.to_s }
    end
  end

  private

  def run_params
    params.permit(:name)
  end

  def render_not_found
    render json: { error: 'No run with that slug found.' }, status: :not_found
  end
end
