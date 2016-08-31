#Scrabble.rb

require_relative '../Scrabble/'
require 'awesome_print'

#Create Scoring class
class Scrabble::Scoring

  #Create self.bonus_check method: checks to see if word gets 7 letter bonus
  def self.bonus_check(letters)
    bonus = 0
    if letters.length == 7
      bonus = 50
    end
    return bonus
  end

  #Create self.score: returns total score of word input
  def self.score(word)
    word = word.upcase #changes all letters to uppercase

    letters = word.split(//)
    score = 0
    letters.each do |letter|
      raise ArgumentError.new("Only letters A-Z are excepted") if Scrabble::LETTER_VALUES.detect{ |k, v| k.include?(letter)} == nil
      a = Scrabble::LETTER_VALUES.detect{ |k, v| k.include?(letter)}
      score += a[1]
    end

    score += bonus_check(letters)

    return score
  end

  #Create self.highest_score_from method: returns highest scoring word in given list
  def self.highest_score_from(word_options)

    scores = []
    word_options.each do |word|
      scores << score(word)      #loop stores scores of each word in list in array
    end

    max_val = scores.max
    index_array = scores.each_index.select{|i| scores[i] == max_val} #finds index of highest scoring word(s)

    high_score_words = word_options.values_at(*index_array) #returns array of highest scoring word(s)

    #following part of code deals with possibility of tie in score
    if high_score_words.max_by(&:length).length == 7 # (&:length) is a shortcut of the iteration {|i| i.length}
      return high_score_words.max_by(&:length)
    else
      return high_score_words.min_by(&:length)
    end

  end

end

class Scrabble::Player
  attr_reader :name, :plays, :player_tiles
  def initialize(name, tilebag_object = Scrabble::TileBag.new)
    @name = name
    @plays = []
    @player_tiles = []
    @tile_bag = tilebag_object
    draw_tiles
  end

  # Method to store a played word and return the score
  def play(word)
      word = word.upcase
      score = Scrabble::Scoring.score(word)
      plays << word
      if won? == true # Check if the game should already be over
        return false
      end
      puts plays
      return score
  end

  # Method to calculate the current total score
  def total_score
    total_score = 0
    plays.each do |word|
      total_score += Scrabble::Scoring.score(word)
    end
    return total_score
  end

  # Method to determine if the player has won
  def won?
    win = false
    win = true if total_score >= 100
    return win
  end

  # Method to find the highest scoring WORD played
  def highest_scoring_word
    word = Scrabble::Scoring.highest_score_from(plays)
    return word
  end

  # Method to find the SCORE of the highest scoring word played
  def highest_word_score
    word = highest_scoring_word
    highest_score = Scrabble::Scoring.score(word)
    return highest_score
  end


  def draw_tiles

    fill = 7 - @player_tiles.length
    @player_tiles += @tile_bag.draw_tiles(fill)
    return @player_tiles

  end

  def update_player_tiles(word)
    letters = word.upcase.split(//)
    letters.each do |letter|
      @player_tiles.delete_at(@player_tiles.index(letter))
    end
    draw_tiles
    return @player_tiles
  end

end

class Scrabble::TileBag
  attr_reader :tiles
  def initialize
    @tiles = Scrabble::BEGINNING_TILE_BAG.clone
  end


  def draw_tiles(num)
    drawn_tiles = []
    num.times do
      drawn_tile = @tiles.to_a.sample[0]
      @tiles[drawn_tile] -= 1
      drawn_tiles << drawn_tile.to_s

      clean_up_bag(drawn_tile)  #Remove letters without tiles left from @@tiles
    end
    return drawn_tiles
  end

  def tiles_remaining
    return @tiles.values.inject(:+)
  end

  def clean_up_bag(drawn_tile)
    if @tiles[drawn_tile] == 0
      @tiles.delete(drawn_tile)
    end
    return @tiles
  end

end

class Scrabble::Game

  attr_reader :p1

  def initialize(player1)
    @p1 = Scrabble::Player.new(player1)
  end

  def move
    while true
    print "Player 1 Tiles: #{p1.player_tiles}\nEnter a word with these tiles(type exit to quit):"
    word = gets.chomp
    if word == "exit"
      exit
    end
    word_score = p1.play(word)
    puts word_score
      if word_score == false
        puts "Wow, #{p1.name}! Your score is #{p1.total_score}! Looks like you won! :D"
        exit
      else
        puts "Your score is #{p1.total_score}!"
      end
    p1.update_player_tiles(word)
    end
  end

end

game = Scrabble::Game.new("Jeannie")
game.move
