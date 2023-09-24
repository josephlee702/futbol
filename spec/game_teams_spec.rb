require 'spec_helper'

RSpec.describe GameTeam do 
  let(:game_teams_data) { CSV.readlines('./data/test_game_teams.csv', headers: true, header_converters: :symbol) } 
  let(:game_team) { GameTeam.new(game_teams_data.first) } 
  
  describe '#initialize' do 
    it 'exists' do 
      expect(game_team).to be_a(GameTeam)
      expect(game_team.game_id).to eq("2012030221")
      expect(game_team.team_id).to eq("3")
      expect(game_team.hoa).to eq("away")
      expect(game_team.result).to eq("LOSS")
      expect(game_team.settled_in).to eq("OT")
      expect(game_team.head_coach).to eq("John Tortorella")
      expect(game_team.goals).to eq(2)
      expect(game_team.shots).to eq(8)
      expect(game_team.tackles).to eq(44)
      expect(game_team.pim).to eq(8)
      expect(game_team.power_play_opportunities).to eq(3)
      expect(game_team.power_play_goals).to eq(0)
      expect(game_team.faceoff_win_percentage).to eq(44.8)
      expect(game_team.giveaways).to eq(17)
      expect(game_team.takeaways).to eq(7)
    end
  end
end 