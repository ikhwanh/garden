class PlantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plant, only: [ :show, :edit, :update, :destroy ]

  def index
    @plants = current_user.plants.includes(:seed).order(:name)
    @plant = current_user.plants.new
    @seeds = current_user.seeds.order(:name)
    @presets = Preset.order(:name, :grow_type)
  end

  def show; end

  def new
    @plant = current_user.plants.new
    @seeds = current_user.seeds.order(:name)
    @presets = Preset.order(:name, :grow_type)
  end

  def create
    @plant = current_user.plants.new(plant_params)
    if @plant.save
      @plant.seed&.update_column(:transplanted_on, @plant.planted_on)
      ReminderGenerator.call(@plant, @plant.preset) if @plant.preset
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to plant_path(@plant) }
      end
    else
      @seeds = current_user.seeds.order(:name)
      @presets = Preset.order(:name, :grow_type)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @seeds = current_user.seeds.order(:name)
    @presets = Preset.order(:name, :grow_type)
  end

  def update
    if @plant.update(plant_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to plant_path(@plant) }
      end
    else
      @seeds = current_user.seeds.order(:name)
      @presets = Preset.order(:name, :grow_type)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @plant.destroy
    @plant = current_user.plants.new
    @seeds = current_user.seeds.order(:name)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to plants_path }
    end
  end

  private

  def set_plant
    @plant = current_user.plants.includes(:seed, :preset).find(params[:id])
  end

  def plant_params
    params.require(:plant).permit(:name, :seed_id, :preset_id, :grow_medium, :planted_on, :days_to_maturity, :container_size, :location, :quantity_initial, :quantity_final, :note)
  end
end
