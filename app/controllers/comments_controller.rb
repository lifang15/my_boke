class CommentsController < ApplicationController
  before_action :set_article

  # 提交新评论
  def create
    @comment = @article.comments.build(comment_params)
    if @comment.save
      redirect_to article_path(@article), notice: '评论发表成功！'
    else
      redirect_to article_path(@article), alert: '评论发表失败，请填写昵称和内容！'
    end
  end

   # 删除评论
  def destroy
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article), notice: '评论已删除！'
  end
  private

  # 寻找当前评论相应的文章
  def set_article
    @article = Article.find(params[:article_id])
  end
  
  def comment_params
    params.require(:comment).permit(:commenter, :body)
  end
end