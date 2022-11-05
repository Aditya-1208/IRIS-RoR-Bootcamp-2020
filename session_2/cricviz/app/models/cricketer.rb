class Cricketer < ApplicationRecord
  # Select players from the country 'Australia'
  scope :australian_players, -> {where(country: "Australia")}

  # Select players with the role 'Batter'
  scope :batters, -> { where(role: "Batter") }

  # Select players with the role 'Bowler'
  scope :bowlers, -> { where(role: "Bowler") }

  # Sort players by the descending number of matches played
  scope :descending_by_matches, -> { order(matches: "desc") }

  # Batting average: Runs scored / (Number of innings in which player has been out)
  #
  # Note:
  # - If any of runs scored, innings batted and not outs are missing,
  #   return nil as the data is incomplete.
  # - If the player has not batted yet, return nil
  # - If the player has been not out in all innings, return runs scored.
  def batting_average
    if !runs_scored || !innings_batted || !not_out || innings_batted<=0
      return nil
    end
    if innings_batted==not_out
      return runs_scored
    else
      return runs_scored.to_f/(innings_batted-not_out)
    end
  end

  # Batting strike rate: (Runs Scored x 100) / (Balls Faced)
  #
  # Note:
  # - If any of runs scored and balls faced are missing, return nil as the
  #   data is incomplete
  # - If the player has not batted yet, return nil
  def batting_strike_rate
    if !runs_scored || !balls_faced || balls_faced<=0
      return nil
    end
    return (runs_scored*100.0)/balls_faced
  end

  # Create records for the classical batters
  def self.import_classical_batters
    data_attrs = %w[name country role matches innings_batted not_out runs_scored balls_faced high_score centuries half_centuries]
    data = [["Sachin Tendulkar","India","Batter",200,329,33,15921,0,248,51,68],
            ["Rahul Dravid","India","Batter",164,286,32,13288,31258,270,36,63],
            ["Kumar Sangakkara","Sri Lanka","Wicketkeeper",134,233,17,12400,22882,319,38,52],
            ["Ricky Ponting","Australia","Batter",168,287,29,13378,22782,257,41,62],
            ["Brian Lara","West Indies","Batter",131,232,6,11953,19753,400,34,48]]
    data.each do |cricketer|
      @classical_batters = self.create(Hash[data_attrs.zip cricketer])
    end
  end

  # Update the current data with an innings scorecard.
  #
  # A batting_scorecard is defined an array of the following type:
  # [Player name, Is out, Runs scored, Balls faced, 4s, 6s]
  #
  # For example:
  # [
  #   ['Rohit Sharma', true, 26, 77, 3, 1],
  #   ['Shubham Gill', true, 50, 101, 8, 0],
  #   ...
  #   ['Jasprit Bumrah', false, 0, 2, 0, 0],
  #   ['Mohammed Siraj', true, 6, 10, 1, 0]
  # ]
  #
  # There are atleast two batters and upto eleven batters in an innings.
  #
  # A bowling_scorecard is defined as an array of the following type:
  # [Player name, Balls bowled, Maidens bowled, Runs given, Wickets]
  #
  # For example:
  # [
  #   ['Mitchell Starc', 114, 7, 61, 1],
  #   ['Josh Hazzlewood', 126, 10, 43, 2],
  #   ...
  #   ['Cameron Green', 30, 2, 11, 0]
  # ]
  #
  # Note: If you cannot find a player with given name, raise an
  # `ActiveRecord::RecordNotFound` exception with the player's name as
  # the message.
  def self.update_innings(batting_scorecard, bowling_scorecard)
    batting_scorecard.each do |bat_sc|
        player = self.find_by(name: bat_sc[0])
        raise ActiveRecord::RecordNotFound.new bat_sc[0] if !player
        player.innings_batted+=1
        player.not_out +=bat_sc[1] ? 0 : 1
        player.runs_scored+=bat_sc[2]
        player.high_score = [player.high_score, bat_sc[2]].max
        player.half_centuries+=bat_sc[2]/50
        player.centuries+=bat_sc[2]/100
        player.balls_faced += bat_sc[3]
        player.fours_scored += bat_sc[4]
        player.sixes_scored += bat_sc[5]
        player.save
    end
    bowling_scorecard.each do |bowl_sc|
        player = self.find_by(name: bowl_sc[0])
        raise ActiveRecord::RecordNotFound.new bowl_sc[0] if !player
        player.innings_bowled+=1
        player.balls_bowled+=bowl_sc[1]
        player.runs_given+=bowl_sc[3]
        player.wickets_taken+=bowl_sc[4]
        player.save
      end
  end

  # Delete the record associated with a player.
  #
  # Note: If you cannot find a player with given name, raise an
  # `ActiveRecord::RecordNotFound` exception.
  def self.ban(name)
      player = self.find_by(name: name)
      if !player
        raise ActiveRecord::RecordNotFound
      end
      player.destroy
  end
end
