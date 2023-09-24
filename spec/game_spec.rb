require './spec/spec_helper'

RSpec.describe Game do
  let(:game_data) { CSV.readlines('./data/test_games.csv', headers: true, header_converters: :symbol) }
  let(:game) { Game.new(game_data.first) }

  describe '#initialize' do
    it 'exists' do
      expect(game).to be_a(Game)
      expect(game.game_id).to eq("2012030221")
      expect(game.season).to eq("20122013")
      expect(game.type).to eq('Postseason')
      expect(game.date_time).to eq('5/16/13')
      expect(game.away_team_id).to eq("3")
      expect(game.home_team_id).to eq("6")
      expect(game.away_goals).to eq(2)
      expect(game.home_goals).to eq(3)
      expect(game.venue).to eq('Toyota Stadium')
      expect(game.venue_link).to eq('/api/v1/venues/null')
    end
  end
end