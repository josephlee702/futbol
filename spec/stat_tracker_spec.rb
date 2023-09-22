require 'spec_helper'
RSpec.describe StatTracker do
  let(:game_path) { './data/test_games.csv' }
  let(:team_path) { './data/teams.csv' } 
  let(:game_teams_path) { './data/test_game_teams.csv' } 
  let(:test_locations) { 
    {games: game_path,
    teams: team_path,
    game_teams: game_teams_path}
    } 
  let(:stat_tracker) { StatTracker.from_csv(test_locations) } 

  describe "::from_csv" do 
    it 'will create a new instance of StatTracker using data from the given csv' do
      expect(stat_tracker).to be_a(StatTracker)
    end
    it 'will create an array of Team objects to be used by the StatTracker' do 
      expect(stat_tracker.teams).to be_a(Array)
      expect(stat_tracker.teams.first).to be_a(Team)
    end
    it 'will create an array of Game objects to be used by the StatTracker' do 
      expect(stat_tracker.games).to be_a(Array)
      expect(stat_tracker.games.first).to be_a(Game)
    end
    it 'will create an array of GameTeam objects to be used by the StatTracker' do 
      expect(stat_tracker.game_teams).to be_a(Array)
      expect(stat_tracker.game_teams.first).to be_a(GameTeam)
    end
  end
  context 'Game Statistic Methods' do
    describe "#highest total score" do 
      it 'will find the highest sum of the winning and losing teams scores and return them as integers' do
        expect(stat_tracker.highest_total_score).to be_an(Integer)
        expect(stat_tracker.highest_total_score).to eq(7)
      end 
    end
    describe "#lowest total score" do 
      it 'will find the lowest sum of the winning and losing teams scores' do 
      expect(stat_tracker.lowest_total_score).to be_an(Integer)
      expect(stat_tracker.lowest_total_score).to eq(1)
      end
    end
    describe "#percentage home wins" do 
      it 'will find the percentage of games that a home team has won' do 
        expect(stat_tracker.percentage_home_wins).to  be_a(Float)
        expect(stat_tracker.percentage_home_wins).to  eq(68.0)
      end
    end
    describe "#percentage visitor wins" do 
      it 'will find the percentage of games that a visitor has won' do 
        expect(stat_tracker.percentage_visitor_wins).to  be_a(Float)
        expect(stat_tracker.percentage_visitor_wins).to  eq(30.0)
      end
    end
    describe "#percentage_ties" do 
      it 'will find the percentage of games that ended in a tie' do 
        expect(stat_tracker.percentage_ties).to  be_a(Float)
        expect(stat_tracker.percentage_ties).to  eq(2.00)
      end
    end
    describe '#count_of_games_by_season' do 
      it 'will return a A hash with season names as keys and counts of games as values' do
        expect(stat_tracker.count_of_games_by_season).to be_a(Hash)
        expect(stat_tracker.count_of_games_by_season).to eq({20122013=>57, 20162017=>4, 20142015=>6, 20152016=>6})
      end
    end
    describe '#average_goals_per_game' do 
      it 'will return the average number of goals scored accross all seasons including both home and away goals' do 
        expect(stat_tracker.average_goals_per_game).to be_a(Float)
        expect(stat_tracker.average_goals_per_game).to eq(3.95)
      end
    end
    describe '#average_goals_by_season' do 
      it 'will return a hash with season names as keys, and a float representing the average number of goals in a game for that season as values' do
        expect(stat_tracker.average_goals_by_season).to be_a(Hash)
        expect(stat_tracker.average_goals_by_season).to eq({20122013=>3.86, 20162017=>3.92, 20142015=>3.88, 20152016=>3.95})
      end
    end
  end
  context 'League Statistic Methods' do
    describe '#count_of_teams' do 
      it 'will return an integer with the total number of teams in the data' do
        expect(stat_tracker.count_of_teams).to be_a(Integer)
        expect(stat_tracker.count_of_teams).to eq(32)
      end
    end
    describe '#best_offense' do 
      it 'will return a string with the name of the team with the highest average number of goals scored per game across all seasons' do
        expect(stat_tracker.best_offense).to be_a(String)
        expect(stat_tracker.best_offense).to eq("New York City FC")
      end
    end
    describe '#worst_offense' do 
      it 'will return a string with the name of the team with the lowest average number of goals scored per game across all seasons' do
        # expect(stat_tracker.worst_offense).to be_a(String)
        expect(stat_tracker.worst_offense).to eq("Houston Dynamo")
      end
    end
    describe '#highest_scoring_visitor' do 
      it 'will return a string with the name of the team with the highest average score per game across all seasons when they are away' do
        expect(stat_tracker.highest_scoring_visitor).to be_a(String)
        expect(stat_tracker.highest_scoring_visitor).to eq("FC Dallas")
      end
    end
    describe '#lowest_scoring_visitor' do 
      it 'will return a string with the name of the team with the lowest average score per game across all seasons when they are away' do
        expect(stat_tracker.lowest_scoring_visitor).to be_a(String)
        expect(stat_tracker.lowest_scoring_visitor).to eq("Seattle Sounders FC")
      end
    end
    describe '#highest_scoring_home_team' do 
      it 'will return a string with the name of the team of the team with the highest average score per game across all seasons when they are home' do
        expect(stat_tracker.highest_scoring_home_team).to be_a(String)
        expect(stat_tracker.highest_scoring_home_team).to eq("New York City FC")
      end
    end
    describe '#lowest_scoring_home_team' do 
      it 'will return a string with the name of the team of the team with the lowest average score per game across all seasons when they are home' do
        expect(stat_tracker.lowest_scoring_home_team).to be_a(String)
        expect(stat_tracker.lowest_scoring_home_team).to eq("Houston Dynamo")
      end
    end
  end

  context 'Season Statistic Methods' do
    describe "#winningest_coach" do 
      it 'will find the coach with the highest win percentage' do
        expect(stat_tracker.winningest_coach(20122013)).to be_an(String)
        expect(stat_tracker.winningest_coach(20122013)).to eq("Claude Julien")
      end 
    end

    describe "#worst_coach" do 
      it 'will find the coach with the lowest win percentage' do
        expect(stat_tracker.worst_coach(20122013)).to be_an(String)
        expect(stat_tracker.worst_coach(20122013)).to eq("John Tortorella")
      end 
    end

    describe "#most_accurate_team" do 
      it 'will find the team with best shots to goals ratio for the season' do
        expect(stat_tracker.most_accurate_team(20122013)).to be_an(String)
        expect(stat_tracker.most_accurate_team(20122013)).to eq("Sporting Kansas City")
      end 
    end

    describe "#least_accurate_team" do 
      it 'will find the team with worst shots to goals ratio for the season' do
        expect(stat_tracker.least_accurate_team(20122013)).to be_an(String)
        expect(stat_tracker.least_accurate_team(20122013)).to eq("FC Cincinnati")
      end 
    end

    describe "#most_tackles" do 
      it 'will find the team with the most tackles in the season' do
        expect(stat_tracker.most_tackles(20122013)).to be_an(String)
        expect(stat_tracker.most_tackles(20122013)).to eq("Sporting Kansas City")
      end 
    end

    describe "#fewest_tackles" do 
      it 'will find the team with the fewest tackles in the season' do
        expect(stat_tracker.fewest_tackles(20122013)).to be_an(String)
        expect(stat_tracker.fewest_tackles(20122013)).to eq("FC Cincinnati")
      end 
    end
  end

  context 'Team Statistic Methods' do
    describe '#team_info' do 
      it 'will return a hash of team info' do
        expect(stat_tracker.team_info(1)).to be_a(Hash)
        expect(stat_tracker.team_info(1)).to eq(:abbreviation=>"ATL", :franchiseid=>23, :link=>"/api/v1/teams/1", :team_id=>1, :teamname=>"Atlanta United")
      end
    end

    describe '#best_season' do 
      it 'will return the season with the highest win percentage for a team' do
        expect(stat_tracker.best_season(6)).to be_a(String)
        expect(stat_tracker.best_season(6)).to eq()
      end
    end

    describe '#worst_season' do 
      it 'will return the season with the lowest win percentage for a team' do
        expect(stat_tracker.worst_season()).to be_a(String)
        expect(stat_tracker.worst_season()).to eq()
      end
    end

    describe '#average_win_percentage' do 
      it 'will return the average win percentage of all games for a team' do
        expect(stat_tracker.average_win_percentage()).to be_a(Float)
        expect(stat_tracker.average_win_percentage()).to eq()
      end
    end
  end
end 