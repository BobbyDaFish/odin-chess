# frozen-string-literal: true

# This is the class for the players. It holds the number of turns taken, their last several moves
# the last piece taken, and the turn count when that piece was taken
class Player
  attr_reader :side
  attr_accessor :turns_taken, :last_piece_taken, :turn_history, :pieces

  def initialize(player)
    @turns_taken = 0
    @last_piece_taken = [nil, 0]
    @turn_history = {}
    @side = 'black' if player == 1
    @side = 'white' if player == 2
    @pieces = Pieces.new(@side)
  end
end
