# Bash Scripts
These are simply a collection of scripts that I use personally. Use with caution. I am not accountable for what you do with them.

# [Backup Script](https://github.com/taylorflatt/bash-scripts/blob/master/backup.sh)
Simple bash script I use to run scheduled backups in Linux.

Usage: `./backup.sh -s SOURCE -d DEST [-t]`

-s: The location of the file/directory to be backed up.
-d: The remote storage location of the files specified with the -s parameter.
-t: (Optional) Includes a date in the resulting filename (if single file) or directory.

# [Prune Script](https://github.com/taylorflatt/bash-scripts/blob/master/prune.sh)
A prune script which removes files in a directory older than a set number of days prior.

Usage `./prune.sh -d DIRECTORY -n NUM_DAYS [-a]`

-d,--directory: The directory from which files will be pruned.
-n,--days: Files last modified before this date are subject to pruning. In other words, if n=30 then files older than 30 days are to be pruned.
-a,--automated: Runs the script without interaction and perform the least destructive operations.

Runs a prune on the /opt/backup directory and remove files (or directories) last modified over 30 days ago.
Example: `./prune.sh -d /opt/backup -n 30`

Runs a prune on the /opt/backup directory and removes files (or directories) last modified 2 days ago without messages (or prompts).
Example: `./prune -n 2 --directory /opt/backup --automated`

Notes:
-This will not remove the CWD if that is ever possible (it should not be).
-This cannot be run as sudo/root to help reduce the risk of undetermined behavior.
-Running the script in an automated fashion will always leave AT LEAST ONE file left (newest file) in the backup directory.
-Running the script with prompts will ask for confirmation for each delete to be made.
-This deletes both files AND directories.
