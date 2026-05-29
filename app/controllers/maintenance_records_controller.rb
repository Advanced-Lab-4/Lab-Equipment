class MaintenanceRecordsController < ApplicationController
  before_action :set_maintenance_record, only: [:show, :update, :destroy]

  def index
    records = MaintenanceRecord.includes(:equipment).order(performed_at: :desc)
    records = records.where(equipment_id: params[:equipment_id]) if params[:equipment_id].present?
    render json: records.map { |r| maintenance_json(r) }
  end

  def show
    render json: maintenance_json(@maintenance_record)
  end

  def create
    record = MaintenanceRecord.new(maintenance_record_params)
    if record.save
      render json: maintenance_json(record), status: :created
    else
      render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @maintenance_record.update(maintenance_record_params)
      render json: maintenance_json(@maintenance_record)
    else
      render json: { errors: @maintenance_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @maintenance_record.destroy
    head :no_content
  end

  private

  def set_maintenance_record
    @maintenance_record = MaintenanceRecord.includes(:equipment).find_by(id: params[:id])
    return render json: { error: "Maintenance record not found" }, status: :not_found if @maintenance_record.nil?
  end

  def maintenance_record_params
    params.require(:maintenance_record).permit(:description, :performed_at, :equipment_id)
  end

  def maintenance_json(record)
    {
      id: record.id,
      description: record.description,
      performed_at: record.performed_at,
      equipment_id: record.equipment_id,
      equipment_name: record.equipment&.name
    }
  end
end