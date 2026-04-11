class SeedsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_seed, only: [ :show, :edit, :update, :destroy ]

  def index
    @seeds = current_user.seeds.order(:name)
    @seed = current_user.seeds.new
  end

  def show; end

  def new
    @seed = current_user.seeds.new
  end

  def create
    @seed = current_user.seeds.new(seed_params)
    if @seed.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to seed_path(@seed) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @seed.update(seed_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to seed_path(@seed) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @seed.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to seeds_path }
    end
  end

  private

  def set_seed
    @seed = current_user.seeds.find(params[:id])
  end

  def seed_params
    params.require(:seed).permit(:name, :germination_days)
  end
end
