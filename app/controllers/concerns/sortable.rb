module Sortable
  extend ActiveSupport::Concern

  included do
    helper_method :sort_column, :sort_direction
    after_action :update_last_sort_by
  end

  # Abstract method that should be overridden in including controllers
  def sortable_columns
    raise NotImplementedError, "controller should include method `sortable_columns`"
  end

  def order_by
    "#{sort_column} #{sort_direction} NULLS LAST"
  end

  def sort_column
    return column if sortable_columns.include?(column)
    return "name" if sortable_columns.include?("name")
    "created_at"
  end

  def sort_direction
    @sort_direction ||= %w[asc desc].include?(direction) ? direction : "asc"
  end

  def sort_by
    @sort_by ||= sort_column
  end

  def current_page(max: nil)
    return 1 if max&.zero?

    page = session[:current_page].to_i
    page = 1 if page <= 0
    page = max if max && page > max
    page
  end

  private

  def column
    @column ||= params[:column] || session[:sort_by]
  end

  def direction
    @direction ||= params[:direction] || session[:sort_direction]
  end

  def update_last_sort_by
    session[:last_sort_by] = sort_by
  end
end
