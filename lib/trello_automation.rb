# -*- coding: utf-8 -*-
require 'trello_automation/board_duplicator'

class TrelloAutomation

  def start
    bd = BoardDuplicator.new
    bd.call('https://trello.com/b/Fqvqdqeo/workshop-4-ruby',
            member_name: 'psulkowski',
            full_member_name: 'Paweł Sułkowski')
  end
end
