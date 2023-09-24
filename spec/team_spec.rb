require 'spec_helper'
RSpec.describe Team do 
  let(:team_data) { CSV.readlines('./data/teams.csv', headers: true, header_converters: :symbol) } 
  let(:team) { Team.new(team_data.first) } 
  describe 'Initialize' do 
    it 'can initialize' do 
      expect(team).to be_a(Team)
      expect(team.team_id).to eq("1")
      expect(team.franchise_id).to eq("23")
      expect(team.name).to eq("Atlanta United")
      expect(team.abbreviation).to eq("ATL")
      expect(team.stadium).to eq("Mercedes-Benz Stadium")
      expect(team.link).to eq("/api/v1/teams/1")
    end
  end
end 