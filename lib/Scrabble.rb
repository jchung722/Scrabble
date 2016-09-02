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

  attr_reader :p1, :p2, :b1, :t1

  def initialize(player1, player2)
    @t1 = Scrabble::TileBag.new
    @p1 = Scrabble::Player.new(player1, @t1)
    @p2 = Scrabble::Player.new(player2, @t1)
    @b1 = Scrabble::Board.new(@p1, @p2)
  end

  def play_game
    word_score = true
    @first_turn = true
    turn = "player1"
    print display_board(b1.board_array[0][0], "0A", "right")

    until word_score == false # Check if a player has won

      if turn == "player1"
        word_score = move(p1)
        turn = "player2"
      elsif turn == "player2"
        word_score = move(p2)
        turn = "player1"
      end

    end

    puts "Wow, #{p1.name}! Your score is #{p1.total_score}! Looks like you won! :D"
    exit
  end

  def move(player)
    while true
      # Get a word
      print "
      \t\t*** #{player.name.upcase}'s Turn ***\n\n"
      print "Enter a word with your tiles(type Q to quit):"
      word = gets.chomp.upcase
      word2 = word

      # Exit if word is Q
      if word == "Q"
        exit
      end

      # Check if word contains only available letters
      test_input = true
      while test_input == true
        player.player_tiles.each do |letter|
          word2 = word2.sub(/[#{letter}]/, '')
        end
        if word2.length > 0
          print "You dont have those tiles... \nEnter another word (type Q to quit):"
          word = gets.chomp.upcase
          if word == "Q"
            exit
          end
          word2 = word
        else
          test_input = false
        end
      end

      # Check that word is in the dictionary
      until Scrabble::Dictionary.check_dictionary(word) == true
        print "That's not a real word...Enter a real word please (type Q to quit): "
        word = gets.chomp.upcase
        if word == "Q"
          exit
        end
      end

      # Get the start position of the word (default to center on first turn)
      if @first_turn == true
        start_position = "7H"
        @first_turn = false
        # Actually should check if spaces_covered includes 7H...
        # if not.. puts "Sorry, the first word must cover the center space (7H), try again: "
      else
        print "Enter the start position of your word (e.g 0A): "
        start_position = gets.chomp.upcase
      end

      # Get the dorection the word should be placed
      print "Do you want to place the word horizontally or vertically? (h/v): "
      direction = gets.chomp

      # add the word to the list of words played by the current player (returns false if someone won)
      word_score = player.play(word)
      player.update_player_tiles(word)

      # Display the score of the played word and Update the board
      puts "\n\n\n\n\"#{word}\" was #{word_score} points! "
      print display_board(word, start_position, direction)
      return word_score
    end
  end

  # Display the current board
  def display_board(word, start_position, direction)
    return b1.fill(word, start_position, direction)
  end

  def spaces_covered
    display_board
  end

end

class Scrabble::Dictionary
  def self.check_dictionary(word)
    valid_word = false
    IO.foreach("lib/Dictionary.txt") do |line|
      if word == line.strip.upcase
        return valid_word = true
      end
    end
    return valid_word
  end
end

class Scrabble::Board
  attr_reader :board_array, :p1, :p2
  def initialize(player1, player2)
    @board_array = Scrabble::BOARD_ARRAY.clone
    @p1 = player1
    @p2 = player2
  end

    def get_board
      p1_letters = p1.player_tiles
      p2_letters = p2.player_tiles
      p1_l1, p1_l2, p1_l3, p1_l4, p1_l5, p1_l6, p1_l7 = p1_letters
      p2_l1, p2_l2, p2_l3, p2_l4, p2_l5, p2_l6, p2_l7 = p2_letters

      board = "\n\n\n\n\n\n
        ██████  ▄████▄   ██▀███   ▄▄▄       ▄▄▄▄    ▄▄▄▄    ██▓    ▓█████
      ▒██    ▒ ▒██▀ ▀█  ▓██ ▒ ██▒▒████▄    ▓█████▄ ▓█████▄ ▓██▒    ▓█   ▀
      ░ ▓██▄   ▒▓█    ▄ ▓██ ░▄█ ▒▒██  ▀█▄  ▒██▒ ▄██▒██▒ ▄██▒██░    ▒███
        ▒   ██▒▒▓▓▄ ▄██▒▒██▀▀█▄  ░██▄▄▄▄██ ▒██░█▀  ▒██░█▀  ▒██░    ▒▓█  ▄
      ▒██████▒▒▒ ▓███▀ ░░██▓ ▒██▒ ▓█   ▓██▒░▓█  ▀█▓░▓█  ▀█▓░██████▒░▒████▒
      ▒ ▒▓▒ ▒ ░░ ░▒ ▒  ░░ ▒▓ ░▒▓░ ▒▒   ▓▒█░░▒▓███▀▒░▒▓███▀▒░ ▒░▓  ░░░ ▒░ ░
      ░ ░▒  ░ ░  ░  ▒     ░▒ ░ ▒░  ▒   ▒▒ ░▒░▒   ░ ▒░▒   ░ ░ ░ ▒  ░ ░ ░  ░
      ░  ░  ░  ░          ░░   ░   ░   ▒    ░    ░  ░    ░   ░ ░      ░
            ░  ░ ░         ░           ░  ░ ░       ░          ░  ░   ░  ░
               ░                                 ░       ░
                                                                      \n
      \t   a b c d e f g h i j k l m n o
      \t   -----------------------------
      \t 0|#{board_array[0][0]} #{board_array[0][1]} #{board_array[0][2]} #{board_array[0][3]} #{board_array[0][4]} #{board_array[0][5]} #{board_array[0][6]} #{board_array[0][7]} #{board_array[0][8]} #{board_array[0][9]} #{board_array[0][10]} #{board_array[0][11]} #{board_array[0][12]} #{board_array[0][13]} #{board_array[0][14]}|0        #{p1.name}'s
      \t 1|#{board_array[1][0]} #{board_array[1][1]} #{board_array[1][2]} #{board_array[1][3]} #{board_array[1][4]} #{board_array[1][5]} #{board_array[1][6]} #{board_array[1][7]} #{board_array[1][8]} #{board_array[1][9]} #{board_array[1][10]} #{board_array[1][11]} #{board_array[1][12]} #{board_array[1][13]} #{board_array[1][14]}|1         TILES:
      \t 2|#{board_array[2][0]} #{board_array[2][1]} #{board_array[2][2]} #{board_array[2][3]} #{board_array[2][4]} #{board_array[2][5]} #{board_array[2][6]} #{board_array[2][7]} #{board_array[2][8]} #{board_array[2][9]} #{board_array[2][10]} #{board_array[2][11]} #{board_array[2][12]} #{board_array[2][13]} #{board_array[2][14]}|2    |---------------|
      \t 3|#{board_array[3][0]} #{board_array[3][1]} #{board_array[3][2]} #{board_array[3][3]} #{board_array[3][4]} #{board_array[3][5]} #{board_array[3][6]} #{board_array[3][7]} #{board_array[3][8]} #{board_array[3][9]} #{board_array[3][10]} #{board_array[3][11]} #{board_array[3][12]} #{board_array[3][13]} #{board_array[3][14]}|3    | #{p1_l1} #{p1_l2} #{p1_l3} #{p1_l4} #{p1_l5} #{p1_l6} #{p1_l7} |
      \t 4|#{board_array[4][0]} #{board_array[4][1]} #{board_array[4][2]} #{board_array[4][3]} #{board_array[4][4]} #{board_array[4][5]} #{board_array[4][6]} #{board_array[4][7]} #{board_array[4][8]} #{board_array[4][9]} #{board_array[4][10]} #{board_array[4][11]} #{board_array[4][12]} #{board_array[4][13]} #{board_array[4][14]}|4    |===============|
      \t 5|#{board_array[5][0]} #{board_array[5][1]} #{board_array[5][2]} #{board_array[5][3]} #{board_array[5][4]} #{board_array[5][5]} #{board_array[5][6]} #{board_array[5][7]} #{board_array[5][8]} #{board_array[5][9]} #{board_array[5][10]} #{board_array[5][11]} #{board_array[5][12]} #{board_array[5][13]} #{board_array[5][14]}|5
      \t 6|#{board_array[6][0]} #{board_array[6][1]} #{board_array[6][2]} #{board_array[6][3]} #{board_array[6][4]} #{board_array[6][5]} #{board_array[6][6]} #{board_array[6][7]} #{board_array[6][8]} #{board_array[6][9]} #{board_array[6][10]} #{board_array[6][11]} #{board_array[6][12]} #{board_array[6][13]} #{board_array[6][14]}|6        #{p2.name}'s
      \t 7|#{board_array[7][0]} #{board_array[7][1]} #{board_array[7][2]} #{board_array[7][3]} #{board_array[7][4]} #{board_array[7][5]} #{board_array[7][6]} #{board_array[7][7]} #{board_array[7][8]} #{board_array[7][9]} #{board_array[7][10]} #{board_array[7][11]} #{board_array[7][12]} #{board_array[7][13]} #{board_array[7][14]}|7         TILES:
      \t 8|#{board_array[8][0]} #{board_array[8][1]} #{board_array[8][2]} #{board_array[8][3]} #{board_array[8][4]} #{board_array[8][5]} #{board_array[8][6]} #{board_array[8][7]} #{board_array[8][8]} #{board_array[8][9]} #{board_array[8][10]} #{board_array[8][11]} #{board_array[8][12]} #{board_array[8][13]} #{board_array[8][14]}|8    |---------------|
      \t 9|#{board_array[9][0]} #{board_array[9][1]} #{board_array[9][2]} #{board_array[9][3]} #{board_array[9][4]} #{board_array[9][5]} #{board_array[9][6]} #{board_array[9][7]} #{board_array[9][8]} #{board_array[9][9]} #{board_array[9][10]} #{board_array[9][11]} #{board_array[9][12]} #{board_array[9][13]} #{board_array[9][14]}|9    | #{p2_l1} #{p2_l2} #{p2_l3} #{p2_l4} #{p2_l5} #{p2_l6} #{p2_l7} |
      \t10|#{board_array[10][0]} #{board_array[10][1]} #{board_array[10][2]} #{board_array[10][3]} #{board_array[10][4]} #{board_array[10][5]} #{board_array[10][6]} #{board_array[10][7]} #{board_array[10][8]} #{board_array[10][9]} #{board_array[10][10]} #{board_array[10][11]} #{board_array[10][12]} #{board_array[10][13]} #{board_array[10][14]}|10   |===============|
      \t11|#{board_array[11][0]} #{board_array[11][1]} #{board_array[11][2]} #{board_array[11][3]} #{board_array[11][4]} #{board_array[11][5]} #{board_array[11][6]} #{board_array[11][7]} #{board_array[11][8]} #{board_array[11][9]} #{board_array[11][10]} #{board_array[11][11]} #{board_array[11][12]} #{board_array[11][13]} #{board_array[11][14]}|11
      \t12|#{board_array[12][0]} #{board_array[12][1]} #{board_array[12][2]} #{board_array[12][3]} #{board_array[12][4]} #{board_array[12][5]} #{board_array[12][6]} #{board_array[12][7]} #{board_array[12][8]} #{board_array[12][9]} #{board_array[12][10]} #{board_array[12][11]} #{board_array[12][12]} #{board_array[12][13]} #{board_array[12][14]}|12
      \t13|#{board_array[13][0]} #{board_array[13][1]} #{board_array[13][2]} #{board_array[13][3]} #{board_array[13][4]} #{board_array[13][5]} #{board_array[13][6]} #{board_array[13][7]} #{board_array[13][8]} #{board_array[13][9]} #{board_array[13][10]} #{board_array[13][11]} #{board_array[13][12]} #{board_array[13][13]} #{board_array[13][14]}|13        Scores
      \t14|#{board_array[14][0]} #{board_array[14][1]} #{board_array[14][2]} #{board_array[14][3]} #{board_array[14][4]} #{board_array[14][5]} #{board_array[14][6]} #{board_array[14][7]} #{board_array[14][8]} #{board_array[14][9]} #{board_array[14][10]} #{board_array[14][11]} #{board_array[14][12]} #{board_array[14][13]} #{board_array[14][14]}|14    --------------
      \t   -----------------------------        #{p1.name}: #{p1.total_score}
      \t   a b c d e f g h i j k l m n o        #{p2.name}: #{p2.total_score}\n\n"

      return board
    end

    # Get input word, position, and diection in the proper formats
    def clean_up_input(word, start_position, direction)
      if start_position.length > 2
        letter = start_position[2]
      else
        letter = start_position[1]
      end
      case letter #start_position[1]
      when "A"
        start_position.gsub!("A", "0")
      when "B"
        start_position.gsub!("B", "1")
      when "C"
        start_position.gsub!("C", "2")
      when "D"
        start_position.gsub!("D", "3")
      when "E"
        start_position.gsub!("E", "4")
      when "F"
        start_position.gsub!("F", "5")
      when "G"
        start_position.gsub!("G", "6")
      when "H"
        start_position.gsub!("H", "7")
      when "I"
        start_position.gsub!("I", "8")
      when "J"
        start_position.gsub!("J", "9")
      when "K"
        start_position.gsub!("K", "10")
      when "L"
        start_position.gsub!("L", "11")
      when "M"
        start_position.gsub!("M", "12")
      when "N"
        start_position.gsub!("N", "13")
      when "O"
        start_position.gsub!("O", "14")
      end

      position = start_position.split("").map(&:to_i) # Split the position into an integer array
      if position.length == 3
        v = position[0,2].join.to_i
        h = position[2]
      elsif position.length == 4
          v = position[0,2].join.to_i
          h = position[2,2].join.to_i
      elsif position.length == 2
        v = position[0]
        h = position[1]
      end

      word = word.upcase #changes all letters to uppercase
      direction = direction.downcase

      return [word, v, h]
    end

    # Place the word in the board array variable in the correct place/orientation
    def fill(word, start_position, direction)

      word, v, h = clean_up_input(word, start_position, direction)
      ap start_position
      ap direction
      ap v
      ap h
      letters = word.split(//)

      letters.each do |letter|
        board_array[v][h] = letter
        case direction
        when "v"
          v += 1
        when "h"
          h += 1
        end
      end
      board = get_board
      return board
    end

    # Get the positions and contents of all the spaces that the word is going to cover
    # def check_coverage(word, start_position, direction)
    #   word, start_position, v, h = clean_up_input(word, start_position, direction)
    #
    #   letters = word.split(//)
    #   letter_locations =
    #
    #   (letters.length).times do |i|
    #     letter_locations[i] = start_position
    #     case direction
    #     when "v"
    #       v += 1
    #     when "h"
    #       h += 1
    #     end
    #   end
    #
    #   location_contents =
    #
    # end
end

game = Scrabble::Game.new("Jeannie", "Jessica")
game.play_game

# t = Scrabble::Board.new
# print t.fill("Hello", "0A", "down")
# print t.fill("hill", "0A", "right")
