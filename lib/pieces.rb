# frozen-string-literal: true

require 'pry-byebug'

# piece reference:
#   white: king: "\u2654" queen: "\u2655" knight: "\u2658" rook: "\u2656" bishop: "\u2657" pawn: "\u2659"
#   black: king: "\u265a" queen: "\u265b" knight: "\u265e" rook: "\u265c" bishop: "\u265d" pawn "\u265f"

# This is the pieces class that generates each piece object. It also hold methods for calculating possible
# moves for each piece type. This shold be called after each move to generate new moves for that piece
class Pieces
  attr_accessor :pieces, :icon

  def initialize(player)
    @pieces = create_pieces(player)
  end

  def create_pieces(player)
    rows = [1, 2] if player == 'white'
    rows = [8, 7] if player == 'black'

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

    king[:position] = ['e', rows[0]]
    king
  end

  def create_queen(player, rows)
    queen = {}
    queen[:icon] = "\u265b " if player == 'black'
    queen[:icon] = "\u2655 " if player == 'white'

    queen[:position] = ['d', rows[0]]
    queen
  end

  def create_knights(player, rows, pieces) # rubocop:disable Metrics/AbcSize
    pieces[:left_knight] = {}
    pieces[:right_knight] = {}
    pieces[:left_knight][:icon] = "\u265e " if player == 'black'
    pieces[:left_knight][:icon] = "\u2658 " if player == 'white'
    pieces[:left_knight][:position] = ['b', rows[0]]
    pieces[:right_knight][:icon] = "\u265e " if player == 'black'
    pieces[:right_knight][:icon] = "\u2658 " if player == 'white'
    pieces[:right_knight][:position] = ['g', rows[0]]
    pieces
  end

  def create_rooks(player, rows, pieces) # rubocop:disable Metrics/AbcSize
    pieces[:left_rook] = {}
    pieces[:right_rook] = {}
    pieces[:left_rook][:icon] = "\u265c " if player == 'black'
    pieces[:left_rook][:icon] = "\u2656 " if player == 'white'
    pieces[:left_rook][:position] = ['a', rows[0]]
    pieces[:right_rook][:icon] = "\u265c " if player == 'black'
    pieces[:right_rook][:icon] = "\u2656 " if player == 'white'
    pieces[:right_rook][:position] = ['h', rows[0]]
    pieces
  end

  def create_bishops(player, rows, pieces) # rubocop:disable Metrics/AbcSize
    pieces[:left_bishop] = {}
    pieces[:right_bishop] = {}
    pieces[:left_bishop][:icon] = "\u265d " if player == 'black'
    pieces[:left_bishop][:icon] = "\u2657 " if player == 'white'
    pieces[:left_bishop][:position] = ['c', rows[0]]
    pieces[:right_bishop][:icon] = "\u265d " if player == 'black'
    pieces[:right_bishop][:icon] = "\u2657 " if player == 'white'
    pieces[:right_bishop][:position] = ['f', rows[0]]
    pieces
  end

  def create_pawns(player, row, pieces) # rubocop:disable Metrics/AbcSize
    pieces[:pawn1] = create_one_pawn(player, row, 'a')
    pieces[:pawn2] = create_one_pawn(player, row, 'b')
    pieces[:pawn3] = create_one_pawn(player, row, 'c')
    pieces[:pawn4] = create_one_pawn(player, row, 'd')
    pieces[:pawn5] = create_one_pawn(player, row, 'e')
    pieces[:pawn6] = create_one_pawn(player, row, 'f')
    pieces[:pawn7] = create_one_pawn(player, row, 'g')
    pieces[:pawn8] = create_one_pawn(player, row, 'h')
    pieces
  end

  def create_one_pawn(player, row, col)
    pawn = {}
    pawn[:icon] = "\u265f " if player == 'black'
    pawn[:icon] = "\u2659 " if player == 'white'

    pawn[:position] = [col, row[1]]
    pawn
  end
end
