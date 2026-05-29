class CategoriesController < ApplicationController
  before_action :set_category, only: [ :show, :update, :destroy ]

  def index
    categories = Category.order(:name)
    render json: categories.map { |c| category_json(c) }
  end

  def show
    render json: category_json(@category, include_count: true)
  end

  def create
    category = Category.new(category_params)
    if category.save
      render json: category_json(category), status: :created
    else
      render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: category_json(@category)
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.equipment.any?
      count = @category.equipment.count
      render json: { error: "Cannot delete category. #{count} equipment items still belong to it." }, status: :conflict
    else
      @category.destroy
      head :no_content
    end
  end

  private

  def set_category
    @category = Category.find_by(id: params[:id])
    render json: { error: "Category not found" }, status: :not_found if @category.nil?
  end

  def category_params
    params.require(:category).permit(:name)
  end

  def category_json(category, include_count: false)
    json = { id: category.id, name: category.name }
    json[:equipment_count] = category.equipment.count if include_count
    json
  end
end
