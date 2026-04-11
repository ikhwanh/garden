class FertilizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_fertilization, only: [ :show, :edit, :update, :destroy ]

  def index
    @fertilizations = Fertilization.joins(:plant)
                                    .where(plants: { user_id: current_user.id })
                                    .includes(:plant)
                                    .order(applied_on: :desc)
  end

  def show; end

  def new
    @plant = current_user.plants.find(params[:plant_id])
    @fertilization = @plant.fertilizations.new
  end

  def create
    @plant = current_user.plants.find(params[:plant_id])
    @fertilization = @plant.fertilizations.build(fertilization_params)
    if @fertilization.save
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
    if @fertilization.update(fertilization_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to fertilization_path(@fertilization) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @plant = @fertilization.plant
    @fertilization.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to plant_path(@plant) }
    end
  end

  private

  def set_fertilization
    @fertilization = Fertilization.joins(:plant)
                                   .where(plants: { user_id: current_user.id })
                                   .find(params[:id])
  end

  def fertilization_params
    params.require(:fertilization).permit(:fertilizer_type, :applied_on, :amount, :unit)
  end
end
