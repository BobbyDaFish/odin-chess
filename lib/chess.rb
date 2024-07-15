# frozen-string-literal: true

require_relative 'pieces'
require_relative 'player'
require_relative 'moves'
require 'pry-byebug'

# Hold methods for game logic like updating and displaying board, accepting player input for moves
# and determining check/mate
class Chess
  attr_accessor :current_turn, :next_turn

  def initialize # rubocop:disable Metrics/MethodLength
    @board = { 8 => ["\u265c ", "\u265e ", "\u265d ", "\u265b ", "\u265a ", "\u265d ", "\u265e ", "\u265c "],
               7 => ["\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f "],
               6 => ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
               5 => ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
               4 => ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
               3 => ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
               2 => ["\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 "],
               1 => ["\u2656 ", "\u2658 ", "\u2657 ", "\u2655 ", "\u2654 ", "\u2657 ", "\u2658 ", "\u2656 "] }
    @player1 = Player.new(1)
    @player2 = Player.new(2)
    @current_turn = @player2
    @next_turn = @player1
    @num_to_col = { 1 => 'a', 2 => 'b', 3 => 'c', 4 => 'd', 5 => 'e', 6 => 'f', 7 => 'g', 8 => 'h' }
    @col_to_num = { 'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8 }
    @movement = Moves.new
  end

  def display_board
    puts '    A   |  B   |  C   |  D   |  E   |  F   |  G   |  H   '
    @board.each do |k, v|
      puts " #{k}: #{v.join('  |  ')}"
    end
  end

  def choose_piece
    loop do
      piece = []
      puts "Select a #{@current_turn.side} piece!\nPick a column from A to H"
      piece << gets.chomp
      puts 'Choose a row from 1 to 8'
      piece << gets.chomp.to_i
      @current_turn.pieces.pieces.select { |_k, v| return piece if piece == v[:position] }
      puts 'Invalid selection!'
    end
  end

  def choose_move(piece_coords)
    move = []
    puts "Where are you moving?\nPick a column from A to H"
    move[0] = gets.chomp
    puts 'Choose a row from 1 to 8'
    move[1] = gets.chomp.to_i
    return move if @movement.possible_moves(@current_turn, piece_coords, @next_turn).any?(move)

    puts 'Invalid move, select a piece and try again.'
    false
  end

  # sets the new piece coords, then calls method to find and resolve any piece takes
  def process_move(piece, move)
    @current_turn.pieces.pieces.each_value do |v|
      if v[:position] == piece
        v[:position] = move
        return resolve_takes(v)
      end
    end
  end

  # checks if current players pieces share position coordinates with next players piece.
  # If so, set next player's piece position to [] to remove from board
  def resolve_takes(piece)
    @next_turn.pieces.pieces.each_value do |opp_piece|
      if piece[:position] == opp_piece[:position]
        opp_piece[:position] = nil
        return opp_piece
      end
    end
    []
  end

  def update_board
    @board.each_key do |k|
      @board[k] = ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ']
    end
    update_board_row(@current_turn)
    update_board_row(@next_turn)
  end

  def update_board_row(player)
    player.pieces.pieces.select do |_k, v|
      next if v[:position].nil?

      @board[v[:position][1]][(@col_to_num[v[:position][0]]) - 1] = (v[:icon]).to_s
    end
  end

  def find_check # rubocop:disable Metrics
    king = @current_turn.pieces.pieces[:king][:position]
    swap_turn
    @current_turn.pieces.pieces.each_value do |piece|
      next if piece[:position].nil?

      moves = @movement.possible_moves(@current_turn, piece[:position], @next_turn)
      next if moves.nil?

      moves.each do |threat|
        swap_turn if threat == king
        return true if threat == king
      end
    end
    swap_turn
    false
  end

  def find_mate
    @current_turn.pieces.pieces.each do |k, v|
      next if v[:position].nil?

      player_state = @current_turn.pieces.pieces[k][:position]
      pos_moves = @movement.possible_moves(@current_turn, v[:position], @next_turn)
      return false unless mate?(pos_moves, v, player_state)
    end
    true
  end

  def mate?(pos_moves, piece, state)
    pos_moves.each do |move|
      taken_piece = process_move(piece[:position], move)
      check = find_check
      piece[:position] = state
      taken_piece[:position] = move unless taken_piece.empty?
      return false unless check
    end
    true
  end

  def swap_turn
    if @current_turn == @player2
      @current_turn = @player1
      @next_turn = @player2
    else
      @current_turn = @player2
      @next_turn = @player1
    end
  end

  def play_move
    loop do
      piece = choose_piece
      move = choose_move(piece)
      next if move == false

      taken_piece = process_move(piece, move)
      return unless find_check

      taken_piece[:position] = move unless taken_piece.empty?
      @current_turn.pieces.pieces.select { |_k, h| h[:position] = piece if h[:position] == move }
      puts 'This move has you in check. Invalid move, try again.'
    end
  end

  def play_game
    loop do
      display_board
      mate = find_mate if find_check
      return if mate

      play_move
      update_board
      swap_turn
    end
  end
end

game = Chess.new
game.play_game
puts "Game over #{game.next_turn.side} wins!"
