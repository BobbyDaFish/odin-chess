# frozen-string-literal: true

# this class stores all the methods for moving pieces and checking possible moves
class Moves
  def initialize
    @num_to_col = { 1 => 'a', 2 => 'b', 3 => 'c', 4 => 'd', 5 => 'e', 6 => 'f', 7 => 'g', 8 => 'h' }
    @col_to_num = { 'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8 }
    @player
  end

  def possible_moves(player, piece_coords, next_player) # rubocop:disable Metrics
    @player = player
    rook_direction = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    bishop_direction = [[-1, 1], [1, 1], [1, -1], [-1, -1]]
    queen_direction = [[-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0]]
    true_position = [@col_to_num[piece_coords[0]], piece_coords[1]]
    piece_type = (player.pieces.pieces.select { |_k, h| h[:position] == piece_coords }).flatten[1][:icon]
    possible_moves = king_moves(true_position) if ["\u2654 ", "\u265a "].include?(piece_type)
    possible_moves = linear_moves(true_position, queen_direction, next_player) if ["\u2655 ",
                                                                                   "\u265b "].include?(piece_type)
    possible_moves = knight_moves(true_position) if ["\u2658 ", "\u265e "].include?(piece_type)
    possible_moves = linear_moves(true_position, bishop_direction, next_player) if ["\u2657 ",
                                                                                    "\u265d "].include?(piece_type)
    possible_moves = linear_moves(true_position, rook_direction, next_player) if ["\u2656 ",
                                                                                  "\u265c "].include?(piece_type)
    possible_moves = pawn_moves(true_position, next_player) if ["\u2659 ", "\u265f "].include?(piece_type)
    possible_moves.each { |move| move[0] = @num_to_col[move[0]] }
    possible_moves
  end

  # checks for moves that would go off board, or collide with a friendly piece
  def remove_invalid_moves(moves_arr) # rubocop:disable Metrics
    final_moves = []
    moves_arr.each do |move|
      final_moves << move unless move.any? { |n| n > 8 } || move.any? { |n| n < 1 }
      @player.pieces.pieces.select do |_k, h|
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

  def linear_moves(piece_coords, directions, next_player)
    possible_moves = []
    directions.each do |direction|
      next if direction_move(piece_coords, next_player, direction).nil?

      single_direction_moves = direction_move(piece_coords, next_player, direction)
      single_direction_moves.each { |arr| possible_moves << arr }
    end

    possible_moves
  end

  def direction_move(piece_coords, next_player, direction, moves = []) # rubocop:disable Metrics/AbcSize
    coords = [piece_coords[0] + direction[0], piece_coords[1] + direction[1]]
    valid_move = remove_invalid_moves([coords])
    return moves if valid_move.empty? && moves.any?
    return nil if valid_move.empty?

    moves << valid_move.flatten
    next_player.pieces.pieces.select do |_k, h| # stop if opponent's piece
      return moves if h[:position] == [@num_to_col[valid_move[0][0]], valid_move[0][1]]
    end
    direction_move(coords, next_player, direction, moves)
  end

  def pawn_moves(piece_coords, next_player) # rubocop:disable Metrics/AbcSize
    dir = [[0, 1]]
    dir << [0, 2] if piece_coords[1] == 2 || piece_coords[1] == 7
    dir.each { |coords| coords[1] *= -1 } if @player.side == 'black' # correct direction if black player
    dir = pawn_opponent_check(piece_coords, dir, next_player)
    possible_moves = []
    dir.each { |arr| possible_moves << [arr[0] + piece_coords[0], arr[1] + piece_coords[1]] }
    remove_invalid_moves(possible_moves)
  end

  # checks for opponent pieces diagonal, and ahead of selected pawn. It adjusts possible directions of movement to match
  def pawn_opponent_check(piece_coords, dir, next_player) # rubocop:disable Metrics
    forward_piece = false
    forward_dir = 1 if @player.side == 'white'
    forward_dir = -1 if @player.side == 'black'
    next_player.pieces.pieces.each_value do |h|
      next if h[:position].nil?

      forward_piece = true if h[:position] == [@num_to_col[piece_coords[0]], piece_coords[1] + forward_dir]
      dir << [dir[0][0] + 1, dir[0][1]] if h[:position] == [@num_to_col[piece_coords[0] + 1],
                                                            piece_coords[1] + forward_dir]
      dir << [dir[0][0] - 1, dir[0][1]] if h[:position] == [@num_to_col[piece_coords[0] - 1],
                                                            piece_coords[1] + forward_dir]
    end
    dir.delete([0, forward_dir]) if forward_piece == true
    dir
  end
end
