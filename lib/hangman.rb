# frozen_string_literal: true

#hamgman game class. handles everything in this program
class Hangman
  def initialize(name)
    @name = name
    @score = 0
    @guess_count = 10
    @playing = true

    create_dictionary
  end

  def play
    ready =''
    until ready == 'y' || ready == 'n'
      print "Welcome to Hang-man #{@name}, start game (y,n)? > "
      ready = gets.chomp.downcase.chr
    end
    ready == 'y' ? @playing = true : @playing = false 
    while @playing
      play_round
    end
    p 'Thanks for trying, see you again...'
  end

  private

  def select_secret_word(words)
    word = words[rand(0..(words.length-1))]
    word.length > 4 && word.length < 13 ? word : select_secret_word(words)
  end

  def guess_chr
    guess = ''
    unless ('a'..'z').include?(guess)
      print 'Guess a letter -> '
      gets.chomp.downcase.chr
    end
  end

  def create_dictionary
    begin 
      @word_bank = File.read('google-10000-english-no-swears.txt').split("\n")
    rescue # returns empty if not found
      @word_bank = Arrya.new(1, 'empty')
      p 'The dictionary file does not exist'
    end
  end

  def draw_game
    system('clear') || system('cls')
    puts "\nPlayer score: #{score} "
    puts "Guesses remaining: #{@guess_count}\n\n"

    @display_word.each { |i| print "#{i} " }
    puts "\n\n"
  end

  def play_round
    secret_word = select_secret_word(@word_bank)
    @display_word = Array.new(secret_word.length, '_')
    playing_round = true
    guess = ''
    draw_game

    while playing_round
      guess = guess_chr
      switched = false

      secret_word.split('').each_with_index do |val, i|
        if guess == val && !switched && @display_word[i] == '_'
          @display_word[i] = val
          @guess_count += 1
          switched = true 
        end
      end
      @guess_count -= 1

      puts "word: #{@display_word}"

      draw_game

      if @guess_count <= 0
        playing_round = false
        puts 'Out of guesses, you failed to guess the word'
      elsif !@display_word.include?('_')
        playing_round = false
        @score += 1
        puts "You guessed the word with #{@guess_count}guesses left"
      end

    end
    print "\nDo you want to play another round(y,n)? > "
    reply = gets.chomp.downcase.chr
    if reply == 'y'
      @guess_count = 10
    else
      @playing = false
    end
  end
end

print 'Hi, enter your name > '
name = gets.chomp
hm = Hangman.new(name)
hm.play
