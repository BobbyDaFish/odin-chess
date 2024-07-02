# frozen-string-literal: true

# main game class. holds methods for the board, and calls to pieces for creating and updating pieces
class Chess
  def initialize
    @board = create_board
    @player1 = Player.new(1)
    @player2 = Player.new(2)
  end
end
