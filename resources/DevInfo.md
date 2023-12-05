To reverse engineer the ID string required for an action (requires a Macbook):

1. Create a shortcut with the desired action
2. Open terminal, navigate to `~/Library/Shortcuts`, run `sqlite3 shortcuts.sqlite`
3. (Optional) To make reading output a bit easier, we will make the output to a separate
    CSV File.
    i. `.mode csv`
    ii. `.output t.csv` // whatever else you want to name your file
4. `select * from zshortcut;`
5. Read the above output, find the shortcut with the name you want, and get its `Z_PK` (primary key)
6. `select * from zshortcutactions where Z_PK = $Z_PK_FROM_ABOVE`
7. Read the output; the required string will be in here somewhere.