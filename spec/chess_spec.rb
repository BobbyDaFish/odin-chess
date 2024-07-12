# frozen-string-literal: true

require '../lib/chess'

describe Chess do # rubocop:disable Metrics/BlockLength
  subject(:game) { described_class.new }

  describe '#choose_piece' do
    before do
      allow(game).to receive(:gets).and_return('a', '1')
    end

    it 'returns the move selection if valid' do
      array = game.choose_piece
      expect(array).to eql(['a', 1])
    end
  end

  describe '#choose_move' do
    describe 'user inputs a valid move selection' do
      before do
        allow(game).to receive(:possible_moves).and_return([['c', 1], ['d', 1]])
        allow(game).to receive(:gets).and_return('d', '1')
      end

      it 'returns the selection of a valid move' do
        move = game.choose_move(['b', 1])
        expect(move).to eql(['d', 1])
      end
    end

    describe 'user inputs invalid selection' do
      before do
        allow(game).to receive(:possible_moves).and_return([['c', 1], ['d', 1]])
        allow(game).to receive(:gets).and_return('e', '1')
      end

      it 'returns false' do
        move = game.choose_move(['b', 1])
        expect(move).to be false
      end
    end
  end

  describe '#possible_moves' do
    before do
      allow(game).to receive(:king_moves).and_return([[4, 1], [4, 2], [5, 2], [6, 2], [6, 1]])
      allow(game).to receive(:knight_moves).and_return([[1, 3], [3, 3]])
    end

    it 'returns array of possible moves as sub arrays for the white side king' do
      moves = game.possible_moves(game.current_turn, ['e', 1])
      expect(moves).to eql([['d', 1], ['d', 2], ['e', 2], ['f', 2], ['f', 1]])
    end

    it 'returns array of possible moves from starting position for left white knight' do
      moves = game.possible_moves(game.current_turn, ['b', 1])
      expect(moves).to eql([['a', 3], ['c', 3]])
    end
  end

  describe '#linear_moves' do
    context 'starting game board, no pieces moved' do
      before do
        allow(game).to receive(:remove_invalid_moves).and_return([])
        allow(game).to receive(:direction_move).and_return(nil)
      end

      it 'returns an empty array, as there are no possible moves' do
        moves = game.possible_moves(game.current_turn, ['a', 1])
        expect(moves).to eql([])
      end
    end

    context 'white left bishop at c1 has clear moves to b2, a3, d2, e3, f4, and takes a pawn at g5' do
      before do
        game.next_turn.pieces.pieces[:pawn7][:position] = ['g', 5]
        game.player2.pieces.pieces[:pawn2][:position] = ['b', 4]
        game.player2.pieces.pieces[:pawn4][:position] = ['d', 4]
      end

      it 'returns possible moves including taking pawn' do
        result = game.linear_moves([3, 1], [[-1, 1], [1, 1], [1, -1], [-1, -1]])
        expect(result).to eql([[2, 2], [1, 3], [4, 2], [5, 3], [6, 4], [7, 5]])
      end
    end

    context 'black queen at c3 threatens white king at e1' do
      before do
        game.next_turn.pieces.pieces[:queen][:position] = ['c', 3]
        game.current_turn.pieces.pieces[:pawn4][:position] = ['d', 4]
        game.swap_turn
      end

      it 'includes e1 as a possible move' do
        moves = game.linear_moves([3, 3], [[-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0]])
        expect(moves).to include([5, 1])
      end
    end
  end

  describe '#direction_move' do
    context 'starting board with no moves' do
      it 'receives a position and direction with no possible moves, so returns nil' do
        result = game.direction_move([1, 1], [0, 1])
        expect(result).to eql(nil)
      end
    end

    context 'rook with a clear path forward to pawn at a7, but no other movement' do
      before do
        allow(game).to receive(:remove_invalid_moves).and_return([[1, 2]], [[1, 3]], [[1, 4]], [[1, 5]], [[1, 6]], [[1, 7]]) # rubocop:disable Layout/LineLength
      end

      it 'returns valid move options' do
        result = game.direction_move([1, 1], [0, 1])
        expect(result).to eql([[1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7]])
      end
    end
  end

  describe '#pawn_move' do
    context 'starting board with no moves for white player' do
      it 'can move forward one or two spaces' do
        moves = game.pawn_moves([1, 2])
        expect(moves).to eql([[1, 3], [1, 4]])
      end
    end

    context 'starting board with no moves for black player' do
      before do
        game.current_turn = game.player1
        game.next_turn = game.player2
      end
      it 'delivers correct directions for black side player' do
        moves = game.pawn_moves([1, 7])
        expect(moves).to eql([[1, 6], [1, 5]])
      end
    end

    context 'white player, enemy piece is diagonal on either corner, and ahead' do
      it 'returns diagonal one as only option' do
        moves = game.pawn_moves([2, 6])
        expect(moves).to eql([[1, 7], [3, 7]])
      end
    end
  end

  describe '#find_check' do
    context 'white king is threatened by black queen' do
      before do
        game.next_turn.pieces.pieces[:queen][:position] = ['c', 3]
        game.current_turn.pieces.pieces[:pawn4][:position] = ['d', 4]
      end

      it 'returns true' do
        check = game.find_check
        expect(check).to be true
      end
    end
  end
end
