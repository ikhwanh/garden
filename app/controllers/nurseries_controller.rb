class NurseriesController < ApplicationController
  include Paginatable
  include Sortable

  before_action :authenticate_user!
  before_action :set_nursery, only: [ :show, :edit, :update, :destroy ]
  before_action :set_nursery_presets, only: [ :index, :new, :create, :edit, :update ]

  def index
    scope = apply_sort(current_user.nurseries, allowed_columns: %w[name started_on transplanted_on quantity_initial], default_column: :name)
    @nurseries = paginate(scope)
    @nursery = current_user.nurseries.new
  end

  def show; end

  def new
    @nursery = current_user.nurseries.new
  end

  def create
    @nursery = current_user.nurseries.new(nursery_params)
    if @nursery.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to nursery_path(@nursery) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @nursery.update(nursery_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to nursery_path(@nursery) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @nursery.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to nurseries_path }
    end
  end

  private

  def set_nursery
    @nursery = current_user.nurseries.find(params[:id])
  end

  def nursery_params
    params.require(:nursery).permit(:name, :preset_id, :started_on, :quantity_initial, :note)
  end

  def set_nursery_presets
    @nursery_presets = Preset.where(grow_type: "nursery").order(:name)
  end
end
