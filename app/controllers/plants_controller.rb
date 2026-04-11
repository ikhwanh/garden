class PlantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plant, only: [ :show, :edit, :update, :destroy, :quick_fertilize ]

  def index
    @plants = current_user.plants.includes(:seed).order(:name)
    @plant = current_user.plants.new
    @seeds = current_user.seeds.order(:name)
  end

  def show; end

  def new
    @plant = current_user.plants.new
    @seeds = current_user.seeds.order(:name)
  end

  def create
    @plant = current_user.plants.new(plant_params)
    if @plant.save
      @plant.seed.update_column(:transplanted_at, @plant.planted_on)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to plant_path(@plant) }
      end
    else
      @seeds = current_user.seeds.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def quick_fertilize
    days = params[:days].to_i
    fertilizer_type = params[:fertilizer_type]
    last_fert = @plant.fertilizations.order(applied_on: :desc).first
    base_date = last_fert ? last_fert.applied_on : Date.today
    @fertilization = @plant.fertilizations.build(
      fertilizer_type: fertilizer_type,
      applied_on: base_date + days.days
    )
    if @fertilization.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to plant_path(@plant) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash") }
        format.html { redirect_to plant_path(@plant) }
      end
    end
  end

  def edit
    @seeds = current_user.seeds.order(:name)
  end

  def update
    if @plant.update(plant_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to plant_path(@plant) }
      end
    else
      @seeds = current_user.seeds.order(:name)
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
    @plant = current_user.plants.includes(:seed, :fertilizations, :harvests).find(params[:id])
  end

  def plant_params
    params.require(:plant).permit(:name, :seed_id, :grow_medium, :planted_on, :container_size, :location)
  end
end
