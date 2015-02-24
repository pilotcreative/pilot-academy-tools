require 'trello_automation/authorization'
require 'json'
LISTS_TO_SUBSCRIBE_TO = ['Done'] # case insensitive

class BoardDuplicator
  def call(board_url, options = {})
    # p options #>  {:trello_nickname=>"johnny", :full_member_name=>"John Doe "}
    Authorization.authorize
    original_board = find_board(board_url)
    cloned_board_id = clone_board(original_board, options[:full_member_name])
    subscribe_me_to_chosen_lists_in(cloned_board_id)
    add_member(cloned_board_id, options[:trello_nickname]) if options[:trello_nickname]
  end

  def close_boards(filter = '')
    Authorization.authorize
    tokens_of_boards_to_close = []
    leave_out(filter).each { |e| tokens_of_boards_to_close << e['shortLink'] }
    tokens_of_boards_to_close.each do |token|
      closed_board = JSON.parse(client.put("/boards/#{token}", closed: true))
      name = closed_board['name']
      url = closed_board['url']
      puts "Closed board #{name}, URL: #{url}."
    end
  end

  private

  def find_board(board_url)
    Trello::Board.find(board_token(board_url))
  end

  def clone_board(original_board, clone_name)
    clone_name ||= 'copy'
    name = "#{original_board.name} - #{clone_name}".strip
    cloned_board = client.post('/boards', name: name, idBoardSource: original_board.id)
    puts "Created a copy of #{original_board.name} with the name #{name}."
    JSON.parse(cloned_board)['id']
  end

  def close_default_lists_in(board)
    board.lists.each { |list| list.close! }
  end

  def clone_lists_from_to(original_board, cloned_board_id)
    original_board.lists.each do |list|
      client.post('/lists', name: list.name, idBoard: cloned_board_id, pos: 'bottom')
    end
  end

  def leave_out(filter)
    (all_boards('open') - all_boards(filter))
  end

  def all_boards(filter)
    JSON.parse(client.get('/members/me/boards', filter: filter, fields: 'shortLink' ))
  end

  def board_token(board_url)
    %r{.*trello.com/b/(?<token>.*)/.*} =~ board_url
    token
  end

  def subscribe_me_to_chosen_lists_in(cloned_board_id)
    cloned_board = Trello::Board.find(cloned_board_id)
    cloned_lists = {}
    client.find(:board, cloned_board_id).lists.map do |list|
      cloned_lists[list.name.downcase] = list.id
    end
    LISTS_TO_SUBSCRIBE_TO.each do |list|
      if cloned_lists.keys.include?(list.downcase)
        subscribe_member(cloned_lists[list.downcase])
        puts "You have been subscribed to the list #{list} in the board #{cloned_board.name}."
      else
        new_list_id = JSON.parse(client.post("/boards/#{cloned_board_id}/lists", name: list, pos: 'bottom' ))['id']
        subscribe_member(new_list_id)
        puts "You have been subscribed to the newly created list #{list} in the board #{cloned_board.name}."
      end
    end

    # (&:name).map(&:downcase)

    # p list_names

    # subscribe_to = (LISTS_TO_SUBSCRIBE_TO & list_names)
    # client.find(:board, cloned_board_id).lists
    # subscribe_to.each { |list_id| subscribe_member(list_id) }

    # create_and_subscribe_to = LISTS_TO_SUBSCRIBE_TO - list_names
    # if create_and_subscribe_to.any?
    #   create_and_subscribe_to.each do |list_name|
    #     new_list_id = JSON.parse(client.post("/boards/#{cloned_board_id}/lists", name: list_name, pos: 'bottom' ))['id']
    #     subscribe_member(new_list_id)
    #   end
    # end

    # else
    #   done_list = Trello::List.create(name: 'Done', board_id: board_id)
    #   subscribe_member(done_list.id)
    # end
    # p done_list.board_id
  end

  def add_member(board_id, trello_nickname)
    member = Trello::Member.find(trello_nickname)
    client.put("/boards/#{board_id}/members/#{member.id}", type: 'normal')
    board_name = client.find(:board, board_id).name
    puts "Member #{trello_nickname} has been added to the board #{board_name}."
  end

  def subscribe_member(done_list_id)
    client.put("/lists/#{done_list_id}/subscribed", value: true)
  end

  def client
    client ||= Trello.client
  end
end
