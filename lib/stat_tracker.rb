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
  def season_game_ids(season)
    season_games = @games.find_all { |game| game.season == season }
    season_game_ids = season_games.map { |game| game.game_id }
  end


  def winningest_coach(season)
    #number of wins for each coach
    coach_wins = Hash.new(0)
    #opportunity here to create a helper method (to find all games in a season) and just call that
    season_games = season_game_ids(season)
    @game_teams.each do |game_team|
      if game_team.result == "WIN" && season_games.include?(game_team.game_id)
        coach_wins[game_team.head_coach] += 1.0
      elsif season_games.include?(game_team.game_id)
        coach_wins[game_team.head_coach] += 0.0
      else

      end
    end
    #number of games played by each coach's team
    coach_total_games = Hash.new(0)
    @game_teams.each do |game_team|
      if season_games.include?(game_team.game_id)
        coach_total_games[game_team.head_coach] += 1.0
      end
    end
    #now we divide each coach's wins by the number of games their team played
    coach_win_percentage = {}
    coach_wins.each do |coach, wins|
      coach_win_percentage[coach] = (wins/coach_total_games[coach])
    end
    winningest_coach = coach_win_percentage.find{ |key, value| value  == coach_win_percentage.values.max }
    winningest_coach.first
  end
  
  def worst_coach(season)
    #number of wins for each coach
    coach_wins = Hash.new(0)
    #opportunity here to create a helper method (to find all games in a season) and just call that
    season_games = season_game_ids(season)
    @game_teams.each do |game_team|
      if game_team.result == "WIN" && season_games.include?(game_team.game_id)
        coach_wins[game_team.head_coach] += 1
      elsif season_games.include?(game_team.game_id)
        coach_wins[game_team.head_coach] += 0
      else

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
    worst_coach = coach_win_percentage.find{ |key, value| value  == coach_win_percentage.values.min }
    worst_coach.first
  end

  def most_accurate_team(season)
    accuracy_by_team = {}
    #sets team names to keys
    @teams.each do |team|
      season_games = season_game_ids(season)
      goals = 0
      shots = 0
      @game_teams.each do |game_team|
        if season_games.include?(game_team.game_id) && game_team.team_id == team.team_id
          goals += game_team.goals
          shots += game_team.shots
        end
      end
      if goals > 0 && shots > 0
        accuracy_by_team[team.name] = (goals.to_f/shots.to_f)
      end
    end
    most_accurate = accuracy_by_team.values.max
    accuracy_by_team.find { |key, value| value == most_accurate}.first
    #goals / shots is what we need
  end

  def least_accurate_team(season)
    accuracy_by_team = {}
    #sets team names to keys
    @teams.each do |team|
      season_games = season_game_ids(season)
      goals = 0
      shots = 0
      @game_teams.each do |game_team|
        if season_games.include?(game_team.game_id) && game_team.team_id == team.team_id
          goals += game_team.goals
          shots += game_team.shots
        end
      end
      if goals > 0 && shots > 0
        accuracy_by_team[team.name] = (goals.to_f/shots.to_f)
      end
    end
    least_accurate = accuracy_by_team.values.min
    accuracy_by_team.find { |key, value| value == least_accurate}.first
    #goals / shots is what we need
  end

  def most_tackles(season)
    tackles_by_team = {}
    @teams.each do |team|
      season_games = season_game_ids(season)
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
      season_games = season_game_ids(season)
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
    @games.each do |game|
      if team_id == game.team_id
    end
  end

  def worst_loss(team_id)
    #Biggest difference between team goals and opponent goals for a loss for the given team. Integer

  end

  def head_to_head(team_id)
    #Record (as a hash - win/loss) against all opponents with the opponents’ names as keys and the win percentage against that opponent as a value.	#Hash

  end

  def seasonal_summary(team_id)
    #For each season that the team has played, a hash that has two keys (:regular_season and :postseason), that each point to a hash with the following keys: :win_percentage, :total_goals_scored, :total_goals_against, :average_goals_scored, :average_goals_against. #Hash

  end
end
end
