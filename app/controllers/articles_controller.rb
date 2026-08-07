class ArticlesController < ApplicationController
  before_action :set_article, only: [ :show, :edit, :update, :destroy ]

  def index
    articles = Article.search_by_keyword(params[:query])
    @per_page = Rails.configuration.x.blog.dig(
      :pagination,
      :web_per_page
    ).to_i

    @per_page = 5 unless @per_page.positive?
    @total_count = articles.count
    @total_pages = [ (@total_count.to_f / @per_page).ceil, 1 ].max
    @page = params[:page].to_i
    @page = 1 if @page < 1
    @page = @total_pages if @page > @total_pages

    @articles = articles.with_attached_cover_image
                        .with_rich_text_rich_content_and_embeds
                        .order(created_at: :desc)
                        .offset((@page - 1) * @per_page)
                        .limit(@per_page)
  end

  def show
    comments = @article.comments.order(created_at: :desc)
    @comments_per_page = Rails.configuration.x.blog.dig(
      :pagination,
      :comments_per_page
    ).to_i
    @comments_per_page = 5 unless @comments_per_page.positive?

    @comments_total_count = comments.count
    @comments_total_pages = [
      (@comments_total_count.to_f / @comments_per_page).ceil,
      1
    ].max

    @comments_page = params[:comments_page].to_i
    @comments_page = 1 if @comments_page < 1
    @comments_page = @comments_total_pages if @comments_page > @comments_total_pages

    @comments = comments.offset(
      (@comments_page - 1) * @comments_per_page
    ).limit(@comments_per_page)
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to @article, notice: "文章发布成功！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: "文章更新成功！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_path, notice: "文章已成功删除！"
  end

  private

  def set_article
    @article = Article.find_by(id: params[:id])
    return if @article

    redirect_to articles_path, alert: "文章不存在或已被删除。"
  end

  def article_params
    params.require(:article).permit(:title, :cover_image, :rich_content)
  end
end
