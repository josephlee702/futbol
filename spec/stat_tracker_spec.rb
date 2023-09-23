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
        expect(stat_tracker.percentage_home_wins).to  eq(0.68)
      end
    end
    describe "#percentage visitor wins" do 
      it 'will find the percentage of games that a visitor has won' do 
        expect(stat_tracker.percentage_visitor_wins).to  be_a(Float)
        expect(stat_tracker.percentage_visitor_wins).to  eq(0.32)
      end
    end
    describe "#percentage_ties" do 
      it 'will find the percentage of games that ended in a tie' do 
        expect(stat_tracker.percentage_ties).to  be_a(Float)
        expect(stat_tracker.percentage_ties).to  eq(0.02)
      end
    end
    describe '#count_of_games_by_season' do 
      it 'will return a A hash with season names as keys and counts of games as values' do
        expect(stat_tracker.count_of_games_by_season).to be_a(Hash)
        expect(stat_tracker.count_of_games_by_season).to eq({"20122013"=>57, "20142015"=>6, "20152016"=>6, "20162017"=>4})
      end
    end
    describe '#average_goals_per_game' do 
      it 'will return the average number of goals scored accross all seasons including both home and away goals' do 
        expect(stat_tracker.average_goals_per_game).to be_a(Float)
        expect(stat_tracker.average_goals_per_game).to eq(2.64)
      end
    end
    describe '#average_goals_by_season' do 
      it 'will return a hash with season names as keys, and a float representing the average number of goals in a game for that season as values' do
        expect(stat_tracker.average_goals_by_season).to be_a(Hash)
        expect(stat_tracker.average_goals_by_season).to eq({"20122013"=>3.86, "20142015"=>3.5, "20152016"=>4.67, "20162017"=>4.75})
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
    describe "#season_game_ids" do 
      it 'will find all game ids for the given season' do 
        expect(stat_tracker.season_game_ids("20152016")).to be_a(Array)
        expect(stat_tracker.season_game_ids("20152016")).to eq(["2015030141", "2015030142", "2015030143", "2015030144", "2015030145", "2015030181"])
      end
    end
    describe "#winningest_coach" do 
      it 'will find the coach with the highest win percentage' do
        expect(stat_tracker.winningest_coach("20122013")).to be_an(String)
        expect(stat_tracker.winningest_coach("20122013")).to eq("Claude Julien")
      end 
    end

    describe "#worst_coach" do 
      it 'will find the coach with the lowest win percentage' do
        expect(stat_tracker.worst_coach("20122013")).to be_an(String)
        expect(stat_tracker.worst_coach("20122013")).to eq("John Tortorella")
      end 
    end

    describe "#most_accurate_team" do 
      it 'will find the team with best shots to goals ratio for the season' do
        expect(stat_tracker.most_accurate_team("20122013")).to be_an(String)
        expect(stat_tracker.most_accurate_team("20122013")).to eq("New York City FC")
      end 
    end

    describe "#least_accurate_team" do 
      it 'will find the team with worst shots to goals ratio for the season' do
        expect(stat_tracker.least_accurate_team("20122013")).to be_an(String)
        expect(stat_tracker.least_accurate_team("20122013")).to eq("Houston Dynamo")
      end 
    end

    describe "#most_tackles" do 
      it 'will find the team with the most tackles in the season' do
        expect(stat_tracker.most_tackles("20122013")).to be_an(String)
        expect(stat_tracker.most_tackles("20122013")).to eq("LA Galaxy")
      end 
    end

    describe "#fewest_tackles" do 
      it 'will find the team with the fewest tackles in the season' do
        expect(stat_tracker.fewest_tackles("20122013")).to be_an(String)
        expect(stat_tracker.fewest_tackles("20122013")).to eq("Orlando City SC")
      end 
    end
    context 'Team Statistics' do
      describe '#most_goals_scored' do 
        it 'will return highest number of goals a particular team has scored in a single game.' do 
          expect(stat_tracker.most_goals_scored("3")).to eq(2)
          expect(stat_tracker.most_goals_scored("3")).to be_a(Integer)
        end
      end

      describe '#fewest_goals_scored' do 
        it 'will return lowest number of goals a particular team has scored in a single game.' do 
          expect(stat_tracker.fewest_goals_scored("3")).to eq(0)
          expect(stat_tracker.fewest_goals_scored("3")).to be_a(Integer)
        end
      end

      describe "#favorite_opponent" do 
        it 'will return the name of the opponent that has the lowest win percentage against the given team.' do 
          expect(stat_tracker.favorite_opponent("3")).to eq("Portland Timbers")
          expect(stat_tracker.favorite_opponent("3")).to be_a(String)
        end
      end

      describe "#rival" do 
        it 'will return the name of the opponent that has the highest win percentage against the given team.' do 
          expect(stat_tracker.rival("3")).to eq("FC Dallas")
          expect(stat_tracker.rival("3")).to be_a(String)
        end
      end
    end
  end
end 