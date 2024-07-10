# frozen-string-literal: true

require_relative 'pieces'
require_relative 'player'
require 'pry-byebug'

# main game class. holds methods for the board, and calls to pieces for creating and updating pieces
class Chess
  attr_reader :player1, :player2
  attr_accessor :current_turn, :next_turn

  def initialize # rubocop:disable Metrics/MethodLength
    @board = { 1 => ["\u265c ", "\u265e ", "\u265d ", "\u265b ", "\u265a ", "\u265d ", "\u265e ", "\u265c "],
               2 => ["\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f "],
               3 => %w[_ _ _ _ _ _ _ _],
               4 => %w[_ _ _ _ _ _ _ _],
               5 => %w[_ _ _ _ _ _ _ _],
               6 => %w[_ _ _ _ _ _ _ _],
               7 => ["\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 "],
               8 => ["\u2656 ", "\u2658 ", "\u2657 ", "\u2655 ", "\u2654 ", "\u2657 ", "\u2658 ", "\u2656 "] }
    @player1 = Player.new(1)
    @player2 = Player.new(2)
    @current_turn = @player2
    @next_turn = @player1
    @num_to_col = { 1 => 'a', 2 => 'b', 3 => 'c', 4 => 'd', 5 => 'e', 6 => 'f', 7 => 'g', 8 => 'h' }
  end

  def choose_piece(player)
    valid_piece = false
    piece = []
    while valid_piece == false
      puts "Select a #{@current_turn.side} piece!\nPick a column from A to H"
      piece[0] = gets.chomp
      puts 'Choose a row from 1 to 8'
      piece[1] = gets.chomp.to_i
      valid_piece = true if player.value?(piece)
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

    puts 'Invalid move, try again.'
    false
  end

  def possible_moves(player, piece_coords) # rubocop:disable Metrics
    rook_direction = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    bishop_direction = [[-1, 1], [1, 1], [1, -1], [-1, -1]]
    queen_direction = [[-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0]]
    col_to_num = { 'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8 }
    true_pos = [col_to_num[piece_coords[0]], piece_coords[1]]
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
        final_moves.delete(move) if h[:position] == [@num_to_col[move[0]], move[1]]
      end
    end

    final_moves
  end

  def king_move(piece_coords)
    all_moves = [[0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1]]
    possible_moves = []
    possible_moves << all_moves.each { |arr| [arr[0] + piece_coords[0], arr[1] + piece_coords[1]] }
    remove_invalid_moves(possible_moves)
  end

  def knight_moves(piece_coords)
    all_moves = [[-2, 1], [-2, -1], [-1, -2], [-1, 2], [1, 2], [1, -2], [2, 1], [2, -1]]
    possible_moves = []
    possible_moves << all_moves.each { |arr| [arr[0] + piece_coords[0], arr[1] + piece_coords[1]] }
    remove_invalid_moves(possible_moves)
  end

  def linear_moves(piece_coords, directions)
    possible_moves = []
    directions.each do |direction|
      possible_moves << direction_move(piece_coords, direction)
    end
    return [] if possible_moves.all?(nil)

    possible_moves
  end

  def direction_move(piece_coords, direction, moves = []) # rubocop:disable Metrics/AbcSize
    coords = [piece_coords[0] + direction[0], piece_coords[1] + direction[1]]
    valid_move = remove_invalid_moves([coords])
    return moves if valid_move.empty? && moves.any?
    return nil if valid_move.empty?

    moves << valid_move.flatten
    @next_turn.pieces.pieces.select do |_k, h| # stop if opponent's piece
      return moves if h[:position] == [@num_to_col[valid_move[0]], valid_move[1]]
    end
    direction_move(coords, direction, moves)
  end

  def pawn_move(piece_coords) # rubocop:disable Metrics/AbcSize
    dir = [[0, 1]]
    dir << [0, 2] if piece_coords[1] == 2 || piece_coords[1] == 7
    dir.each { |coords| coords[1] *= -1 } if @current_turn.side == 'black' # correct direction if black player

    dir = pawn_opponent_check(piece_coords, dir)
    possible_moves = []
    dir.each { |arr| possible_moves << [arr[0] + piece_coords[0], arr[1] + piece_coords[1]] }
    remove_invalid_moves(possible_moves)
  end

  def pawn_opponent_check(piece_coords, dir) # rubocop:disable Metrics/AbcSize
    forward_piece = false
    @next_turn.pieces.pieces.select do |_k, h| # check for opponent pieces, adjust directions appropriately
      forward_piece = true if h[:position] == [@num_to_col[piece_coords[0]], piece_coords[1] + 1]
      dir << [dir[0][0] + 1, dir[0][1]] if h[:position] == [@num_to_col[piece_coords[0] + 1], piece_coords[1] + 1]
      dir << [dir[0][0] - 1, dir[0][1]] if h[:position] == [@num_to_col[piece_coords[0] - 1], piece_coords[1] + 1]
    end
    dir.delete([0, 1]) if forward_piece == true
    dir
  end
end
