# frozen-string-literal: true

# Holds the board, and board methods
class Board
  def initialize
    @board = { 8 => ["\u265c ", "\u265e ", "\u265d ", "\u265b ", "\u265a ", "\u265d ", "\u265e ", "\u265c "],
               7 => ["\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f "],
               6 => ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
               5 => ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
               4 => ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
               3 => ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
               2 => ["\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 "],
               1 => ["\u2656 ", "\u2658 ", "\u2657 ", "\u2655 ", "\u2654 ", "\u2657 ", "\u2658 ", "\u2656 "] }
  end

  def display_board
    puts '    A   |  B   |  C   |  D   |  E   |  F   |  G   |  H   '
    @board.each do |k, v|
      puts " #{k}: #{v.join('  |  ')}"
    end
  end

  def update_board(current_turn, next_turn)
    @board.each_key do |k|
      @board[k] = ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ']
    end
    update_board_row(current_turn)
    update_board_row(next_turn)
  end

  def update_board_row(player)
    player.pieces.pieces.select do |_k, v|
      next if v[:position].nil?

      @board[v[:position][1]][(@col_to_num[v[:position][0]]) - 1] = (v[:icon]).to_s
    end
  end
end
