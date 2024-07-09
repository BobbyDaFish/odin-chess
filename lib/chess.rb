# frozen-string-literal: true

require_relative 'pieces'
require_relative 'player'
require 'pry-byebug'

# main game class. holds methods for the board, and calls to pieces for creating and updating pieces
class Chess
  attr_reader :player1, :player2, :current_turn

  def initialize
    @board = { a: ["\u265c ", "\u265e ", "\u265d ", "\u265b ", "\u265a ", "\u265d ", "\u265e ", "\u265c "],
               b: ["\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f "],
               c: %w[_ _ _ _ _ _ _ _],
               d: %w[_ _ _ _ _ _ _ _],
               e: %w[_ _ _ _ _ _ _ _],
               f: %w[_ _ _ _ _ _ _ _],
               g: ["\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 "],
               h: ["\u2656 ", "\u2658 ", "\u2657 ", "\u2655 ", "\u2654 ", "\u2657 ", "\u2658 ", "\u2656 "] }
    @player1 = Player.new(1)
    @player2 = Player.new(2)
    @current_turn = @player2
    @next_turn = @player1
  end

  def choose_piece(player)
    valid_piece = false
    piece = []
    while valid_piece == false
      puts "Select your piece!\nPick a row from A to Z"
      piece[0] = gets.chomp
      puts 'Pick a column from 1 to 8'
      piece[1] = gets.chomp.to_i
      valid_piece = true if player.value?(piece)
    end
    piece
  end

  def choose_move(piece_coords)
    move = []
    puts "Where are you moving?\nPick a row from A to Z"
    move[0] = gets.chomp
    puts 'Pick a column from 1 to 8'
    move[1] = gets.chomp.to_i
    return move if possible_moves(@current_turn, piece_coords).any?(move)

    puts 'Invalid move, try again.'
    false
  end

  def possible_moves(player, piece_coords) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
    row_to_num = { 'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8 }
    true_pos = [row_to_num[piece_coords[0]], piece_coords[1]]
    piece_type = (player.pieces.pieces.select { |_k, h| h[:position] == piece_coords }).flatten[1][:icon]

    possible_moves = king_moves(true_pos) if ["\u2654 ", "\u265a "].include?(piece_type)
    possible_moves = queen_moves(true_pos) if ["\u2655 ", "\u265b "].include?(piece_type)
    possible_moves = knight_moves(true_pos) if ["\u2658 ", "\u265e "].include?(piece_type)
    possible_moves = bishop_moves(true_pos) if ["\u2657 ", "\u265d "].include?(piece_type)
    possible_moves = rook_moves(true_pos) if ["\u2656 ", "\u265c "].include?(piece_type)
    possible_moves = pawn_moves(true_pos) if ["\u2659 ", "\u265f "].include?(piece_type)
    possible_moves
  end

  def remove_invalid_moves(moves_arr, current_player)
    num_to_row = { 1 => 'a', 2 => 'b', 3 => 'c', 4 => 'd', 5 => 'e', 6 => 'f', 7 => 'g', 8 => 'h' }
    final_moves = moves.arr
    moves_arr.each do |move|
      final_moves.delete(move) if move.any? > 8 || move.any? < 1
    end
    final_moves.each do |move|
      final_moves.delete(move) if current_player.values?(move)
      move[0] = num_to_row[move[0]]
    end
    final_moves
  end

  def king_move(piece_coords)
    all_moves = [[-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1]]
    possible_moves = []
    possible_moves << all_moves.each { |arr| [arr[0] + piece_coords[0], arr[1] + piece_coords[1]] }
    remove_invalid_moves(possible_moves, @current_turn)
  end

  def knight_moves(piece_coords)
    all_moves = [[-2, 1], [-2, -1], [-1, -2], [-1, 2], [1, 2], [1, -2], [2, 1], [2, -1]]
    possible_moves = []
    possible_moves << all_moves.each { |arr| [arr[0] + piece_coords[0], arr[1] + piece_coords[1]] }
    remove_invalid_moves(possible_moves, @current_turn)
  end
end
