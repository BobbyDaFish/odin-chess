# frozen-string-literal: true

require_relative 'pieces'
require_relative 'player'
require_relative 'moves'

# main game class. holds methods for the board, and calls to pieces for creating and updating pieces
class Chess
  attr_reader :player1, :player2
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
    valid_piece = false
    piece = []
    while valid_piece == false
      puts "Select a #{@current_turn.side} piece!\nPick a column from A to H"
      piece[0] = gets.chomp
      puts 'Choose a row from 1 to 8'
      piece[1] = gets.chomp.to_i
      @current_turn.pieces.pieces.select { |_k, v| (valid_piece = true) if piece == v[:position] }
      puts 'Invalid selection!' if valid_piece == false
    end
    piece
  end

  def choose_move(piece_coords)
    move = []
    puts "Where are you moving?\nPick a column from A to H"
    move[0] = gets.chomp
    puts 'Choose a row from 1 to 8'
    move[1] = gets.chomp.to_i
    return move if @movement.possible_moves(@current_turn, piece_coords).any?(move)

    puts 'Invalid move, select a piece and try again.'
    false
  end

  # checks if current players pieces share position coordinates with next players piece.
  # If so, set next player's piece position to nil to remove from board
  def resolve_takes
    @current_turn.pieces.pieces.each_value do |current_turn_piece|
      @next_turn.pieces.pieces.each_value do |next_turn_piece|
        taken_piece = next_turn_piece if current_turn_piece[:position] == next_turn_piece[:position]
        next_turn_piece[:position] = nil if current_turn_piece[:position] == next_turn_piece[:position]
        return taken_piece unless taken_piece.nil?
      end
    end
  end

  def update_board
    @board.each_key do |k|
      @board[k] = ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ']
    end
    @current_turn.pieces.pieces.select do |_k, v|
      next if v[:position].nil?

      coords = [v[:position][1], (@col_to_num[v[:position][0]]) - 1]
      @board[coords[0]][coords[1]] = (v[:icon]).to_s
    end
    @next_turn.pieces.pieces.select do |_k, v|
      next if v[:position].nil?

      coords = [v[:position][1], (@col_to_num[v[:position][0]]) - 1]
      @board[coords[0]][coords[1]] = (v[:icon]).to_s
    end
  end

  def find_check
    king = @current_turn.pieces.pieces[:king][:position]
    swap_turn
    @current_turn.pieces.pieces.each_value do |piece|
      next if piece[:position].nil?

      moves = @movement.possible_moves(@current_turn, piece[:position])
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
    @current_turn.pieces.pieces.select do |k, v|
      next if v[:position].nil?

      current_pos = []
      current_pos << v[:position][0]
      current_pos << v[:position][1]
      possible_moves = @movement.possible_moves(@current_turn, v[:position])
      possible_moves.each do |move|
        @current_turn.pieces.pieces[k][:position] = move
        unless find_check
          @current_turn.pieces.pieces[k][:position] = current_pos
          return false
        end

        @current_turn.pieces.pieces[k][:position] = current_pos
      end
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

  def play_game
    game_over = false
    until game_over == true
      display_board
      mate = find_mate if find_check
      game_over = true if mate
      next if mate

      piece = choose_piece
      move = choose_move(piece)
      next if move == false

      @current_turn.pieces.pieces.select { |_k, h| h[:position] = move if h[:position] == piece }
      taken_piece = resolve_takes
      if find_check
        taken_piece[:position] = move
        @current_turn.pieces.pieces.select { |_k, h| h[:position] = piece if h[:position] == move }
        puts 'This move has you in check. Invalid move, try again.'
        next
      end
      update_board
      swap_turn
    end
  end
end

game = Chess.new
game.play_game
puts "Game over #{game.current_turn.side} wins!"
