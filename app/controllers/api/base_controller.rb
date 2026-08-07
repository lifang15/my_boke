module Api
  class BaseController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    private

    def pagination_values
      default_per_page = Rails.configuration.x.blog.dig(
        :pagination,
        :api_per_page
      ).to_i
      max_per_page = Rails.configuration.x.blog.dig(
        :pagination,
        :api_max_per_page
      ).to_i

      default_per_page = 5 unless default_per_page.positive?
      max_per_page = 50 unless max_per_page.positive?

      page = params[:page].to_i
      page = 1 unless page.positive?

      per_page = params[:per_page].to_i
      per_page = default_per_page unless per_page.positive?
      per_page = [ per_page, max_per_page ].min

      [ page, per_page ]
    end

    def pagination_meta(total_count, page, per_page)
      {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / per_page).ceil
      }
    end

    def render_not_found
      render json: { error: "资源不存在" }, status: :not_found
    end
  end
end
