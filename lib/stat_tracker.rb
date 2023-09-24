require "csv"
require_relative './team'
require_relative './game'
require_relative './game_teams'
require_relative './modules'

class StatTracker
  include HelperMethods
  attr_reader :teams,
              :games,
              :game_teams
  
  def initialize(content)
    @teams = content[:teams]
    @games = content[:games]
    @game_teams = content[:game_teams]
    @teams_h = content[:teams_h]
    @games_h = content[:games_h]
    @game_teams_h = content[:game_teams_h]
  end

  def self.from_csv(locations)
    # convert each CSV into an array of associated instance objects, ie. teams_arry holds an array of Team objects
    teams_arry = CSV.readlines(locations[:teams], headers: true, header_converters: :symbol).map { |team| Team.new(team) }
    games_arry = CSV.readlines(locations[:games], headers: true, header_converters: :symbol).map { |game| Game.new(game) }
    game_teams_arry = CSV.readlines(locations[:game_teams], headers: true, header_converters: :symbol).map { |game_team| GameTeam.new(game_team)}
    # make hashes
    teams_hash = CSV.readlines(locations[:teams], headers: true, header_converters: :symbol).map { |team| [team[:team_id], Team.new(team)] }.to_h
    games_hash = CSV.readlines(locations[:games], headers: true, header_converters: :symbol).map { |game| [game[:game_id], Game.new(game)] }.to_h
    game_teams_hash = CSV.readlines(locations[:game_teams], headers: true, header_converters: :symbol).map { |game_team| [game_team[:game_id], GameTeam.new(game_team)] }.to_h
    # combine all arrays to be stored in a Hash so we can easily call each array
    contents = {
      teams: teams_arry,
      games: games_arry,
      game_teams: game_teams_arry,
      teams_h: teams_hash,
      games_h: games_hash,
      game_teams_h: game_teams_hash
    }
    # pass contents hash on to StatTracker to initiate the class.
    StatTracker.new(contents)
  end

# Game Statistic Method
  def highest_total_score
    @games.map {|game| game.home_goals + game.away_goals }.max
  end

  def lowest_total_score
    @games.map {|game| game.home_goals + game.away_goals }.min
  end

  # refactored percentage methods for simplicity and readability

  def percentage_home_wins
    total_games = 0.0
    home_wins = 0.0
    @game_teams.each do |game|
      total_games += 0.50
      if game.result == "WIN" && game.hoa == "home"
        home_wins +=1
      end
    end
    percentage_home_wins = (home_wins / total_games).round(2)
  end

  def percentage_visitor_wins
    total_games = 0.0
    visitor_wins = 0.0
    @game_teams.each do |game|
      total_games += 0.50
      if game.result == "WIN" && game.hoa == "away"
        visitor_wins +=1
      end
    end
    percentage_visitor_wins = (visitor_wins / total_games).round(2)
  end

  def percentage_ties
    total_games = 0.0
    tie_games = 0.0
    @game_teams.each do |game|
      total_games += 0.5
      if game.result == "TIE"
        tie_games += 0.5
      end
    end
    percentage_ties = (tie_games / total_games).round(2)
  end

  def count_of_games_by_season
    games_per_season = Hash.new(0)
    @games.each do |game|
      games_per_season[game.season] += 1
    end
    games_per_season
  end

  # refactored for simplicity
  def average_goals_per_game
    total_goals = 0.0
    @game_teams.each do |game|
      total_goals += game.goals
    end
    average_goals = (total_goals/@games.count).round(2)
  end
  # refactored to fit spec_harness
  def average_goals_by_season
    goals_per_season = Hash.new(0)
    games_per_season = Hash.new(0)
    @games.each do |game|
      game_count = 0.0
      home_goals = 0.0
      away_goals = 0.0
      game_count += 1.0
      home_goals += game.home_goals
      away_goals += game.away_goals
      total_goals = home_goals + away_goals
      goals_per_season[game.season] += total_goals
      games_per_season[game.season] += game_count
    end
    season_averages = [goals_per_season.values, games_per_season.values].transpose.map {|x| x.reduce(:/).round(2)}
    average_goals_by_season = {}
    goals_per_season.keys.each do |season|
      index = goals_per_season.keys.find_index(season)
      season_average = season_averages[index]
      average_goals_by_season[season] = season_average
    end
    average_goals_by_season
  end
  
  # League Statistic Methods
  def count_of_teams
    @teams.count
  end

  def best_offense
    teams_goals_average = offensable
    best_offense = teams_goals_average.find { |team, avg| avg == teams_goals_average.values.max}
    best_offense.first
  end

  def worst_offense
    teams_goals_average = offensable
    worst_offense = teams_goals_average.find { |team, avg| avg == teams_goals_average.values.min}
    worst_offense.first
  end

  def highest_scoring_visitor
    avg = scorable("away")
    max = avg[0].max
    index = avg[0].find_index(max)
    best_visitor = avg[1].keys[index]
    team_code = best_visitor
    x = @teams.find do |team|
      team.team_id == team_code
    end
    x.name
  end

  def lowest_scoring_visitor
    avg = scorable("away")
    min = avg[0].min
    index = avg[0].find_index(min)
    best_visitor = avg[1].keys[index]
    team_code = best_visitor
    x = @teams.find do |team|
      team.team_id == team_code
    end
    x.name
  end

  def highest_scoring_home_team
    avg = scorable("home")
    max = avg[0].max
    index = avg[0].find_index(max)
    best_visitor = avg[1].keys[index]
    team_code = best_visitor
    x = @teams.find do |team|
      team.team_id == team_code
    end
    x.name
  end

  def lowest_scoring_home_team
    avg = scorable("home")
    min = avg[0].min
    index = avg[0].find_index(min)
    best_visitor = avg[1].keys[index]
    team_code = best_visitor
    x = @teams.find do |team|
      team.team_id == team_code
    end
    x.name
  end
  
