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