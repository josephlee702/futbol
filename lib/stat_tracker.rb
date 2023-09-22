require "csv"
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
    (x * 100).round(2)
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
    (x * 100).round(2)
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
    (x * 100).round(2)
  end

  def count_of_games_by_season
    games_per_season = Hash.new(0)
    @games.each do |game|
      games_per_season[game.season] += 1
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
    total_goals = 0.00
    total_games = 0.00
    @games.each do |game|
      key = game.season
      value1 = game.away_goals
      value2 = game.home_goals
      total_games += 1.00
      total_goals += value1
      total_goals += value2
      avg_goals_game = (total_goals / total_games)
      hash[key] = avg_goals_game.round(2)
    end
    hash
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
    accuracy_by_team.max.first
    #goals / shots is what we need
  end

  def least_accurate_team(season)
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
    accuracy_by_team.min.first
    #goals / shots is what we need
  end

  def most_tackles(season)
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
    tackles_by_team.max.first
  end

  def fewest_tackles(season)
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
    tackles_by_team.min.first
  end

#Team Statistic Methods
  def team_info(team_id)
    team_info = Hash.new(0)
    @teams.find do |team|
      if team_id == team.team_id
        # require 'pry'; binding.pry
        team_info[:team_id] = team.team_id
        team_info[:franchiseid] = team.franchise_id
        team_info[:teamname] = team.name
        team_info[:abbreviation] = team.abbreviation
        team_info[:link] = team.link
      else
        p "Cannot find that team"
      end
    end
    team_info
  end

  def best_season(team_id)
    #create a hash of season and win percentage as key value pairs
    season_win_percentages = Hash.new(0)
    season_games = @games.find_all { |game| team_id == game.away_team_id || game.home_team_id}
    season_games = season_games.map do |game|
      game.game_id
    end
    #find all the wins of a team in a season
    win_in_season = 0
    @game_teams.each do |game_team|
      if game_team.result == "WIN" && season_games.include?(game_team.game_id && team_id == game.team_id)
        season_win_percentages[@game_team.season] += 1
      end
      require 'pry'; binding.pry
    end
    #find total number of games a team played in a season


    # season_games = @game_teams.find_all { |game| game.team_id == team_id }
    # season_games = season_games.map do |game|
    #   game.game_id
    # end
    # @game_teams.each do |game_team|
    #   if game_team.result == "WIN" && season_games.include?(game_team.game_id)
    #     coach_wins[game_team.head_coach] += 1
    #   end
    # end
    # #number of games played by each coach's team
    # coach_total_games = Hash.new(0)
    # @game_teams.each do |game_team|
    #   if season_games.include?(game_team.game_id)
    #     coach_total_games[game_team.head_coach] += 1
    #   end
    # end
    # #now we divide each coach's wins by the number of games their team played
    # coach_win_percentage = {}
    # coach_wins.each do |coach, wins|
    #   coach_win_percentage[coach] = (wins.to_f/coach_total_games[coach].to_f)
    # end
    # winningest_coach = coach_win_percentage.find{ |key, value| value  == coach_win_percentage.values.max }
    # winningest_coach.first
  end

  def worst_season(team_id)

  end

  def average_win_percentage(team_id)

  end
end
