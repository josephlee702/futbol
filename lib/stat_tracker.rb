require "csv"
require_relative './team'
require_relative './game'
require_relative './game_teams'
class StatTracker
  attr_reader :teams,
              :games,
              :game_teams
  
  def initialize(content)
    @teams = content[:teams]
    @games = content[:games]
    @game_teams = content[:game_teams]
  end

  def self.from_csv(locations)
    # convert each CSV into an array of associated instance objects, ie. teams_arry holds an array of Team objects
    teams_arry = CSV.readlines(locations[:teams], headers: true, header_converters: :symbol).map { |team| Team.new(team) }
    games_arry = CSV.readlines(locations[:games], headers: true, header_converters: :symbol).map { |game| Game.new(game) }
    game_teams_arry = CSV.readlines(locations[:game_teams], headers: true, header_converters: :symbol).map { |game_team| GameTeam.new(game_team)}
    # combine all arrays to be stored in a Hash so we can easily call each array
    contents = {
      teams: teams_arry,
      games: games_arry,
      game_teams: game_teams_arry
    }
    # pass contents hash on to StatTracker to initiate the class.
    StatTracker.new(contents)
  end

# Game Statistic Method
  def highest_total_score
    max = @games.map {|game| game.home_goals + game.away_goals }.max
  end

  def lowest_total_score
    min = @games.map {|game| game.home_goals + game.away_goals }.min
  end

  def percentage_home_wins
    hash = Hash.new{ |hash, key| hash[key] = [] }
    total_games = 0
    @game_teams.each do |game|
      total_games += 0.50
      key = game.game_id
      value_array = []
      value1 = game.result
      value2 = game.hoa
      value_array << value1
      value_array << value2
      hash[key] = value_array
    end
    home_win = 0.00
    hash.values.each do |hashy|
      if hashy[0] == "WIN" && hashy[1] == "home"
        home_win += 1.00
      end
    end
    x = home_win / total_games
    x.round(2)
  end

  def percentage_visitor_wins
    hash = Hash.new{ |hash, key| hash[key] = [] }
    total_games = 0
    @game_teams.each do |game|
      total_games += 0.50
      key = game.game_id
      value_array = []
      value1 = game.result
      value2 = game.hoa
      value_array << value1
      value_array << value2
      hash[key] = value_array
    end
    visitor_win = 0.00
    hash.values.each do |hashy|
      if hashy[0] == "LOSS" && hashy[1] == "home"
        visitor_win += 1.00
      end
    end
    x = visitor_win / total_games
    x.round(2)
  end

  def percentage_ties
    hash = Hash.new{ |hash, key| hash[key] = [] }
    total_games = 0
    @game_teams.each do |game|
      total_games += 0.50
      key = game.game_id
      value_array = []
      value1 = game.result
      value2 = game.hoa
      value_array << value1
      value_array << value2
      hash[key] = value_array
    end
    tie = 0.00
    hash.values.each do |hashy|
      if hashy[0] == "TIE" && hashy[1] == "home"
        tie += 1.00
      end
    end
    x = tie / total_games
    x.round(2)
  end

  def count_of_games_by_season
    games_per_season = Hash.new(0)
    @games.each do |game|
      games_per_season[game.season.to_s] += 1
    end
    games_per_season
  end

  def average_goals_per_game
    @home_goals = 0.0
    @away_goals = 0.0
    @games.each do |game|
      @home_goals += game.home_goals
      @away_goals += game.away_goals
    end
    total_goals = @home_goals+@away_goals
    number_of_games = @games.count
    @average_goals = (total_goals/number_of_games)
    @average_goals.round(2)
  end

  def average_goals_by_season
    hash = Hash.new{ |hash, key| hash[key] = 0.00 }
    hash2 = Hash.new{ |hash, key| hash[key] = 0.00 }
    @games.each do |game|
      @game_count = 0.0
      @home_goals = 0.0
      @away_goals = 0.0
      @game_count += 1.0
      @home_goals += game.home_goals
      @away_goals += game.away_goals
      total_goals = @home_goals + @away_goals
      @key = game.season
      hash[@key.to_s] += total_goals
      hash2[@key.to_s] += @game_count
    end
    hash_values = hash.values
    hash2_values = hash2.values
    avg_array = [hash_values, hash2_values].transpose.map {|x| x.reduce(:/).round(2)}
    hash3 = {}
    hash.keys.each do |key|
      key = key
      key_index = hash.keys.find_index(key)
      key_value = avg_array[key_index]
      hash3[key] = key_value
    end
    hash3
  end
  
  # League Statistic Methods
  def count_of_teams
    @teams.count
  end

  def best_offense
    teams_goals_average = {}
    @teams.each do |team|
      total_games = 0
      total_goals = 0
      games = @game_teams.each do |game_team| 
        if game_team.team_id == team.team_id
          total_games +=1
          total_goals += game_team.goals
        end
      end
      if total_games > 0 && total_goals > 0
        teams_goals_average["#{team.name}"] = (total_goals.to_f / total_games.to_f)
      end
    end
    best_offense = teams_goals_average.find { |team, avg| avg == teams_goals_average.values.max}
    best_offense.first
  end

  def worst_offense
    teams_goals_average = {}
    @teams.each do |team|
      total_games = 0
      total_goals = 0
      games = @game_teams.each do |game_team| 
        if game_team.team_id == team.team_id
          total_games +=1
          total_goals += game_team.goals
        end
      end
      if total_games > 0 && total_goals
      teams_goals_average["#{team.name}"] = (total_goals.to_f / total_games.to_f)
      end
    end
    worst_offense = teams_goals_average.find { |team, avg| avg == teams_goals_average.values.min}
    worst_offense.first
  end

  def highest_scoring_visitor
    hash = Hash.new{ |hash, key| hash[key] = [] }
    @game_teams.each do |game|
      if game.hoa == "away"
        total_goals = 0.00
        total_games = 0.00
        key = game.team_id
        value1 = game.goals
        total_games += 1.00
        total_goals += value1
        hash[key] << [value1, total_games]
      end
    end
    transpo = hash.map { |key, value| value.transpose}
    sum_array = transpo.map do |a|
      [a[0].sum, a[1].sum]
    end
    avg = sum_array.map do |b|
      b[0] / b[1]
    end
    max = avg.max
    index = avg.find_index(max)
    best_visitor = hash.keys[index]
    team_code = best_visitor
    @x = @teams.find do |team|
      team.team_id == team_code
    end
    @x.name
  end

  def lowest_scoring_visitor
    hash = Hash.new{ |hash, key| hash[key] = [] }
    @game_teams.each do |game|
      if game.hoa == "away"
        total_goals = 0.00
        total_games = 0.00
        key = game.team_id
        value1 = game.goals
        total_games += 1.00
        total_goals += value1
        hash[key] << [value1, total_games]
      end
    end
    transpo = hash.map { |key, value| value.transpose}
    sum_array = transpo.map do |a|
      [a[0].sum, a[1].sum]
    end
    avg = sum_array.map do |b|
      b[0] / b[1]
    end
    min = avg.min
    index = avg.find_index(min)
    best_visitor = hash.keys[index]
    team_code = best_visitor
    @x = @teams.find do |team|
      team.team_id == team_code
    end
    @x.name
  end

  def highest_scoring_home_team
    hash = Hash.new{ |hash, key| hash[key] = [] }
    @game_teams.each do |game|
      if game.hoa == "home"
        total_goals = 0.00
        total_games = 0.00
        key = game.team_id
        value1 = game.goals
        total_games += 1.00
        total_goals += value1
        hash[key] << [value1, total_games]
      end
    end
    transpo = hash.map { |key, value| value.transpose}
    sum_array = transpo.map do |a|
      [a[0].sum, a[1].sum]
    end
    avg = sum_array.map do |b|
      b[0] / b[1]
    end
    max = avg.max
    index = avg.find_index(max)
    best_visitor = hash.keys[index]
    team_code = best_visitor
    @x = @teams.find do |team|
      team.team_id == team_code
    end
    @x.name
  end

  def lowest_scoring_home_team
    hash = Hash.new{ |hash, key| hash[key] = [] }
    @game_teams.each do |game|
      if game.hoa == "home"
        total_goals = 0.00
        total_games = 0.00
        key = game.team_id
        value1 = game.goals
        total_games += 1.00
        total_goals += value1
        hash[key] << [value1, total_games]
      end
    end
    transpo = hash.map { |key, value| value.transpose}
    sum_array = transpo.map do |a|
      [a[0].sum, a[1].sum]
    end
    avg = sum_array.map do |b|
      b[0] / b[1]
    end
    min = avg.min
    index = avg.find_index(min)
    best_visitor = hash.keys[index]
    team_code = best_visitor
    @x = @teams.find do |team|
      team.team_id == team_code
    end
    @x.name
  end
  
