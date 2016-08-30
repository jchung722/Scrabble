#Scrabble.rb

require_relative '../Scrabble/'
require 'awesome_print'
class Scrabble::Scoring


  def self.score(word)
    word.upcase!
    letters = word.split(//)
    score = 0
    letters.each do |letter|
      a = Scrabble::LETTER_VALUES.detect{ |k, v| k.include?(letter)}
      score += a[1]
    end

    if letters.length == 7
      score += 50
    end

    return score

  end

  def self.highest_score_from(word_options)

    scores = []
    word_options.each do |word|
      scores << score(word)
    end
    #i = scores.index(scores.max)
    max_val = scores.max
    index_array = scores.each_index.select{|i| scores[i] == max_val}

    high_score_words = word_options.values_at(*index_array)

    if high_score_words.max_by(&:length).length == 7 # (&:length) is a shortcut of the iteration {|i| i.length}
      return high_score_words.max_by(&:length)
    else
      return high_score_words.min_by(&:length)
    end

  end

end

# ap Scrabble::Scoring.highest_score_from(["qzqzqj", "aeiould"])
# ap Scrabble::Scoring.score("aeiould")
ap Scrabble::Scoring.score("qzqzqj")
