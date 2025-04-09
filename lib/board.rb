# frozen-string-literal: true

require 'json'

# Holds the board, and board methods
class Board
  def initialize
    @board = { 8 => ["\u265c ", "\u265e ", "\u265d ", "\u265b ", "\u265a ", "\u265d ", "\u265e ", "\u265c "],
               7 => ["\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f "],
               6 => ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
               5 => ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
               4 => ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
               3 => ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
               2 => ["\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 "],
               1 => ["\u2656 ", "\u2658 ", "\u2657 ", "\u2655 ", "\u2654 ", "\u2657 ", "\u2658 ", "\u2656 "] }
    @num_to_col = { 1 => 'a', 2 => 'b', 3 => 'c', 4 => 'd', 5 => 'e', 6 => 'f', 7 => 'g', 8 => 'h' }
    @col_to_num = { 'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8 }
  end

  def display_board
    puts '    A   |  B   |  C   |  D   |  E   |  F   |  G   |  H   '
    @board.each do |k, v|
      puts " #{k}: #{v.join('  |  ')}"
    end
  end

  def update_board(current_turn, next_turn)
    @board.each_key do |k|
      @board[k] = ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ']
    end
    update_board_row(current_turn)
    update_board_row(next_turn)
  end

  def update_board_row(player)
    player.pieces.pieces.each_value do |v|
      next if v[:position].nil?

      @board[v[:position][1]][(@col_to_num[v[:position][0]]) - 1] = (v[:icon]).to_s
    end
  end

  def save_game(player1, player2, current_turn)
    state = { player1: player1, player2: player2, current_turn: current_turn }
    save_file = save_file_check

    File.open(save_file, 'w') do |json|
      json << state.to_json
    end
    puts 'Game saved!'
  end

  def save_file_check
    File.write('../save_game.json', '') unless File.exist?('../save_game.json')
    File.open('../save_game.json')
  end

  def load_save_file(player1, player2)
    save_file = File.open('../save_game.json')
    json = save_file.readline
    state = JSON.parse(json, { symbolize_names: true })
    puts "-----\n\nGame loaded!"
    player1.pieces.pieces = state[:player1]
    player2.pieces.pieces = state[:player2]
    return player1 if state[:current_turn] == 'white' # game will #swap_turn to set turn variables

    player2 if state[:current_turn] == 'black'
  end

  def load?(player1, player2)
    return player1 unless File.exist?('../save_game.json')

    puts "Save game found. Do you want to load your game?\nStarting a new game will delete this save."
    loop do
      puts "Load game?\nY/N?"
      load = gets.chomp
      return load_save_file(player1, player2) if load.match?(/y/i)
      return player1 if load.match?(/n/i)

      puts 'Invalid entry.'
    end
  end
end
