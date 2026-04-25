class CropsController < ApplicationController
  include Paginatable

  before_action :authenticate_user!
  before_action :set_crop, only: [ :show, :edit, :update, :destroy ]

  def index
    @show_harvested = params[:show_harvested] == "1"
    scope = current_user.crops.includes(:nursery).order(:name)
    scope = scope.where(harvested_on: nil) unless @show_harvested
    @crops = paginate(scope)
    @crop = current_user.crops.new
    @nurseries = current_user.nurseries.order(:name)
    @presets = Preset.order(:name, :grow_type)
  end

  def show; end

  def new
    @crop = current_user.crops.new
    @nurseries = current_user.nurseries.order(:name)
    @presets = Preset.order(:name, :grow_type)
  end

  def create
    @crop = current_user.crops.new(crop_params)
    if @crop.save
      @crop.nursery&.update_column(:transplanted_on, @crop.planted_on)
      ReminderGenerator.call(@crop, @crop.preset) if @crop.preset
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to crop_path(@crop) }
      end
    else
      @nurseries = current_user.nurseries.order(:name)
      @presets = Preset.order(:name, :grow_type)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @nurseries = current_user.nurseries.order(:name)
    @presets = Preset.order(:name, :grow_type)
  end

  def update
    if @crop.update(crop_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to crop_path(@crop) }
      end
    else
      @nurseries = current_user.nurseries.order(:name)
      @presets = Preset.order(:name, :grow_type)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @crop.destroy
    @crop = current_user.crops.new
    @nurseries = current_user.nurseries.order(:name)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to crops_path }
    end
  end

  private

  def set_crop
    @crop = current_user.crops.includes(:nursery, :preset).find(params[:id])
  end

  def crop_params
    params.require(:crop).permit(:name, :nursery_id, :preset_id, :planted_on, :harvested_on, :quantity_initial, :quantity_final, :note)
  end
end
