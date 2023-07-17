class ThrowService
  attr_accessor :items_list, :server_throw, :user_throw, :errors

  def initialize(user_throw, items_list)
    @user_throw = user_throw
    @items_list = items_list
    @server_throw = nil
    @errors = []
  end

  def call
    validate_items_list unless items_list == GamesController::DEFAULT_ITEMS_LIST
    validate_user_throw
    return if errors.any?

    @server_throw = make_server_throw
    return 'Draw!' if server_throw == user_throw

    humanize_result(determine_result)
  end

  private

  def validate_items_list
    validate_items_list_count
    validate_items_list_structure
  end

  def make_server_throw
    response = RestClient::Request.execute(method: :get, url: request_url, timeout: 10, open_timeout: 10)
    response['statusCode'].to_i == 200 && items_list.include?(response['body']) ? response['body'] : random_throw
  rescue
    random_throw
  end

  def determine_result
    server_throw_index = items_list.reverse.index(server_throw)

    first_index_of_winning_option = server_throw_index - (items_list.size / 2)
    calculate_result(first_index_of_winning_option, server_throw_index)
  end

  def humanize_result(result)
    result == true ? 'You win!' : 'You lose!'
  end

  def calculate_result(first_index_of_winning_option, server_throw_index)
    if first_index_of_winning_option.negative?
      # Find all losing variants and make sure that user throw not in it
      !items_list.reverse[(server_throw_index + 1)...first_index_of_winning_option].include?(user_throw)
    else
      # Find all winning variants and make sure that user throw in it
      items_list.reverse[first_index_of_winning_option...server_throw_index].include?(user_throw)
    end
  end

  def random_throw
    items_list[rand(0...items_list.size)]
  end

  def validate_items_list_count
    errors << wrong_items_count_error if items_list.size.even? || items_list.size < 3
  end

  def validate_items_list_structure
    errors << wrong_items_list_structure_error if items_list.tally.values.any? { |count| count > 1 }
  end

  def validate_user_throw
    errors << wrong_user_throw_error unless items_list.include?(user_throw)
  end

  def wrong_user_throw_error
    'Wrong user choice'
  end

  def wrong_items_list_structure_error
    'Wrong custom items list, duplicate item found'
  end

  def wrong_items_count_error
    'Wrong number of items, should be more than 3 and odd number'
  end

  def request_url
    'https://5eddt4q9dk.execute-api.us-east-1.amazonaws.com/rps-stage/throw'
  end
end
