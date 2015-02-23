require 'trello_automation/authorization'
require 'json'

class BoardDuplicator
  def call(board_url, options = {})
    # p options #>  {:member_nickname=>"johnny", :full_member_name=>"John Doe "}
    Authorization.authorize
    board, board_users_copy = get_boards_array(board_url, options)
    board_users_copy.lists.each { |list| list.close! }
    board.lists.reverse.each do |list|
      @done_list = list if list.name =~ /done/i
      list_copy = Trello::List.create(name: list.name, board_id: board_users_copy.id)
      list.cards.reverse.each do |card|
        Trello::Card.create(name: card.name,
                            list_id: list_copy.id,
                            desc: card.desc)
      end
    end
    # p board_users_copy.lists.map(&:name).any? { |e| e =~ /done/i }
    # p board_users_copy.lists.find()
    # p board_users_copy.lists.pluck(:name).include?(/done/i)
    subscribe_me_to_users_done_list(@done_list, board_users_copy.id, options[:full_member_name])
    add_member(board_users_copy.id, options[:member_nickname]) if options[:member_nickname]
  end

  private

  def get_boards_array(board_url, options = {})
    board = Trello::Board.find(board_token(board_url))
    board_subname = options[:full_member_name] || 'copy'
    board_users_copy = Trello::Board.create(name: "#{board.name} - #{board_subname}",
                                      organization_id: board.organization_id)
    [board, board_users_copy]
  end

  def board_token(board_url)
    %r{.*trello.com/b/(?<token>.*)/.*} =~ board_url
    # %r{.*trello.com/b/(?<token>.*)/.*} =~ 'https://trello.com/b/khsx7Ez1/tat'
    token
  end

  def close_boards(client, array_with_tokens)
    array_with_tokens.each do |token|
      if client.get("/boards/#{token}").include?("closed\":true") == false
        client.put("/boards/#{token}", {closed: true})
        puts "Closed board #{token}."
      else
        puts "Board #{token} already closed."
      end
    end
  end

  def subscribe_me_to_users_done_list(done_list, board_id = '', member = '')
    if done_list
      subscribe_member(done_list.id)
    else
      done_list = Trello::List.create(name: 'Done', board_id: board_id)
      subscribe_member(done_list.id)
    end
    puts "You have been subscribed to the list '#{done_list.name}' of user #{member.strip}."
    p done_list.board_id
  end

  def add_member(board_id, member_nickname)
    client = Trello.client
    member = Trello::Member.find(member_nickname)
    path = "/boards/#{board_id}/members/#{member.id}"
    client.put(path, type: 'normal')
  end

  def subscribe_member(done_list_id)
    client = Trello.client
    path = "/lists/#{done_list_id}/subscribed"
    client.put(path, value: true)
    open_boards_tokens = []
    # %r{.*trello.com/b/(?<token>.*)/.*} =~ client.get("/members/me/boards").to_hash
    JSON.parse(client.get('/members/me/boards', filter: 'open', fields: 'shortLink' )).each { |e| open_boards_tokens << e['shortLink'] }
    # .scan(/(?<="name":")(.{8})/).flatten
    # puts open_boards_tokens
    2.times { open_boards_tokens.delete_at(0) }
    close_boards(client, open_boards_tokens)

    # boards = Trello::Board.find("DSLZcAdN").attributes[:closed]
    # p boards
    # p client.put(path, value: true) #> "{\"id\":\"54e73d680cab5d847df6ad59\",\"name\":\"done\",\"closed\":false,\"idBoard\":\"54e73d659d32fdbcee6b73ab\",\"pos\":8192}"
  end
end


# close a board: client.put("/boards/xdJ6Icuq", {closed: true})
