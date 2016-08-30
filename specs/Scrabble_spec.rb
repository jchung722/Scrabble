#Scrabble_spec.rb

require_relative 'Spec_helper'
require_relative '../lib/Scrabble'

describe 'Testing Scrabble' do

  it "Must return total score for given word" do
    expect(Scrabble::Scoring.score("art")).must_equal(3)
    expect(Scrabble::Scoring.score("quit")).must_equal(13)
  end

  it "Must return total score including bonus for seven letter word" do
    expect(Scrabble::Scoring.score("racecar")).must_equal(61)
  end

  it "Must return word with highest score from array of words" do
    expect(Scrabble::Scoring.highest_score_from(["art","quiz","racecar"])).must_equal("RACECAR")
    expect(Scrabble::Scoring.highest_score_from(["jacuzzi","jazzmen","jazzman"])).must_equal("JACUZZI")
  end

  it "In a tie, must return word with fewer letters" do
    expect(Scrabble::Scoring.highest_score_from(["goal", "roast"])).must_equal("GOAL")
  end

  it "In a tie, must return word that used seven letters" do
    expect(Scrabble::Scoring.highest_score_from(["qzqzqj", "aeiould"])).must_equal("AEIOULD")
  end

  it "In a tie, with same length words, must return first word in list" do
    expect(Scrabble::Scoring.highest_score_from(["pole", "same"])).must_equal("POLE")
  end

end
