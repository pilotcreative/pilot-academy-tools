## Usage

To clone board, run:

`ruby -Ilib bin/trello_automation "board_url"`

To clone board for every member on a list

* create members list first, format:
 
John Doe <jdoe>
Lorem Ipsum <lipsum>
 
* run:

`ruby -Ilib bin/trello_automation "board_url" "path_to_members_list"`