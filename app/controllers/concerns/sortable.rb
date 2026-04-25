module Sortable
  extend ActiveSupport::Concern

  def apply_sort(scope, allowed_columns:, default_column:, default_direction: "asc")
    column    = params[:sort].presence_in(allowed_columns.map(&:to_s)) || default_column.to_s
    direction = params[:direction].presence_in(%w[asc desc]) || default_direction.to_s
    @sort_column    = column
    @sort_direction = direction
    scope.reorder(column => direction)
  end
end
