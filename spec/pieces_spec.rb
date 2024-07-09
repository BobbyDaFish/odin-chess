# frozen-string-literal: true

require_relative 'pieces'

describe Pieces do # rubocop:disable Metrics/BlockLength
  before do
    allow(game_pieces).to receive(:new).and_return({})
  end

  subject(:game_pieces) { described_class.new('black') }

  describe '#initialize' do
    # the #new method does not need testing. Test the called methods.
  end

  describe '#create_pieces' do
    # script method, test the piece creation methods
  end

  describe '#create_knights' do
    before do
      allow(game_pieces).to receive(:move_calc).and_return(['a', 1])
    end

    it 'returns a hash for the knight piece' do
      knights = game_pieces.create_knights('black', %w[a b], {})
      expect(knights).to include(:left_knight)
    end
  end

  describe '#create_king' do
    before do
      allow(game_pieces).to receive(:move_calc).and_return(['a', 1])
    end

    it 'returns a hash for the king piece' do
      king = game_pieces.create_king('black', %w[a b])
      expect(king).to be_a(Hash).and include(:icon)
    end
  end
end
