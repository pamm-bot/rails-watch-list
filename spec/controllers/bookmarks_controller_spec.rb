require 'rails_helper'
begin
  require "bookmarks_controller"
rescue LoadError
end

if defined?(BookmarksController)
  RSpec.describe BookmarksController, type: :controller do
    before(:each) do
      @user = User.create!(email_address: "bookmarks_controller_spec@example.com", password: "password123")
      sign_in_as(@user)
      @movie = Movie.create!(title: "Titanic", overview: "101-year-old Rose DeWitt Bukater tells the story of her life aboard the Titanic, 84 years later.")
      @list = List.create!(name: "Drama", user: @user)
    end

    let(:valid_attributes) do
      { list_id: @list.id, bookmark: { movie_id: @movie.id, comment: "Great movie!" } }
    end

    let(:invalid_attributes) do
      { list_id: @list.id, bookmark: { movie_id: @movie.id, comment: "Good!" } }
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new bookmark" do
          expect {
            post :create, params: valid_attributes
          }.to change(Bookmark, :count).by(1)
        end

        it "assigns a newly created bookmark as @bookmark" do
          post :create, params: valid_attributes
          expect(assigns(:bookmark)).to be_a(Bookmark)
          expect(assigns(:bookmark)).to be_persisted
        end

        it "redirects to the created list" do
          post :create, params: valid_attributes
          expect(response).to redirect_to(@list)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark as @bookmark" do
          post :create, params: invalid_attributes
          expect(assigns(:bookmark)).to be_a_new(Bookmark)
        end

        it "re-renders the 'new' template or 'lists/show'" do
          post :create, params: invalid_attributes
          expect(response).to render_template('new').or render_template('lists/show')
        end
      end
    end

    describe "DELETE destroy" do
      it "deletes a bookmark" do
        @bookmark = Bookmark.create!(valid_attributes[:bookmark].merge(list_id: @list.id))
        expect {
          delete :destroy, params: { id: @bookmark.id }
        }.to change(Bookmark, :count).by(-1)
      end

      it "does not delete another user's bookmark" do
        other_user = User.create!(email_address: "other_bookmarks_controller_spec@example.com", password: "password123")
        other_list = List.create!(name: "Comedy", user: other_user)
        other_bookmark = Bookmark.create!(list: other_list, movie: @movie)

        expect {
          delete :destroy, params: { id: other_bookmark.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "PATCH update" do
      it "toggles a bookmark between watched and to-watch" do
        @bookmark = Bookmark.create!(valid_attributes[:bookmark].merge(list_id: @list.id))

        patch :update, params: { id: @bookmark.id, bookmark: { watched: true } }, format: :turbo_stream

        expect(@bookmark.reload.watched).to eq(true)
      end
    end
  end
else
  describe "BookmarksController" do
    it "should exist" do
      expect(defined?(Bookmarks)).to eq(true)
    end
  end
end
