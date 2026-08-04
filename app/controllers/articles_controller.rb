class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def index
  @articles = Article.search_by_keyword(params[:query]).order(created_at: :desc)
  end

  def show
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to @article, notice: '文章发布成功！'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: '文章更新成功！'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_path, notice: '文章已删除！'
  end

  private

 
  def set_article
    @article = Article.find(params[:id])
  end 

  def article_params
    params.require(:article).permit(:title, :content)
  end
end