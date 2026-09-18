require 'rails_helper'
begin
  require "lists_controller"
rescue LoadError
end

if defined?(ListsController)
  RSpec.describe ListsController, type: :controller do
    let(:user) do
      User.create!(email_address: "lists_controller_spec@example.com", password: "password123")
    end

    let(:valid_attributes) do
      {
        name: "Comedy"
      }
    end

    let(:invalid_attributes) do
      { name: "" }
    end

    before(:each) { sign_in_as(user) }

    describe "GET index" do
      it "assigns all lists as @lists" do
        list = List.create! valid_attributes.merge(user: user)
        get :index, params: {}
        expect(assigns(:lists)).to eq([ list ])
      end
    end

    describe "GET show" do
      def tmdb_result(id:, title:, genre_ids: [ 18 ], vote_average: 7.5, adult: false)
        {
          "id" => id, "title" => title, "poster_path" => "/#{id}.jpg",
          "overview" => "About #{title}.", "genre_ids" => genre_ids,
          "vote_average" => vote_average, "adult" => adult
        }
      end

      it "assigns the requested list as @list" do
        list = List.create! valid_attributes.merge(user: user)
        get :show, params: { id: list.to_param }
        expect(assigns(:list)).to eq(list)
      end

      it "assigns the first usable discovery candidate as @movie" do
        list = List.create! valid_attributes.merge(user: user)
        allow(TmdbClient).to receive(:discover).and_return([ tmdb_result(id: 1, title: "Heat") ])

        get :show, params: { id: list.to_param }

        expect(assigns(:movie)["title"]).to eq("Heat")
      end

      it "skips a discovery candidate already in the list" do
        list = List.create! valid_attributes.merge(user: user)
        movie = Movie.create!(title: "Heat", overview: "Crime saga.")
        Bookmark.create!(list: list, movie: movie)
        allow(TmdbClient).to receive(:discover).and_return([
          tmdb_result(id: 1, title: "Heat"), tmdb_result(id: 2, title: "Collateral")
        ])

        get :show, params: { id: list.to_param }

        expect(assigns(:movie)["title"]).to eq("Collateral")
      end

      it "excludes a discovery candidate already recorded as seen" do
        list = List.create! valid_attributes.merge(user: user)
        allow(Rails.cache).to receive(:read).and_return([ "1" ])
        allow(TmdbClient).to receive(:discover).and_return([
          tmdb_result(id: 1, title: "Heat"), tmdb_result(id: 2, title: "Collateral")
        ])

        get :show, params: { id: list.to_param }

        expect(assigns(:movie)["id"]).to eq(2)
      end

      it "skips a discovery candidate whose title is in a non-Latin script" do
        list = List.create! valid_attributes.merge(user: user)
        allow(TmdbClient).to receive(:discover).and_return([
          tmdb_result(id: 1, title: "霸王别姬"), tmdb_result(id: 2, title: "Farewell My Concubine")
        ])

        get :show, params: { id: list.to_param }

        expect(assigns(:movie)["title"]).to eq("Farewell My Concubine")
      end

      it "filters mature discovery candidates for a kids-mode list" do
        list = List.create! valid_attributes.merge(user: user, kids_mode: true)
        allow(TmdbClient).to receive(:discover).and_return([
          tmdb_result(id: 1, title: "Saw", genre_ids: [ 27 ]),
          tmdb_result(id: 2, title: "Paddington", genre_ids: [ 10751 ])
        ])

        get :show, params: { id: list.to_param }

        expect(assigns(:movie)["title"]).to eq("Paddington")
      end

      it "biases the discovery deck toward the genre the list already leans on" do
        list = List.create! valid_attributes.merge(user: user)
        drama = Category.find_or_create_by!(name: "Drama")
        Bookmark.create!(list: list, movie: Movie.create!(title: "Nomadland", overview: "Road.", category: drama))
        allow(TmdbClient).to receive(:discover).and_return([ tmdb_result(id: 9, title: "Marriage Story") ])

        get :show, params: { id: list.to_param }

        expect(TmdbClient).to have_received(:discover).with(hash_including(genre_id: "18")).at_least(:once)
      end

      it "assigns no @movie when nothing survives filtering" do
        list = List.create! valid_attributes.merge(user: user)
        allow(TmdbClient).to receive(:discover).and_return([])

        get :show, params: { id: list.to_param }

        expect(assigns(:movie)).to be_nil
      end

      it "404s for another user's list" do
        other = List.create!(name: "Private", user: User.create!(email_address: "other_lists_spec@example.com", password: "password123"))

        expect {
          get :show, params: { id: other.to_param }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new List" do
          expect {
            post :create, params: { list: valid_attributes }
          }.to change(List, :count).by(1)
        end

        it "assigns a newly created list as @list" do
          post :create, params: { list: valid_attributes }
          expect(assigns(:list)).to be_a(List)
          expect(assigns(:list)).to be_persisted
        end

        it "redirects to the new list" do
          post :create, params: { list: valid_attributes }
          expect(response).to redirect_to(list_path(assigns(:list)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved list as @list" do
          post :create, params: { list: invalid_attributes }
          expect(assigns(:list)).to be_a_new(List)
        end

        it "re-renders the 'index' template" do
          post :create, params: { list: invalid_attributes }
          expect(response).to render_template("index")
        end
      end
    end

    describe "PATCH update" do
      it "updates the list's color and emoji" do
        list = List.create!(valid_attributes.merge(user: user))
        patch :update, params: { id: list.to_param, list: { color: List::ACCENT_COLORS.first, emoji: "🎬" } }

        list.reload
        expect(list.color).to eq(List::ACCENT_COLORS.first)
        expect(list.emoji).to eq("🎬")
      end

      it "redirects back to where the request came from" do
        list = List.create!(valid_attributes.merge(user: user))
        request.env["HTTP_REFERER"] = lists_path
        patch :update, params: { id: list.to_param, list: { name: "New name" } }

        expect(response).to redirect_to(lists_path)
      end

      it "falls back to the list's page when there's no referer" do
        list = List.create!(valid_attributes.merge(user: user))
        patch :update, params: { id: list.to_param, list: { name: "New name" } }

        expect(response).to redirect_to(list_path(list))
      end
    end
  end

  RSpec.describe ListsController, type: :controller do
    describe "GET index when signed out" do
      it "renders the guest welcome screen instead of redirecting to login" do
        get :index

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:home)
        expect(assigns(:lists)).to be_nil
      end
    end
  end

else
  describe "ListsController" do
    it "should exist" do
      expect(defined?(ListsController)).to eq(true)
    end
  end
end
