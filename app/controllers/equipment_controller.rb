class EquipmentController < ApplicationController
  before_action :set_equipment, only: [ :show, :update, :destroy ]

  def index
    equipment = Equipment.includes(:category).order(:name)
    equipment = equipment.where(status: params[:status]) if params[:status].present?
    render json: equipment.map { |e| equipment_json(e) }
  end

  def show
    render json: equipment_json(@equipment, include_details: true)
  end

  def create
    equipment = Equipment.new(equipment_params)
    if equipment.save
      render json: equipment_json(equipment), status: :created
    else
      render json: { errors: equipment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @equipment.update(equipment_params)
      render json: equipment_json(@equipment)
    else
      render json: { errors: @equipment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @equipment.destroy
    head :no_content
  end

  private

  def set_equipment
    @equipment = Equipment.includes(:category, :maintenance_records).find_by(id: params[:id])
    render json: { error: "Equipment not found" }, status: :not_found if @equipment.nil?
  end

  def equipment_params
    params.require(:equipment).permit(:name, :serial_number, :status, :category_id)
  end

  def equipment_json(e, include_details: false)
    json = {
      id: e.id,
      name: e.name,
      serial_number: e.serial_number,
      status: e.status,
      category_id: e.category_id,
      category_name: e.category&.name
    }
    if include_details
      json[:category] = { id: e.category.id, name: e.category.name }
      json[:maintenance_records] = e.maintenance_records.order(performed_at: :desc).map do |m|
        { id: m.id, description: m.description, performed_at: m.performed_at }
      end
    end
    json
  end
end
