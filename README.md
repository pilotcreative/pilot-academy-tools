## Usage

To run the script, simply type and enter:

`$ ./trello_automation.sh <board_url> [<members_list_file_path>]`

#####Arguments:

  1. `<board_url>` is a mandatory argument: it is just a copy-paste `http://...` URL of the board you want to clone for other members.
  2. `<members_list_file_path>` is an optional argument - if not given, the specified board will be copied once and the copy will be entitled "Original Name - copy". If the argument is specified, the original board will be cloned for every member.

#####Example:

`$ ./trello_automation.sh https://trello.com/b/vlQMjo8k/trello-automation member_list`

In this case, `member_list` is a file in the home directory of the project, i.e. where the file `trello_automation.sh` sits (this path is relative).

## The `member_list` file

The `member_list` file can be given any name and extension (including none as in this example), but it has to be kept strictly in the following form:

```
Member Name <member_trello_nickname>
John Doe <jdoe>
Lorem Ipsum <lipsum>
```

The script will iterate over each line of this file and create a clone of the original board with the title in form "Original Board's Name - Member's Name".
