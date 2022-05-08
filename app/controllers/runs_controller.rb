class RunsController < ApplicationController
  include ActionController::Helpers
  helper AttachmentUrlHelpers

  def index
    page_size = params[:limit] || 10
    @runs = Run.order(id: :desc).limit(page_size)
  end

  def show
    @run = Run.find_by(slug: params[:slug])

    render_not_found and return unless @run

    @disable_interconnector = params[:disable_interconnector] == 'true'
    respond_to do |format|
      format.json
      format.yaml { render 'snakemake_config' }
    end
  end

  def create
    @run = Run.new(create_run_params)
    if @run.save
      render action: :show, formats: :json
    else
      render json: { errors: @run.errors.full_messages.to_sentence }, status: :bad_request
    end
  end

  def update
    @run = Run.find_by(slug: params[:slug])

    render_not_found and return unless @run

    if @run.update(update_run_params)
      render action: :show, formats: :json
    else
      render json: { errors: @run.errors.full_messages.to_sentence }, status: :bad_request
    end
  end

  private

  def create_run_params
    params.permit(
      :capacity,
      :start_year,
      :end_year,
      resolution: {},
      geographic_scope: [],
      interconnector_nodes: [],
    )
  end

  def update_run_params
    params.permit(
      :email,
      :log_file,
      :capacities_with_interconnector,
      :capacities_without_interconnector,
      :generation_with_interconnector,
      :generation_without_interconnector,
      :metrics_with_interconnector,
      :metrics_without_interconnector,
      :trade_flows_with_interconnector,
      :trade_flows_without_interconnector,
    )
  end

  def render_not_found
    render json: { error: 'No run with that slug found.' }, status: :not_found
  end
end
