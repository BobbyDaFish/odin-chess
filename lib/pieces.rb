# frozen-string-literal: true

require 'pry-byebug'

# piece reference:
#   white: king: "\u2654" queen: "\u2655" knight: "\u2658" rook: "\u2656" bishop: "\u2657" pawn: "\u2659"
#   black: king: "\u265a" queen: "\u265b" knight: "\u265e" rook: "\u265c" bishop: "\u265d" pawn "\u265f"

# This is the pieces class that generates each piece object. It also hold methods for calculating possible
# moves for each piece type. This shold be called after each move to generate new moves for that piece
class Pieces
  attr_accessor :pieces

  def initialize(player)
    @pieces = create_pieces(player)
  end

  def create_pieces(player)
    rows = %w[a b] if player == 'black'
    rows = %w[g h] if player == 'white'

    pieces = {}
    pieces[:king] = create_king(player, rows)
    pieces[:queen] = create_queen(player, rows)
    pieces = create_knights(player, rows, pieces)
    pieces = create_bishops(player, rows, pieces)
    pieces = create_rooks(player, rows, pieces)
    create_pawns(player, rows, pieces)
  end

  def create_king(player, rows)
    king = {}
    king[:icon] = "\u265a " if player == 'black'
    king[:icon] = "\u2654 " if player == 'white'

    king[:position] = [rows[0], 5]
    king
  end

  def create_queen(player, rows)
    queen = {}
    queen[:icon] = "\u265b " if player == 'black'
    queen[:icon] = "\u2655 " if player == 'white'

    queen[:position] = [rows[0], 4]
    queen
  end

  def create_knights(player, rows, pieces)
    pieces[:left_knight] = {}
    pieces[:right_knight] = {}
    pieces[:left_knight][:icon] = "\u265e " if player == 'black'
    pieces[:left_knight][:icon] = "\u2658 " if player == 'white'
    pieces[:left_knight][:position] = [rows[0], 2]
    pieces[:right_knight][:icon] = "\u265e " if player == 'black'
    pieces[:right_knight][:icon] = "\u2658 " if player == 'white'
    pieces[:right_knight][:position] = [rows[0], 7]
    pieces
  end

  def create_rooks(player, rows, pieces)
    pieces[:left_rook] = {}
    pieces[:right_rook] = {}
    pieces[:left_rook][:icon] = "\u265e " if player == 'black'
    pieces[:left_rook][:icon] = "\u2656 " if player == 'white'
    pieces[:left_rook][:position] = [rows[0], 1]
    pieces[:right_rook][:icon] = "\u265e " if player == 'black'
    pieces[:right_rook][:icon] = "\u2656 " if player == 'white'
    pieces[:right_rook][:position] = [rows[0], 8]
    pieces
  end

  def create_bishops(player, rows, pieces)
    pieces[:left_bishop] = {}
    pieces[:right_bishop] = {}
    pieces[:left_bishop][:icon] = "\u265d " if player == 'black'
    pieces[:left_bishop][:icon] = "\u2657 " if player == 'white'
    pieces[:left_bishop][:position] = [rows[0], 3]
    pieces[:right_bishop][:icon] = "\u265d " if player == 'black'
    pieces[:right_bishop][:icon] = "\u2657 " if player == 'white'
    pieces[:right_bishop][:position] = [rows[0], 6]
    pieces
  end

  def create_pawns(player, row, pieces) # rubocop:disable Metrics/AbcSize
    pieces[:pawn1] = create_one_pawn(player, row, 1)
    pieces[:pawn2] = create_one_pawn(player, row, 2)
    pieces[:pawn3] = create_one_pawn(player, row, 3)
    pieces[:pawn4] = create_one_pawn(player, row, 4)
    pieces[:pawn5] = create_one_pawn(player, row, 5)
    pieces[:pawn6] = create_one_pawn(player, row, 6)
    pieces[:pawn7] = create_one_pawn(player, row, 7)
    pieces[:pawn8] = create_one_pawn(player, row, 8)
    pieces
  end

  def create_one_pawn(player, row, num)
    pawn = {}
    pawn[:icon] = "\u265f " if player == 'black'
    pawn[:icon] = "\u2659 " if player == 'white'

    pawn[:position] = [row[1], num]
    pawn
  end

  def move_calc(player, position, piece)
    # calc_pawn(player, position) if piece == 'pawn'
    # calc_knight(player, true_pos) if piece == 'knight'
    # calc_bishop(player, true_pos) if piece == 'bishop'
    # calc_rook(player, true_pos) if piece == 'rook'
    # calc_queen(player, true_pos) if piece == 'queen'
    # calc_king(player, true_pos) if piece == 'queen'
  end

  def calc_pawn(player, position)
    row_to_num = { 'a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8 }
    true_pos = [row_to_num[position[0]], position[1]]
    moved = false
    moved = true if true_pos[0] > 2 && player == 'white'
    moved = true if true_pos[0] > 7 && player == 'black'
  end
end
