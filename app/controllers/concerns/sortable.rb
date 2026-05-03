module Sortable
  extend ActiveSupport::Concern

  # virtual_columns: hash of column_name => lambda(record) returning a sort key.
  # When matched, the scope is materialised and sorted in Ruby instead of SQL.
  def apply_sort(scope, allowed_columns:, default_column:, default_direction: "asc", virtual_columns: {})
    all_columns = allowed_columns.map(&:to_s) + virtual_columns.keys.map(&:to_s)
    column      = params[:sort].presence_in(all_columns) || default_column.to_s
    direction   = params[:direction].presence_in(%w[asc desc]) || default_direction.to_s
    @sort_column    = column
    @sort_direction = direction

    if (key_fn = virtual_columns[column] || virtual_columns[column.to_sym])
      sorted = scope.to_a.sort_by(&key_fn)
      direction == "desc" ? sorted.reverse : sorted
    else
      scope.reorder(column => direction)
    end
  end
end
