class CommentsController < ApplicationController
  before_action :set_article

  def create
    @comment = @article.comments.build(comment_params)

    if @comment.save
      redirect_to article_path(@article, comments_page: 1, anchor: "comments"), notice: "评论发表成功！"
    else
      redirect_to article_path(@article, anchor: "comments"), alert: "评论发表失败，请填写昵称和内容！"
    end
  end

  def destroy
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article, comments_page: 1, anchor: "comments"), notice: "评论已删除！"
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:comment).permit(:commenter, :body)
  end
end
