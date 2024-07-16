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
        allow(game).to receive(:possible_moves).and_return([['c', 2], ['c', 3]])
        allow(game).to receive(:gets).and_return('c', '3')
      end

      it 'returns the selection of a valid move' do
        move = game.choose_move(['c', 2])
        expect(move).to eql(['c', 3])
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
