# -*- coding: utf-8 -*-
require 'trello_automation/board_duplicator'

class TrelloAutomation
  def start(arg)
    board_duplicator = BoardDuplicator.new
    case arg[0]
    when nil
      puts "You must specify at least one argument!"
      return
    when 'authorize'
      Authorization.authorize
      puts "Authorization successful, you can use the script now."
    when 'close_all_but'
      board_duplicator.close_boards(arg[1] ||= 'starred')
    # elsif arg.include?('subscribe')
      # puts "Yeah you're here in subscribe."

    when 'copy'
      puts "\nCreating board copy..."
      board_duplicator.call(arg[1])
    when 'clone'
      puts "You didn't specify members the clones should be made for. " \
      "Perhaps you wanted to 'copy' rather than 'clone'?" if arg[2].nil?
      board_url = arg[1]
      members_list_path = arg[2]
      if members_names = names(members_list_path)
        members_names.each do |full_member_name, trello_nickname|
          board_duplicator.call(board_url,
                                trello_nickname: trello_nickname,
                                full_member_name: full_member_name)
        end
      end
    end
  end

  private

  def names(members_list_path)
    return false if members_list_path.nil?
    names = []
    File.open(members_list_path, encoding: 'utf-8').each do |line|
      /^(?<full_member_name>.*)<(?<trello_nickname>.*)>$/ =~ line
      names << [full_member_name, trello_nickname]
    end
    # p names #> [["John Doe ", "johnny"], ["Lorem Ipsum ", "cicero"]]
    names
  end
end
