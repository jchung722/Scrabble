#Scrabble_spec.rb

require_relative 'Spec_helper'
require_relative '../lib/Scrabble'


describe 'Testing Scrabble' do

  ##########------------------- Wave 1 ------------------------##########

  it "Must return total score for given word" do
    expect(Scrabble::Scoring.score("art")).must_equal(3)
    expect(Scrabble::Scoring.score("quit")).must_equal(13)
  end

  it "Must return total score including bonus for seven letter word" do
    expect(Scrabble::Scoring.score("racecar")).must_equal(61)
  end

  it "Must return word with highest score from array of words" do
    expect(Scrabble::Scoring.highest_score_from(["art","quiz","racecar"])).must_equal("racecar")
    expect(Scrabble::Scoring.highest_score_from(["jacuzzi","jazzmen","jazzman"])).must_equal("jacuzzi")
  end

  it "In a tie, must return word with fewer letters" do
    expect(Scrabble::Scoring.highest_score_from(["goal", "roast"])).must_equal("goal")
  end

  it "In a tie, must return word that used seven letters" do
    expect(Scrabble::Scoring.highest_score_from(["qzqzqj", "aeiould"])).must_equal("aeiould")
  end

  it "In a tie, with same length words, must return first word in list" do
    expect(Scrabble::Scoring.highest_score_from(["pole", "same"])).must_equal("pole")
  end

  ##########-------------------- Wave 2 ------------------------##########

  it "Must return the name of a player" do
    expect(Scrabble::Player.new("Jessica").name).must_equal("Jessica")
  end

  it "Must return the input words " do
    p1 = Scrabble::Player.new("Jessica")
    p1.play("test")
    expect(p1.plays).must_equal(["TEST"])
  end

  it "Must return an Array of input words " do
    expect(Scrabble::Player.new("").plays).must_be_instance_of Array
  end

  it "Must return the score of the played word" do
    expect(Scrabble::Player.new("").play("test")).must_equal(4)
  end

  it "Must return the total score of all words played by a player" do
    p1 = Scrabble::Player.new("Jessica")
    p1.play("test")
    p1.play("newWord")
    expect(p1.total_score).must_equal(68)
  end

  it "Must true if the player already won for won? and return false if they try to enter a new word" do
    p1 = Scrabble::Player.new("Jessica")
    p1.play("newWord")
    p1.play("newWord")
    expect(p1.won?).must_equal(true)
    expect(p1.play("anything")).must_equal(false)
  end

  it "Must return highest scoring played word / highest score" do
    p1 = Scrabble::Player.new("Jessica")
    p1.play("test")
    p1.play("newWord")
    expect(p1.highest_scoring_word).must_equal("NEWWORD")
    expect(p1.highest_word_score).must_equal(64)
  end

  it "Must give an argument error for a word that is not all A-Z letters" do
    p1 = Scrabble::Player.new("Jessica")
    expect( proc {p1.play("test@")}).must_raise ArgumentError
  end

  it "Must true if the player already won for won? and return false if the total score is < 100" do
    p1 = Scrabble::Player.new("Jessica")
    p1.play("newWord")
    expect(p1.won?).must_equal(false)
  end

  ##########-------------------- Wave 3 ------------------------##########

  it "Must set up an instance with a collection of default tiles" do
    expect(Scrabble::TileBag.new).must_be_instance_of Scrabble::TileBag
    expect(Scrabble::TileBag.new.tiles).must_be_instance_of Hash
  end

  it "Must return the number of drawn tiles as an array of strings" do
    t1 = Scrabble::TileBag.new
    expect(t1.draw_tiles(3)).must_be_instance_of Array
    expect(t1.draw_tiles(3).length).must_equal(3)
  end

  it "Must return that there are no tiles left if we draw 98 tiles" do
    t2 = Scrabble::TileBag.new
    t2.draw_tiles(98)
    expect(t2.tiles.values.inject(:+)).must_equal(nil)
  end

  it "Must return number of tiles remaining in bag" do
    t1 = Scrabble::TileBag.new
    expect(t1.tiles_remaining).must_equal(98)
  end

  ##########---------------------- Wave 3 P2 ----------------------#########

  it "Must initialize a collection of tile letters that the player can use" do
    p1 = Scrabble::Player.new("Jessica")
    expect(p1.player_tiles).must_be_instance_of Array
    expect(p1.player_tiles.length).must_equal(7)
  end

  it "Must always keep player tiles at 7" do
    p1 = Scrabble::Player.new("Jeannie")
    p1.play("art")
    expect(p1.player_tiles.length).must_equal(7)
  end

  ###########------------- Optional Enhancement Dictionary -------------####

  it "Must search a list of words to determine if user's word is valid or invalid" do
    expect(Scrabble::Dictionary.check_dictionary("WORD")).must_equal(true)
    expect(Scrabble::Dictionary.check_dictionary("THIS")).must_equal(true)
    expect(Scrabble::Dictionary.check_dictionary("WORKS")).must_equal(true)
    expect(Scrabble::Dictionary.check_dictionary("BLAHBLAH")).must_equal(false)
    expect(Scrabble::Dictionary.check_dictionary("ALKJDFHKEWJHFWE")).must_equal(false)
  end

  ###########------------- Optional Enhancement Game Class ------------######

  # it "Must initialize a new game with a new player with a given name" do
  #   game = Scrabble::Game.new("Jeannie")
  #   expect(game.p1.name).must_equal("Jeannie")
  # end

end
