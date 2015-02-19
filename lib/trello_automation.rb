# -*- coding: utf-8 -*-
require 'trello_automation/board_duplicator'

class TrelloAutomation
  def start(arg)
    bd = BoardDuplicator.new
    board_url = arg[0]
    members_list_path = arg[1]
    if members_list_path
      names(members_list_path).each do |full_member_name, member_name|
        bd.call(board_url,
                member_name: member_name,
                full_member_name: full_member_name)
      end
    else
      bd.call(board_url)
    end
  end

  private

  def names(members_list_path)
    names = []
    File.open(members_list_path, encoding: 'utf-8').each do |line|
      /^(?<full_member_name>.*)<(?<member_name>.*)>$/ =~ line
      names << [full_member_name, member_name]
    end
    names
  end
end
