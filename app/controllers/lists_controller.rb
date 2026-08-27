class ListsController < ApplicationController
  def index
    @lists = List.all
    @list = List.new
  end

  def show
    @list = List.find(params[:id])
    @categories = Category.all
    @selected_category_id = params[:category_id]
    @to_watch, @watched = @list.bookmarks_by_watched(category_id: @selected_category_id)
  end

  def create
    @list = List.new(list_params)
    if @list.save
      redirect_to lists_path
    else
      @lists = List.all
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @list = List.find(params[:id])
    if @list.update(list_params)
      redirect_to list_path(@list)
    else
      @categories = Category.all
      @selected_category_id = params[:category_id]
      @to_watch, @watched = @list.bookmarks_by_watched(category_id: @selected_category_id)
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @list = List.find(params[:id])
    @list.destroy
    redirect_to lists_path
  end

  private

  def list_params
    params.require(:list).permit(:name)
  end
end
