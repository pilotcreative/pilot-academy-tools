# -*- coding: utf-8 -*-
require 'trello_automation/board_duplicator'

class TrelloAutomation
  def start(arg)
    board_duplicator = BoardDuplicator.new
    board_url, members_list_path = arg
    if members_names = names(members_list_path)
      members_names.each do |full_member_name, member_nickname|
        board_duplicator.call(board_url,
                              member_nickname: member_nickname,
                              full_member_name: full_member_name)
      end
    else
      board_duplicator.call(board_url)
    end
  end

  private

  def names(members_list_path)
    return false if members_list_path.nil?
    names = []
    File.open(members_list_path, encoding: 'utf-8').each do |line|
      /^(?<full_member_name>.*)<(?<member_nickname>.*)>$/ =~ line
      names << [full_member_name, member_nickname]
    end
    # p names #> [["John Doe ", "johnny"], ["Lorem Ipsum ", "cicero"]]
    names
  end
end
