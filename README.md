## Usage

To run the script simply run:

`$ ./trello_automation.sh <board_url> [<members_list_file_path>]`

#####Arguments:

  1. `<board_url>` is a mandatory argument: it is just a copy-paste `http://...` URL of the board you want to clone for other members.
  2. `<members_list_file_path>` is an optional argument - if not given, the specified board will be copied once and the copy will be entitled `<original_title> - copy`. If the argument is specified, the original board will be cloned for each member.

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

The script will iterate over each line of this file and create a clone of the original board with the title in form `<original_title> - <member_name>`.

##Closing boards:

You can also close chosen boards by running:

`$ ./trello_automation.sh close_all_but [filter]`

Valid [`filter`](https://trello.com/docs/api/member/index.html#get-1-members-idmember-or-username-boards) options are:

```
closed
members
open
organization
pinned
public
starred
unpinned
```

The default filter is `starred`.
The script will iterate over all open boards and leave out those filtered.

Example:

```
$ ./trello_automation.sh close_all_but pinned
```

This will close all boards but for the pinned ones, whereas this:

```
$ ./trello_automation.sh close_all_but
```

will close all boards but for the `starred` ones, which is the default filter.
