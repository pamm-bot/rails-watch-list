require 'rails_helper'

RSpec.describe TmdbClient do
  describe ".genre_name" do
    it "returns the name for a known genre id" do
      expect(TmdbClient.genre_name(27)).to eq("Horror")
    end

    it "returns nil for an unknown genre id" do
      expect(TmdbClient.genre_name(999_999)).to be_nil
    end
  end

  describe ".mature_genre_name?" do
    it "is true for a mature genre name" do
      expect(TmdbClient.mature_genre_name?("Horror")).to eq(true)
    end

    it "is false for a non-mature genre name" do
      expect(TmdbClient.mature_genre_name?("Comedy")).to eq(false)
    end
  end

  describe ".poster_url" do
    it "builds a full image url from a poster path" do
      expect(TmdbClient.poster_url("/abc.jpg")).to eq("https://image.tmdb.org/t/p/w500/abc.jpg")
    end

    it "returns nil when there is no poster path" do
      expect(TmdbClient.poster_url(nil)).to be_nil
    end
  end

  describe ".explicit_title?" do
    it "flags a title containing an explicit keyword" do
      expect(TmdbClient.explicit_title?("Some XXX Movie")).to eq(true)
    end

    it "does not flag an ordinary title" do
      expect(TmdbClient.explicit_title?("Titanic")).to eq(false)
    end

    it "does not flag a blank title" do
      expect(TmdbClient.explicit_title?(nil)).to eq(false)
    end
  end

  describe ".low_rated?" do
    it "is true for a positive rating below the threshold" do
      expect(TmdbClient.low_rated?(2.5)).to eq(true)
    end

    it "is false for a rating at or above the threshold" do
      expect(TmdbClient.low_rated?(7.0)).to eq(false)
    end

    it "is false for a zero rating (not yet rated)" do
      expect(TmdbClient.low_rated?(0)).to eq(false)
    end
  end

  describe ".mature?" do
    it "is true when TMDb flags the result as adult" do
      expect(TmdbClient.mature?([], adult: true)).to eq(true)
    end

    it "is true for a mature genre id" do
      expect(TmdbClient.mature?([ 27 ], adult: false)).to eq(true)
    end

    it "is true for an explicit title" do
      expect(TmdbClient.mature?([], adult: false, title: "XXX Movie")).to eq(true)
    end

    it "is true for a low vote average" do
      expect(TmdbClient.mature?([], adult: false, vote_average: 1.0)).to eq(true)
    end

    it "is false when none of the signals are present" do
      expect(TmdbClient.mature?([ 35 ], adult: false, title: "Comedy Movie", vote_average: 7.5)).to eq(false)
    end
  end

  describe ".search" do
    it "returns an empty array for a blank query" do
      expect(TmdbClient.search("")).to eq([])
    end

    it "parses the results from the search endpoint" do
      response = { "results" => [ { "title" => "Titanic" } ] }.to_json
      allow(Net::HTTP).to receive(:get).and_return(response)

      expect(TmdbClient.search("Titanic")).to eq([ { "title" => "Titanic" } ])
    end
  end

  describe ".discover" do
    it "parses the results from the discover endpoint" do
      response = { "results" => [ { "title" => "Popular Movie" } ] }.to_json
      allow(Net::HTTP).to receive(:get).and_return(response)

      expect(TmdbClient.discover).to eq([ { "title" => "Popular Movie" } ])
    end

    it "forwards the page parameter" do
      allow(Net::HTTP).to receive(:get).and_return({ "results" => [] }.to_json)

      TmdbClient.discover(page: 4)

      expect(Net::HTTP).to have_received(:get) do |uri|
        expect(uri.query).to include("page=4")
      end
    end
  end
end
