require 'rails_helper'

describe GamesController, type: :request do
  let(:default_items_list) { GamesController::DEFAULT_ITEMS_LIST }
  let(:custom_items_list) { '0, 1, 2, 3, 4' }
  let(:converted_items_list) { %w[0 1 2 3 4] }

  describe '#index' do
    it 'assigns items list' do
      get root_path

      expect(response).to be_successful
      expect(@controller.view_assigns['items_list']).to eq default_items_list
    end

    it 'assigns custom items list' do
      get root_path(items_list: custom_items_list)

      expect(response).to be_successful
      expect(@controller.view_assigns['items_list']).to eq converted_items_list
    end
  end

  describe '#new' do
    let(:result) { 'Draw!' }
    let(:throw_service_double) { double(:ThrowService, call: result, errors: [], server_throw: server_throw) }

    let(:user_throw) { items_list.first }
    let(:server_throw) { items_list.first }
    let(:items_list) { default_items_list }

    before do
      allow(ThrowService).to receive(:new).with(user_throw, items_list).and_return(throw_service_double)
    end

    it 'calls throw servuce' do
      get new_game_path(user_throw:)

      expect(response).to be_successful
      expect(@controller.view_assigns['items_list']).to eq GamesController::DEFAULT_ITEMS_LIST
      expect(@controller.view_assigns['result']).to eq result
    end
  end
end
