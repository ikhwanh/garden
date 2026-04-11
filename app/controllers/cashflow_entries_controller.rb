class CashflowEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entry, only: [ :edit, :update, :destroy ]

  def new
    @entry = current_user.cashflow_entries.new
  end

  def create
    @entry = current_user.cashflow_entries.new(entry_params)
    if @entry.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to cashflow_path }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @entry.update(entry_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to cashflow_path }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy
    @entry = current_user.cashflow_entries.new
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cashflow_path }
    end
  end

  private

  def set_entry
    @entry = current_user.cashflow_entries.find(params[:id])
  end

  def entry_params
    params.require(:cashflow_entry).permit(:entry_type, :amount, :description, :occurred_on)
  end
end
