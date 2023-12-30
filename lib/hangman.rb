# frozen_string_literal: true

def select_secret_word(words)
  word = words[rand(0..(words.length-1))]
  word.length > 4 && word.length < 13 ? word : select_secret_word(words)
end

def end_game
  # would change game stuff to false
end

# generate word bank
begin 
  word_bank = File.read('google-10000-english-no-swears.txt')
  word_bank = word_bank.split("\n")
rescue # returns empty if not found
  word_bank = []
  p 'The dictionary bank does not exist'
end

secret_word = select_secret_word(word_bank)
guess_count = 15
playing  = true
display_word = Array.new(secret_word.length, '_')

# draw game
while playing
  system('clear') || system('cls')
  puts secret_word
  puts "\nPlayer score: "
  puts "Guesses remaining: #{guess_count}\n\n"

  display_word.each { |i| print "#{i} " }
  puts "\n\n"

  # take user input
  guess = ''
  until ('a'..'z').include?(guess)
    print 'Guess a letter -> '
    guess = gets.chomp.downcase.chr
  end

  # check entry
  secret_word.split('').each_with_index do |val, i|
    display_word[i] = val if guess == val
  end

  # guess_count <= 0 ? playing = end_game : guess_count -= 1
  if guess_count <= 0
    puts 'You failed to guess correctly'
    playing = false
  elsif !display_word.include?('_')
    puts 'You guessed the word'
    playing = false
  else
    guess_count -= 1
  end
  # best if after guessing, it calls the display method
end
