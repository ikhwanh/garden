module Paginatable
  extend ActiveSupport::Concern

  PER_PAGE = 25

  def paginate(scope)
    @current_page = [ params[:page].to_i, 1 ].max
    if scope.is_a?(Array)
      @total_count = scope.size
      @total_pages = [ (@total_count.to_f / PER_PAGE).ceil, 1 ].max
      @current_page = [ @current_page, @total_pages ].min
      scope.slice((@current_page - 1) * PER_PAGE, PER_PAGE) || []
    else
      @total_count  = scope.count
      @total_pages  = [ (@total_count.to_f / PER_PAGE).ceil, 1 ].max
      @current_page = [ @current_page, @total_pages ].min
      scope.limit(PER_PAGE).offset((@current_page - 1) * PER_PAGE)
    end
  end
end
