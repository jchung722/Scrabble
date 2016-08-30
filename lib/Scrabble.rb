#Scrabble.rb

#test2
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

    word.upcase! #changes all letters to uppercase

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

# ap Scrabble::Scoring.highest_score_from(["qzqzqj", "aeiould"])
# ap Scrabble::Scoring.score("aeiould")
# ap Scrabble::Scoring.score("2qzqzqj")