#Season Statistic Methods
  def winningest_coach(season)
    season = season.to_i
    #number of wins for each coach
    coach_wins = Hash.new(0)
    #opportunity here to create a helper method (to find all games in a season) and just call that
    season_games = @games.find_all { |game| game.season == season }
    season_games = season_games.map do |game|
      game.game_id
    end
    @game_teams.each do |game_team|
      if game_team.result == "WIN" && season_games.include?(game_team.game_id)
        coach_wins[game_team.head_coach] += 1
      end
    end
    #number of games played by each coach's team
    coach_total_games = Hash.new(0)
    @game_teams.each do |game_team|
      if season_games.include?(game_team.game_id)
        coach_total_games[game_team.head_coach] += 1
      end
    end
    #now we divide each coach's wins by the number of games their team played
    coach_win_percentage = {}
    coach_wins.each do |coach, wins|
      coach_win_percentage[coach] = (wins.to_f/coach_total_games[coach].to_f)
    end
    winningest_coach = coach_win_percentage.find{ |key, value| value  == coach_win_percentage.values.max }
    winningest_coach.first
  end

  def worst_coach(season)
    season = season.to_i
    coach_losses = Hash.new(0)
    season_games = @games.find_all { |game| game.season == season }
    season_games = season_games.map do |game|
      game.game_id
    end
    @game_teams.each do |game_team|
      if game_team.result == "LOSS" && season_games.include?(game_team.game_id)
        coach_losses[game_team.head_coach] += 1
      end
    end
    #number of games played by each coach's team
    coach_total_games = Hash.new(0)
    @game_teams.each { |game_team| coach_total_games[game_team.head_coach] += 1 }
    #now we divide each coach's wins by the number of games their team played
    coach_loss_percentage = {}
    coach_losses.each { |coach, losses| coach_loss_percentage[coach] = (losses.to_f/coach_total_games[coach].to_f) }
    worst_coach = coach_loss_percentage.find{ |key, value| value  == coach_loss_percentage.values.max }
    worst_coach.first
  end

  def most_accurate_team(season)
    season = season.to_i
    accuracy_by_team = {}
    #sets team names to keys
    @teams.each do |team|
      season_games = @games.find_all { |game| game.season == season }
      season_games = season_games.map do |game|
        game.game_id
      end
      goals = 0
      shots = 0
      @game_teams.each do |game_team|
        if season_games.include?(game_team.game_id) && game_team.team_id == team.team_id
          goals += game_team.goals
          shots += game_team.shots
        end
      end
      if goals > 0 && shots > 0
        accuracy_by_team[team.name] = goals.to_f/shots.to_f
      end
    end
    max = accuracy_by_team.values.max
    index = accuracy_by_team.values.find_index(max)
    x = accuracy_by_team.keys[index]
    x
  end

  def least_accurate_team(season)
    season = season.to_i
    accuracy_by_team = {}
    #sets team names to keys
    @teams.each do |team|
      season_games = @games.find_all { |game| game.season == season }
      season_games = season_games.map do |game|
        game.game_id
      end
      goals = 0
      shots = 0
      @game_teams.each do |game_team|
        if season_games.include?(game_team.game_id) && game_team.team_id == team.team_id
          goals += game_team.goals
          shots += game_team.shots
        end
      end
      if goals > 0 && shots > 0
        accuracy_by_team[team.name] = goals.to_f/shots.to_f
      end
    end
    min = accuracy_by_team.values.min
    index = accuracy_by_team.values.find_index(min)
    x = accuracy_by_team.keys[index]
    x
  end

  def most_tackles(season)
    season = season.to_i
    tackles_by_team = {}
    @teams.each do |team|
      season_games = @games.find_all { |game| game.season == season}
      season_games = season_games.map do |game|
        game.game_id
      end
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
    max = tackles_by_team.values.max
    index = tackles_by_team.values.find_index(max)
    x = tackles_by_team.keys[index]
    x
  end

  def fewest_tackles(season)
    season = season.to_i
    tackles_by_team = {}
    @teams.each do |team|
      season_games = @games.find_all { |game| game.season == season}
      season_games = season_games.map do |game|
        game.game_id
      end
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
    min = tackles_by_team.values.min
    index = tackles_by_team.values.find_index(min)
    x = tackles_by_team.keys[index]
    x
  end

  def most_goals_scored(team_id)
    team_id = team_id.to_i
    team_array = @game_teams.find_all do |game|
      game.team_id == team_id
    end
    team_game_goals = team_array.map do |game|
      game.goals
    end
    team_game_goals.max
  end

  def fewest_goals_scored(team_id)
    team_id = team_id.to_i
    team_array = @game_teams.find_all do |game|
      game.team_id == team_id
    end
    team_game_goals = team_array.map do |game|
      game.goals
    end
    team_game_goals.min
  end

  def favorite_opponent(team_id)
    team_id = team_id.to_i
    hash = Hash.new{ |hash, key| hash[key] = [] }
    only_team_games = @games.find_all do |game|
      game.away_team_id == team_id || game.home_team_id == team_id
    end
    only_team_games.each do |game|
      win = 0
      loss = 0
      if game.away_team_id == team_id && game.away_goals > game.home_goals
        key = game.home_team_id
        loss += 1
      elsif game.away_team_id == team_id && game.away_goals < game.home_goals
        key = game.home_team_id
        win += 1
      elsif game.home_team_id == team_id && game.home_goals > game.away_goals
        key = game.away_team_id
        loss += 1
      else game.home_team_id == team_id && game.home_goals < game.away_goals
        key = game.away_team_id
        win += 1
      end
      hash[key] << [win, loss]
    end
    transpo = hash.map { |key, value| value.transpose}
    sum_array = transpo.map do |a|
      [a[0].sum, a[1].sum]
    end
    avg = sum_array.map do |b|
      (b[0].to_f / (b[1].to_f + b[0].to_f))
    end
    min = avg.min
    index = avg.find_index(min)
    best_opponent = hash.keys[index]
    team_code = best_opponent
    @x = @teams.find do |team|
      team.team_id == team_code
    end
    @x.name
  end

  def rival(team_id)
    team_id = team_id.to_i
    hash = Hash.new{ |hash, key| hash[key] = [] }
    only_team_games = @games.find_all do |game|
      game.away_team_id == team_id || game.home_team_id == team_id
    end
    only_team_games.each do |game|
      win = 0
      loss = 0
      if game.away_team_id == team_id && game.away_goals > game.home_goals
        key = game.home_team_id
        loss += 1
      elsif game.away_team_id == team_id && game.away_goals < game.home_goals
        key = game.home_team_id
        win += 1
      elsif game.home_team_id == team_id && game.home_goals > game.away_goals
        key = game.away_team_id
        loss += 1
      else game.home_team_id == team_id && game.home_goals < game.away_goals
        key = game.away_team_id
        win += 1
      end
      hash[key] << [win, loss]
    end
    transpo = hash.map { |key, value| value.transpose}
    sum_array = transpo.map do |a|
      [a[0].sum, a[1].sum]
    end
    avg = sum_array.map do |b|
      (b[0].to_f / (b[1].to_f + b[0].to_f))
    end
    #require 'pry'; binding.pry
    max = avg.max
    index = avg.find_index(max)
    rival = hash.keys[index]
    team_code = rival
    @x = @teams.find do |team|
      team.team_id == team_code
    end
    @x.name
  end
end
