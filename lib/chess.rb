# frozen-string-literal: true

require_relative 'pieces'
require_relative 'player'
require 'pry-byebug'

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
    return move if possible_moves(@current_turn, piece_coords).any?(move)

    puts 'Invalid move, select a piece and try again.'
    puts 'valid moves are'
    p possible_moves(@current_turn, piece_coords)
    false
  end

  def possible_moves(player, piece_coords) # rubocop:disable Metrics
    rook_direction = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    bishop_direction = [[-1, 1], [1, 1], [1, -1], [-1, -1]]
    queen_direction = [[-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0]]
    true_pos = [@col_to_num[piece_coords[0]], piece_coords[1]]
    piece_type = (player.pieces.pieces.select { |_k, h| h[:position] == piece_coords }).flatten[1][:icon]
    possible_moves = king_moves(true_pos) if ["\u2654 ", "\u265a "].include?(piece_type)
    possible_moves = linear_moves(true_pos, queen_direction) if ["\u2655 ", "\u265b "].include?(piece_type)
    possible_moves = knight_moves(true_pos) if ["\u2658 ", "\u265e "].include?(piece_type)
    possible_moves = linear_moves(true_pos, bishop_direction) if ["\u2657 ", "\u265d "].include?(piece_type)
    possible_moves = linear_moves(true_pos, rook_direction) if ["\u2656 ", "\u265c "].include?(piece_type)
    possible_moves = pawn_moves(true_pos) if ["\u2659 ", "\u265f "].include?(piece_type)
    possible_moves.each { |move| move[0] = @num_to_col[move[0]] }
    possible_moves
  end

  # checks for moves that would go off board, or collide with a friendly piece
  def remove_invalid_moves(moves_arr) # rubocop:disable Metrics
    final_moves = []
    moves_arr.each do |move|
      final_moves << move unless move.any? { |n| n > 8 } || move.any? { |n| n < 1 }
      @current_turn.pieces.pieces.select do |_k, h|
        final_moves.delete([move[0], move[1]]) if h[:position] == [@num_to_col[move[0]], move[1]]
      end
    end

    final_moves
  end

  def king_moves(piece_coords)
    all_moves = [[0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1]]
    possible_moves = []
    all_moves.each { |arr| possible_moves << [arr[0] + piece_coords[0], arr[1] + piece_coords[1]] }
    remove_invalid_moves(possible_moves)
  end

  def knight_moves(piece_coords)
    all_moves = [[-2, 1], [-2, -1], [-1, -2], [-1, 2], [1, 2], [1, -2], [2, 1], [2, -1]]
    possible_moves = []
    all_moves.each { |arr| possible_moves << [arr[0] + piece_coords[0], arr[1] + piece_coords[1]] }
    remove_invalid_moves(possible_moves)
  end

  def linear_moves(piece_coords, directions)
    possible_moves = []
    directions.each do |direction|
      next if direction_move(piece_coords, direction).nil?

      single_direction_moves = direction_move(piece_coords, direction)
      single_direction_moves.each { |arr| possible_moves << arr }
    end

    possible_moves # this aint working right. We're getting some weird nested arrays and stuff.
    # maybe time to rethink how linear moves are working, and refactor
  end

  def direction_move(piece_coords, direction, moves = []) # rubocop:disable Metrics/AbcSize
    coords = [piece_coords[0] + direction[0], piece_coords[1] + direction[1]]
    valid_move = remove_invalid_moves([coords])
    return moves if valid_move.empty? && moves.any?
    return nil if valid_move.empty?

    moves << valid_move.flatten
    @next_turn.pieces.pieces.select do |_k, h| # stop if opponent's piece
      return moves if h[:position] == [@num_to_col[valid_move[0][0]], valid_move[0][1]]
    end
    direction_move(coords, direction, moves)
  end

  def pawn_moves(piece_coords) # rubocop:disable Metrics/AbcSize
    dir = [[0, 1]]
    dir << [0, 2] if piece_coords[1] == 2 || piece_coords[1] == 7
    dir.each { |coords| coords[1] *= -1 } if @current_turn.side == 'black' # correct direction if black player

    dir = pawn_opponent_check(piece_coords, dir)
    possible_moves = []
    dir.each { |arr| possible_moves << [arr[0] + piece_coords[0], arr[1] + piece_coords[1]] }
    remove_invalid_moves(possible_moves)
  end

  # checks for opponent pieces diagonal, and ahead of selected pawn. It adjusts possible directions of movement to match
  def pawn_opponent_check(piece_coords, dir) # rubocop:disable Metrics/AbcSize
    forward_piece = false
    @next_turn.pieces.pieces.select do |_k, h|
      forward_piece = true if h[:position] == [@num_to_col[piece_coords[0]], piece_coords[1] + 1]
      dir << [dir[0][0] + 1, dir[0][1]] if h[:position] == [@num_to_col[piece_coords[0] + 1], piece_coords[1] + 1]
      dir << [dir[0][0] - 1, dir[0][1]] if h[:position] == [@num_to_col[piece_coords[0] - 1], piece_coords[1] + 1]
    end
    dir.delete([0, 1]) if forward_piece == true # removes forward direction option if there was a piece present
    # this is to prevent the diagonal options from breaking if the forward is removed too early.
    dir
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
    @next_turn.pieces.pieces.each_value do |piece|
      next if piece[:position].nil?

      moves = possible_moves(@next_turn, piece[:position])
      next if moves.nil?

      moves.each do |threat|
        return true if threat == king
      end
    end
    false
  end

  def find_mate
    @current_turn.pieces.pieces.select do |k, v|
      current_pos = []
      current_pos << v[:position][0]
      current_pos << v[:position][1]
      possible_moves = possible_moves(@current_turn, v[:position])
      possible_moves.each do |move|
        @current_turn.pieces.pieces[k][v][:position] = move
        return false unless find_check
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
      game_over = true && next if mate
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
