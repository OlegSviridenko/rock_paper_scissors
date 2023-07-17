# frozen_string_literal: true
require 'pry'

class GamesController < ApplicationController
  DEFAULT_ITEMS_LIST = %w[rock paper scissors].freeze
  before_action :set_items_list

  def index; end

  def new
    @throw_service = ThrowService.new(params[:user_throw], @items_list)
    @result = @throw_service.call
  end

  private

  def set_items_list
    custom_list = params[:items_list]&.split(',')&.map(&:strip)

    if custom_list.nil? || custom_list.empty?
      @items_list ||= DEFAULT_ITEMS_LIST
    else
      @items_list = custom_list
    end
  end
end
