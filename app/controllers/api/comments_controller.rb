module Api
  class CommentsController < BaseController
    before_action :set_article
    before_action :set_comment, only: [ :show, :update, :destroy ]

    def index
      comments = @article.comments.order(created_at: :desc)
      page, per_page = pagination_values
      total_count = comments.count
      records = comments.offset((page - 1) * per_page).limit(per_page)

      render json: {
        comments: records.map { |comment| comment_json(comment) },
        pagination: pagination_meta(total_count, page, per_page)
      }
    end

    def show
      render json: { comment: comment_json(@comment) }
    end

    def create
      comment = @article.comments.build(comment_params)

      if comment.save
        render json: { comment: comment_json(comment) }, status: :created
      else
        render_validation_errors(comment)
      end
    end

    def update
      if @comment.update(comment_params)
        render json: { comment: comment_json(@comment) }
      else
        render_validation_errors(@comment)
      end
    end

    def destroy
      @comment.destroy!
      head :no_content
    end

    private

    def set_article
      @article = Article.find(params[:article_id])
    end

    def set_comment
      @comment = @article.comments.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end

    def comment_json(comment)
      {
        id: comment.id,
        article_id: comment.article_id,
        commenter: comment.commenter,
        body: comment.body,
        created_at: comment.created_at,
        updated_at: comment.updated_at
      }
    end

    def render_validation_errors(comment)
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
