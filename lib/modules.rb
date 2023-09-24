module HelperMethods

def offensable
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
    teams_goals_average
  end

  def scorable(hoa)
    hash = Hash.new{ |hash, key| hash[key] = [] }
    @game_teams.each do |game|
      if game.hoa == hoa
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
    [avg, hash]
  end

  def season_game_idables(season)
    season_games = @games.find_all { |game| game.season == season }
    season_game_ids = season_games.map { |game| game.game_id }
  end

  def coachable(season_games)
    #number of wins for each coach
    coach_wins = Hash.new(0)
    #opportunity here to create a helper method (to find all games in a season) and just call that
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
    coach_win_percentage
  end

  def accuratable(season)
    accuracy_by_team = {}
    #sets team names to keys
    @teams.each do |team|
      season_games = season_game_idables(season)
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
    accuracy_by_team
  end

  def tacklable(season)
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
    tackles_by_team
  end

  def seasonable(team_id)
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
    team_win_percentage_by_season
  end

  def goals_scorable(team_id)
    team_games = @game_teams.find_all do |game|
      game.team_id == team_id
    end
    team_game_goals = team_games.map do |game|
      game.goals
    end
    team_game_goals
  end

  def versusable(team_id)
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
    opponent_win_percentage
  end

end

