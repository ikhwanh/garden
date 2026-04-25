class PresetsController < ApplicationController
  include Paginatable
  include Sortable

  before_action :authenticate_user!
  before_action :set_preset, only: [ :show, :edit, :update, :destroy ]

  def index
    scope = apply_sort(Preset.all, allowed_columns: %w[name local_name grow_type days_to_harvest_min], default_column: :name)
    @presets = paginate(scope)
    @preset = Preset.new
  end

  def show; end

  def new
    @preset = Preset.new
  end

  def create
    @preset = Preset.new(preset_params)
    if @preset.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to preset_path(@preset) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @preset.update(preset_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to preset_path(@preset) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @preset.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to presets_path }
    end
  end

  private

  def set_preset
    @preset = Preset.find(params[:id])
  end

  def preset_params
    params.require(:preset).permit(:slug, :name, :local_name, :grow_type, :days_to_harvest_min, :days_to_harvest_max)
  end
end
