# The function `lower_case` takes an array of strings and converts
# any non-lower case alphabet (A..Z) to corresponding lower case
# alphabet
def lower_case(words)
  return words.map {|word| word.downcase}
end

# Similar to `lower_case`, this function modifies the array in-place
# and does not return any value.
def lower_case!(words)
  for i in 0..words.size-1
    words[i].downcase!
  end
  return  words
end

# Given a prefix and an array of words, return an array containing
# words that have same prefix.
#
# For example:
# words_with_prefix('apple', ['apple', 'ball', 'applesauce']) would
# return the words 'apple' and 'applesauce'.
def words_with_prefix(prefix, words)
  words.select {|word| word.start_with?(prefix)}
end

# The similarity score between two words is defined as the length of
# largest common prefix between the words.
#
# For example:
# - Similarity of (bike, bite) is 2 as 'bi' is the largest common prefix.
# - Similarity of (apple, bite) is 0 as there are no common letters in
#   the prefix
# - similarity of (applesauce, apple) is 5 as 'apple' is the largest
#   common prefix.
# 
# The function `similarity_score` takes two words and returns the
# similarity score (an integer).
def similarity_score(word_1, word_2)
  i = 0;
  while i<word_1.size && i<word_2.size && word_1[i]==word_2[i]
    i+=1
  end
  return i
end

# Given a chosen word and an array of words, return an array of word(s)
# with the maximum similarity score in the order they appear.
def most_similar_words(chosen_word, words)
  res = []
  maxScore = 0
  words.each do |word|
    ss = similarity_score(chosen_word,word)
    if ss > maxScore
      res.clear()
      res.push(word)
      maxScore = ss
    elsif ss == maxScore
           res.push(word)
    end
  end
  return res
end
