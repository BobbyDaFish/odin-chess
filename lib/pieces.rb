# frozen-string-literal: true

# This is the pieces class that generates each piece object. It also hold methods for calculating possible
# moves for each piece type. This shold be called after each move to generate new moves for that piece
class Pieces
  def initialize(player, type, position)
    @player = player
    @type = type
    @position = position
    @moves = possible_moves(player, type, position)
  end
end
