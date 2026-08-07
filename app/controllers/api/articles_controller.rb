module Api
  class ArticlesController < BaseController
    before_action :set_article, only: [ :show, :update, :destroy ]

    def index
      articles = Article.search_by_keyword(params[:query])
                        .includes(:comments)
                        .with_attached_cover_image
                        .with_rich_text_rich_content_and_embeds
                        .order(created_at: :desc)
      page, per_page = pagination_values
      total_count = articles.count
      records = articles.offset((page - 1) * per_page).limit(per_page)

      render json: {
        articles: records.map { |article| article_json(article) },
        pagination: pagination_meta(total_count, page, per_page)
      }
    end

    def show
      render json: { article: article_json(@article) }
    end

    def create
      article = Article.new(article_params)

      if article.save
        render json: { article: article_json(article) }, status: :created
      else
        render_validation_errors(article)
      end
    end

    def update
      if @article.update(article_params)
        render json: { article: article_json(@article) }
      else
        render_validation_errors(@article)
      end
    end

    def destroy
      @article.destroy!
      head :no_content
    end

    private

    def set_article
      @article = Article.with_attached_cover_image
                        .with_rich_text_rich_content_and_embeds
                        .find(params[:id])
    end

    def article_params
      params.require(:article).permit(:title, :rich_content, :cover_image)
    end

    def article_json(article)
      {
        id: article.id,
        title: article.title,
        content: article.rich_content&.body&.to_html.to_s,
        cover_image_url: article.cover_image.attached? ? rails_blob_url(article.cover_image) : nil,
        comments_count: article.comments.size,
        created_at: article.created_at,
        updated_at: article.updated_at
      }
    end

    def render_validation_errors(article)
      render json: { errors: article.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
