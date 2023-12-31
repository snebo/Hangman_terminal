# Find more by snebo -> https://github.com/snebo/
# freeze_string_literal: true

require 'json'

# Create and manage the hangman game
class Hangman
  attr_writer :name, :score, :guess_count, :secret_word, :display_word, :guessed_letters,
              :playing

  def initialize
    @name = ''
    @score = 0
    @guess_count = 12
    @secret_word = ''
    @display_word = ''
    @guessed_letters = []
    @playing = true
    @loaded = false
    create_dictionary
  end

  def create_dictionary
    @wordbank = File.read('google-10000-english-no-swears.txt').split("\n")
  rescue StandardError
    @wordbank = Array.new(1, 'empty')
    puts 'Error: File not found'
  end

  def choose_secret_word(dict)
    word = dict[rand(0..dict.length - 1)]
    # making sure the words used are 5-12 letters long
    word.length > 4 && word.length < 13 ? word.downcase : choose_secret_word(dict)
  end

  def play_hangman
    puts 'Welcome to Hangman!'
    print 'would you like to load a save? (y/n) -> '
    answer = gets.chomp
    if answer == 'y'
      load_game
    else
      print 'Enter your name ->'
      answer = gets.chomp
      @name = answer
    end
    play_round while @playing
    puts 'Thanks for playing!'
  end

  def get_guess
    guess = ''
    unless ('a'..'z').include?(guess)
      print 'Guess a letter -> '
      guess = gets.chomp.downcase
    end
    if guess == 'save'
      save_game # save game
      '!'
    else
      guess
    end
  end

  def check_guess(letter)
    switched = false
    found = true
    @secret_word.split('').each_with_index do |char, index|
      if letter == char && !switched && @display_word[index] == '_'
        @display_word[index] = char
        switched = true
        @guess_count += 1
      else
        found = false
      end
    end
    if !found && !switched && letter != 'save' && !@guessed_letters.include?(letter)
      @guessed_letters << letter 
    end
  end

  def save_game
    info = JSON.dump({
                       name: @name,
                       score: @score,
                       guess_count: @guess_count,
                       secret_word: @secret_word,
                       display_word: @display_word,
                       guessed_letters: @guessed_letters,
                       playing: @playing
                     })

    Dir.mkdir('Save_files') unless Dir.exist?('Save_files')
    File.open("./Save_files/#{@name}.json", 'w') do |f|
      f.puts info
    end
  end

  def load_game
    list = Dir['Save_files/*']
    list.each { |i| i.gsub!('.json', '').gsub!('Save_files/', '') }
    puts list

    print "\nEnter the name of your save -> "
    name = gets.chomp
    if File.exist?("Save_files/#{name}.json")
      save = File.read("Save_files/#{name}.json")

      info = JSON.parse(save)
      @name = info['name']
      @score = info['score']
      @guess_count = info['guess_count']
      @secret_word = info['secret_word']
      @display_word = info['display_word']
      @guessed_letters = info['guessed_letters']
      @playing = info['playing']
      @loaded = true

      puts "Welcome back #{@name}!"
    end
  end

  def draw_board
    spaces = ' ' * 20
    system('clear') || system('clc')
    puts 'Hangman game'
    puts '--------------------------------'
    puts "type 'save' to save the game"
    puts "Player: #{@name}\nScore: #{@score}" + spaces + "Guesses left: #{@guess_count}"
    print "wrong guesses: #{@guessed_letters}\n\n"
    @display_word.each { |i| print "#{i} " }
    puts "\n\n"
  end

  def round_over?
    if @guess_count == 0
      puts "out of guesses! The word was #{@secret_word}"
      @guess_count = 12
      false
    elsif !@display_word.include?('_')
      @score += 1
      puts "You Guessed the word with #{@guess_count} guesses left!"
      @guess_count = 12
      false
    else
      true
    end
  end

  def play_round
    # prevent the displayed word and guessed letter from resetting if game is loaded
    if @loaded
      @loaded = false
    else
      @guessed_letters = []
      @secret_word = choose_secret_word(@wordbank)
      @display_word = Array.new(@secret_word.length, '_')
    end
    # @secret_word = choose_secret_word(@wordbank)
    # @display_word = Array.new(@secret_word.length, '_')
    # @guessed_letters = []
    playing_round = true

    draw_board
    while playing_round
      guess = get_guess
      check_guess(guess)
      @guess_count -= 1

      draw_board
      playing_round = round_over?
    end
    puts 'Would you like to play again? (y/n)'
    answer = gets.chomp.downcase.chr
    @playing = false if answer == 'n'
  end
end

hm = Hangman.new
hm.play_hangman
