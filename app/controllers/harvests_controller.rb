class HarvestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_harvest, only: [ :show, :edit, :update, :destroy ]

  def index
    @harvests = Harvest.joins(:plant)
                       .where(plants: { user_id: current_user.id })
                       .includes(:plant)
                       .order(harvested_on: :desc)
  end

  def show; end

  def new
    @plant = current_user.plants.find(params[:plant_id])
    @harvest = @plant.harvests.new
  end

  def create
    @plant = current_user.plants.find(params[:plant_id])
    @harvest = @plant.harvests.build(harvest_params)
    if @harvest.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to plant_path(@plant) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @harvest.update(harvest_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to harvest_path(@harvest) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @plant = @harvest.plant
    @harvest.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to plant_path(@plant) }
    end
  end

  private

  def set_harvest
    @harvest = Harvest.joins(:plant)
                      .where(plants: { user_id: current_user.id })
                      .find(params[:id])
  end

  def harvest_params
    params.require(:harvest).permit(:harvested_on, :weight_grams, :quantity, :unit)
  end
end
