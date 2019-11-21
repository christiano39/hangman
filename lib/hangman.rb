class Game
    attr_reader :secret_word, :guessed_letters, :number_of_guesses_remaining, :guessed_word
    
    def initialize
        @secret_word = select_good_word
        @guessed_word = secret_word_to_underscores(@secret_word)
        @guessed_letters = []
        @number_of_guesses_remaining = 12
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

    def start_game
        game_running = true
        @secret_word = select_good_word
        @guessed_word = secret_word_to_underscores(@secret_word)
        @guessed_letters = []
        @number_of_guesses_remaining = 8
        while game_running
            puts `clear`
            display_info
            
            user_guess = gets.chomp
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
                puts "Nice job! You guessed the word #{@secret_word}!"
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
            start_game
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
end

game = Game.new
game.start_game





