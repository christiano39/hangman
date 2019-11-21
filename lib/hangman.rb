require 'yaml'
class Game
    attr_accessor :secret_word, :guessed_letters, :number_of_guesses_remaining, :guessed_word
    @@save_number = 1

    def initialize
        @secret_word = select_good_word
        @guessed_word = secret_word_to_underscores(@secret_word)
        @guessed_letters = []
        @number_of_guesses_remaining = 8
    end

    def display_info
        puts @guessed_word.join(" ")
        puts "Letters already guessed: #{guessed_letters.join(", ")}"
        puts "Incorrect guesses remaining: #{number_of_guesses_remaining}"
        puts "Next guess: "
    end

    def is_match?(word, char)
        if word.include? char
            true
        else
            false
        end
    end

    def get_indices(word, char)
        word = word.split("")
        indices = word.each_index.select{|i| word[i] == char}
    end

    def start_game()
        game_running = true
        
        while game_running
            puts `clear`
            display_info
            
            user_guess = gets.chomp.downcase
            if user_guess == 'save'
                save
            end
            while user_guess.length != 1
                puts "Please choose a letter"
                user_guess = gets.chomp
            end

            if is_match?(@secret_word, user_guess)
                indices = get_indices(@secret_word, user_guess)
                indices.each do |i|
                    @guessed_word[i] = user_guess
                end
            else
                unless @guessed_letters.include? user_guess
                    @guessed_letters.push(user_guess)
                    @number_of_guesses_remaining -= 1
                end
            end

            if !@guessed_word.include? '_'
                puts `clear`
                puts @guessed_word.join(" ")
                puts "Nice job! You guessed the word #{@secret_word}"
                game_running = false
                play_again
            end

            if @number_of_guesses_remaining == 0
                puts "Darn! Out of guesses. The secret word was #{@secret_word}"
                game_running = false
                play_again
            end
            
        end
    end

    def play_again
        puts "Play again? y/n"
        input = gets.chomp.downcase
        while input != 'y' && input != 'n'
            puts "Please type 'y' for yes or 'n' for no"
            input = gets.chomp.downcase
        end
        if input == 'y'
            g = Game.new
            g.start_game
        end
    end

    def save()
        set_savegame_number
        dump = YAML::dump({:word => @secret_word, :guessed_word => @guessed_word, :guessed_letters => @guessed_letters, :remaining => @number_of_guesses_remaining})
        filename = "saves/savegame_#{@@save_number}"
        File.open(filename, 'w') do |f|
            f << dump
        end
        puts "savegame_#{@@save_number} saved!"
        @@save_number += 1
    end

    def load(filename)
        dump = File.read(filename)
        puts dump
        game = YAML::load(dump)
        g = Game.new
        g.secret_word = game[:word]
        g.guessed_word = game[:guessed_word]
        g.guessed_letters = game[:guessed_letters]
        g.number_of_guesses_remaining = game[:remaining]
        return g
    end

    def ask_for_load
        saves = Dir.entries("saves")
        saves = saves.select { |save| save.include? "savegame"}
        saves = saves.sort
        unless saves.empty?
            puts "Would you like to load a previously saved game? y/n"
            input = gets.chomp.downcase
            while input != 'y' && input != 'n'
                puts "Please type 'y' for yes or 'n' for no"
                input = gets.chomp.downcase
            end
            if input == 'y'
                puts saves
                puts "Please type the name of the save you would like to load"
                save = gets.chomp.downcase
                unless saves.include? save
                    puts "Error: savegame not found"
                    save = gets.chomp.downcase
                end
                filename = "saves/#{save}"
                load(filename)
            else
                return Game.new
            end
        end
    end

    private
    def select_random_word
        dictionary = File.readlines("dictionary.txt")
        random_index = get_new_random_number
        begin
            dictionary[random_index].to_s.gsub!(/\r/,"").gsub!(/\n/,"").trim
        rescue
            dictionary[random_index].to_s
        end
    
    end
    
    def select_good_word
        word = select_random_word
        unless word.length > 5 && word.length <= 12
            word = select_random_word
        end
        word.downcase
    end
    
    def get_new_random_number
        rand(61406)
    end

    def secret_word_to_underscores(secret_word)
        length = secret_word.length - 1
        new_word = "".rjust(length * 2, "_ ")
        new_word = new_word.split(" ")
    end

    def set_savegame_number
        saves = Dir.entries("saves")
        saves = saves.select{ |save| save.include? "savegame" }
        saves = saves.sort
        if saves.empty?
            @@save_number = 1
        else
            last_number = saves[-1][-1]
            @@save_number = last_number.to_i + 1
        end
    end
end

game = Game.new
game = game.ask_for_load
if game.nil?
    game = Game.new
end
game.start_game







