class ArticlesController < ApplicationController
  before_action :set_article, only: [ :show, :edit, :update, :destroy ]

  def index
    articles = Article.search_by_keyword(params[:query])
    @per_page = 5
    @total_pages = [ (articles.count.to_f / @per_page).ceil, 1 ].max
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
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :cover_image, :rich_content)
  end
end
