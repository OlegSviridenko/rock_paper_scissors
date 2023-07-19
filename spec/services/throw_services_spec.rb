require 'rails_helper'

describe ThrowService do
  subject { described_class.new(user_throw, items_list) }

  let(:curb_response) { { 'statusCode': 200, 'body': server_throw } }

  let(:default_items_list) { %w[rock paper scissors'] }

  let(:user_throw) { default_items_list.first }
  let(:items_list) { default_items_list }
  let(:server_throw) { default_items_list.last }

  let(:response) { subject.call }
  let(:errors) { subject.errors }

  let(:win) { 'You win!' }
  let(:lose) { 'You lose!' }
  let(:draw) { 'Draw!' }

  before do
    stub_const('GamesController::DEFAULT_ITEMS_LIST', default_items_list)
    allow(RestClient::Request).to receive(:execute).and_return(curb_response)
  end

  context 'validate items list' do
    context 'with even number of items' do
      let(:items_list) { default_items_list + ['hammer'] }

      it 'should raise invalid items count error' do
        expect(response).to be nil
        # All errors Should be moved to i18n.
        expect(subject.errors).to include('Wrong number of items, should be more than 3 and odd number')
      end
    end

    context 'with number of items less then 3' do
      let(:items_list) { default_items_list[0..1] }

      it 'should raise invalid items count error' do
        expect(response).to be nil
        # All errors Should be moved to i18n.
        expect(subject.errors).to include('Wrong number of items, should be more than 3 and odd number')
        expect(subject).not_to receive(:make_server_throw)
      end
    end

    context 'with duplicated values in items list' do
      let(:items_list) { default_items_list + [default_items_list[0]] }

      it 'should raise invalid items count error' do
        expect(response).to be nil
        # All errors Should be moved to i18n.
        expect(subject.errors).to include('Wrong custom items list, duplicate item found')
        expect(subject).not_to receive(:make_server_throw)
      end
    end
  end

  context 'validate user throw' do
    let(:user_throw) { default_items_list.join }

    context 'user throw should be included in items list' do
      it 'should raise invalid items count error' do
        expect(response).to be nil
        # All errors Should be moved to i18n.
        expect(subject.errors).to include('Wrong user choice')
        expect(subject).not_to receive(:make_server_throw)
      end
    end
  end

  context 'make server throw' do
    let(:server_throw) { user_throw }

    it 'makes request to another service' do
      expect(response).to eq draw
      expect(subject.server_throw).to eq user_throw
    end

    context 'with invalid server crub response' do
      let(:curb_response) { { 'statusCode': 500 } }

      before { allow(subject).to receive(:random_throw).and_return(server_throw) }

      it 'makes random throw when request is invalid' do
        expect(response).to eq draw
        expect(subject.server_throw).to eq server_throw
      end
    end
  end

  context 'determine and humanize result' do
    let(:items_list) { %w[0 1 2 3 4 5 6 7 8] }
    let(:user_throw) { items_list[user_throw_index] }

    context 'without negative winning index condition(items list looping)' do
      let(:user_throw_index) { items_list.size / 2 }

      context 'user lose option' do
        let(:server_throw) { items_list[rand((user_throw_index + 1)...items_list.size)] }

        it 'when index of user throw is lower than server throw' do
          # Also should be moved to i18n
          expect(response).to eq lose
        end
      end

      context 'user win option' do
        let(:server_throw) { items_list[rand(0...user_throw_index)] }

        it 'when index of user throw is greater than server throw' do
          # Also should be moved to i18n
          expect(response).to eq win
        end
      end
    end

    context 'with negative winning index condition(items list looping)' do
      context 'user win option' do
        let(:user_throw_index) { 0 }
        let(:server_throw) { items_list.last }

        it 'when user throw in beginning and server throw in the end of items list' do
          expect(response).to eq win
        end
      end

      context 'user lose option' do
        let(:user_throw_index) { -1 }
        let(:server_throw) { items_list.first }

        it 'when user throw in the end of items list and server throw in beginning' do
          expect(response).to eq lose
        end
      end
    end
  end
end