#Season Statistic Methods

  def winningest_coach(season)
    season_games = season_game_idables(season)
    coach_win_percentage = coachable(season_games)
    winningest_coach = coach_win_percentage.find{ |key, value| value  == coach_win_percentage.values.max }
    winningest_coach.first
  end
  
  def worst_coach(season)
    season_games = season_game_idables(season)
    coach_win_percentage = coachable(season_games)
    worst_coach = coach_win_percentage.find{ |key, value| value  == coach_win_percentage.values.min }
    worst_coach.first
  end

  def most_accurate_team(season)
    accuracy_by_team = accuratable(season)
    most_accurate = accuracy_by_team.values.max
    accuracy_by_team.find { |key, value| value == most_accurate}.first
    #goals / shots is what we need
  end

  def least_accurate_team(season)
    accuracy_by_team = accuratable(season)
    least_accurate = accuracy_by_team.values.min
    accuracy_by_team.find { |key, value| value == least_accurate}.first
    #goals / shots is what we need
  end

  def most_tackles(season)
    tackles_by_team = {}
    @teams.each do |team|
      season_games = season_game_idables(season)
      tackles = 0
      @game_teams.each do |game_team|
        if season_games.include?(game_team.game_id) && game_team.team_id == team.team_id
          tackles += game_team.tackles
        end
      end
      if tackles > 0
        tackles_by_team[team.name] = tackles
      end
    end
    most_tackles = tackles_by_team.values.max
    tackles_by_team.find { |team, tackles| tackles == most_tackles}.first
  end

  def fewest_tackles(season)
    tackles_by_team = {}
    @teams.each do |team|
      season_games = season_game_idables(season)
      tackles = 0
      @game_teams.each do |game_team|
        if season_games.include?(game_team.game_id) && game_team.team_id == team.team_id
          tackles += game_team.tackles
        end
      end
      if tackles > 0
        tackles_by_team[team.name] = tackles
      end
    end
    fewest_tackles = tackles_by_team.values.min
    tackles_by_team.find { |team, tackles| tackles == fewest_tackles}.first
  end

  #Team Statistic Methods
  def team_info(team_id)
    team_info = Hash.new(0)
    team = @teams.find { |team| team.team_id == team_id}
    team_info["team_id"] = team.team_id
    team_info["franchise_id"] = team.franchise_id
    team_info["team_name"] = team.name
    team_info["abbreviation"] = team.abbreviation
    team_info["link"] = team.link
    team_info
  end

  def best_season(team_id)
    season_win_percentages = Hash.new(0)
    #this gives all the games that the team was part of
    season_games = @game_teams.find_all { |game| team_id == game.team_id }
    #this gives an array of all game ids they played
    season_games = season_games.map do |game|
      game.game_id
    end
    #find all the wins of a team in a season
    total_wins = Hash.new(0)
    @game_teams.each do |game_team|
      if team_id == game_team.team_id && game_team.result == "WIN" && season_games.include?(game_team.game_id)
        @games.each do |game|
          if game.game_id == game_team.game_id
            total_wins[game.season] += 1
          end
        end
      end
    end
    #find the total games a team played in a season
    total_games = Hash.new(0)
    games_played = 0
    @game_teams.each do |game_team|
      if team_id == game_team.team_id && season_games.include?(game_team.game_id)
        @games.each do |game|
          if game.game_id == game_team.game_id
          total_games[game.season] += 1
          end
        end
      end
    end
    #now we have to divide the wins by total games played in a season
    team_win_percentage_by_season = {}
    total_wins.each do |season, wins|
      team_win_percentage_by_season[season] = (wins.to_f / total_games[season].to_f)
    end
    index = team_win_percentage_by_season.values.max
    season_most_wins = team_win_percentage_by_season.key(index).to_s
  end

  def worst_season(team_id)
    season_win_percentages = Hash.new(0)
    #this gives all the games that the team was part of
    season_games = @game_teams.find_all { |game_team| team_id == game_team.team_id }
    #this gives an array of all game ids they played
    season_games = season_games.map do |game_team|
      game_team.game_id
    end
    #find all the wins of a team in a season
    total_wins = Hash.new(0)
    @game_teams.each do |game_team|
      if team_id == game_team.team_id && game_team.result == "WIN" && season_games.include?(game_team.game_id)
        @games.each do |game|
          if game.game_id == game_team.game_id
            total_wins[game.season] += 1
          end
        end
      end
    end
    #find the total games a team played in a season
    total_games = Hash.new(0)
    games_played = 0
    @game_teams.each do |game_team|
      if team_id == game_team.team_id && season_games.include?(game_team.game_id)
        @games.each do |game|
          if game.game_id == game_team.game_id
          total_games[game.season] += 1
          end
        end
      end
    end
    #now we have to divide the wins by total games played in a season
    team_win_percentage_by_season = {}
    total_wins.each do |season, wins|
      team_win_percentage_by_season[season] = (wins.to_f / total_games[season].to_f)
    end
    index = team_win_percentage_by_season.values.min
    season_least_wins = team_win_percentage_by_season.key(index).to_s
  end

  def average_win_percentage(team_id)
    game_wins = 0
    total_games = 0
    @game_teams.each do |game_team| 
      if team_id == game_team.team_id && game_team.result == "WIN"
        game_wins += 1
      end
      if team_id == game_team.team_id 
        total_games += 1
      end
    end
    average_win_percentage = (game_wins.to_f / total_games.to_f).round(2)
    average_win_percentage
  end

  def most_goals_scored(team_id)
    team_games = @game_teams.find_all do |game|
      game.team_id == team_id
    end
    team_game_goals = team_games.map do |game|
      game.goals
    end
    team_game_goals.max
  end

  def fewest_goals_scored(team_id)
    team_games = @game_teams.find_all do |game|
      game.team_id == team_id
    end
    team_game_goals = team_games.map do |game|
      game.goals
    end
    team_game_goals.min
  end
  
  def favorite_opponent(team_id)
    team_games = @games.find_all do |game|
      game.away_team_id == team_id || game.home_team_id == team_id
    end
    game_ids = team_games.map { |game| game.game_id}
    team_games = @game_teams.find_all { |game| game_ids.include?(game.game_id) }
    opponent_wins = Hash.new(0)
    opponent_games = Hash.new(0)
    team_wins = 0
    team_games.each do |game|
      if game.team_id != team_id && game.result == "WIN"
        opponent_wins[game.team_id] += 1.0
        opponent_games[game.team_id] += 1.0
      elsif game.team_id != team_id
        opponent_games[game.team_id] += 1.0
        opponent_wins[game.team_id] += 0.0
      elsif game.team_id != team_id && game.result == "TIE"
        opponent_games[game.team_id] += 1.0
        opponent_wins[game.team_id] += 0.0
      end
    end
    opponent_win_percentage = {}
    opponent_wins.map do |team_id, wins|
      team = @teams.find { |team| team.team_id == team_id }
      opponent_win_percentage[team.name] = (wins / opponent_games[team.team_id])
    end
    favorite_opponent = opponent_win_percentage.find { |team, wins| wins == opponent_win_percentage.values.min }
    favorite_opponent.first
  end

  def rival(team_id)
    team_games = @games.find_all do |game|
      game.away_team_id == team_id || game.home_team_id == team_id
    end
    game_ids = team_games.map { |game| game.game_id}
    team_games = @game_teams.find_all { |game| game_ids.include?(game.game_id) }
    opponent_wins = Hash.new(0)
    opponent_games = Hash.new(0)
    team_wins = 0
    team_games.each do |game|
      if game.team_id != team_id && game.result == "WIN"
        opponent_wins[game.team_id] += 1.0
        opponent_games[game.team_id] += 1.0
      elsif game.team_id != team_id
        opponent_games[game.team_id] += 1.0
        opponent_wins[game.team_id] += 0.0
      elsif game.team_id != team_id && game.result == "TIE"
        opponent_games[game.team_id] += 1.0
        opponent_wins[game.team_id] += 0.0
      end
    end
    opponent_win_percentage = {}
    opponent_wins.map do |team_id, wins|
      team = @teams.find { |team| team.team_id == team_id }
      opponent_win_percentage[team.name] = (wins / opponent_games[team.team_id])
    end
    rival = opponent_win_percentage.find { |team, wins| wins == opponent_win_percentage.values.max }
    rival.first
  end

  def biggest_team_blowout(team_id)
    #Biggest difference between team goals and opponent goals for a win for the given team.	Integer
    goal_differences = []
    team_wins = @game_teams.find_all {|game| game.team_id == team_id && game.result == "WIN"}

    team_wins.each do |game|
      goal_differences << (@games_h[game.game_id].away_goals - @games_h[game.game_id].home_goals).abs 
    end

    goal_differences.max
  end

  def worst_loss(team_id)
    goal_differences = []
    team_losses = @game_teams.find_all {|game| game.team_id == team_id && game.result == "LOSS"}

    team_losses.each do |game|
      game_stats = @games_h[game.game_id]
      goal_differences << (game_stats.away_goals - game_stats.home_goals).abs 
    end

    goal_differences.max
  end

  def head_to_head(team_id)
    head_to_head_stats = Hash.new{|h,k| h[k] = Hash.new(0)}
    games = @game_teams.find_all { |game| game.team_id == team_id }
    games.each do |game|
      game_stats = @games_h[game.game_id]
      opponent = game.hoa == "away" ? game_stats.home_team_id : game_stats.away_team_id
      opponent_name = @teams_h[opponent].name
      win = game.result == "WIN" ? 1 : 0

      if head_to_head_stats.keys.include?(opponent_name)
        head_to_head_stats[opponent_name][:wins] += win
        head_to_head_stats[opponent_name][:total_games] += 1
      else
        head_to_head_stats[opponent_name] = {
          :wins => win,
          :total_games => 1
        }
      end
    end

    head_to_head_stats_final = {}
    head_to_head_stats.each do |opponent, stats|
      head_to_head_stats_final[opponent] = (stats[:wins].to_f / stats[:total_games].to_f).round(2)
    end
    head_to_head_stats_final
  end

  # def seasonal_summary(team_id)
  #   #For each season that the team has played, a hash that has two keys (:regular_season and :postseason), that each point to a hash with the following keys: :win_percentage, :total_goals_scored, :total_goals_against, :average_goals_scored, :average_goals_against. #Hash
    
  # end
end


