class ListsController < ApplicationController
  def index
    @lists = Current.user.lists
    @list = List.new
  end

  def show
    @list = Current.user.lists.find(params[:id])
    @categories = Category.all
    @selected_category_id = params[:category_id]
    @to_watch, @watched = @list.bookmarks_by_watched(category_id: @selected_category_id)
  end

  def create
    @list = Current.user.lists.new(list_params)
    if @list.save
      redirect_to lists_path
    else
      @lists = Current.user.lists
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @list = Current.user.lists.find(params[:id])
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
    @list = Current.user.lists.find(params[:id])
    @list.destroy
    redirect_to lists_path
  end

  private

  def list_params
    params.require(:list).permit(:name, :kids_mode)
  end
end
