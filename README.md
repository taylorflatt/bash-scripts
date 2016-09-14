# Bash Scripts
These are simply a collection of scripts that I use personally. Use with caution. I am not accountable for what you do with them.

# [Backup Script](https://github.com/taylorflatt/bash-scripts/blob/master/backup.sh)
Simple bash script I use to run scheduled backups in Linux.

**Usage**: `./backup.sh -s SOURCE -d DEST [-t]`

###File Parameters
-s:   The location of the file/directory to be backed up.<br />
-d:   The remote storage location of the files specified with the -s parameter.<br />
-t:   (Optional) Includes a date in the resulting filename (if single file) or directory.

###Examples
`./backup.sh -s /opt/myProgram/data -d /mnt/share/myBackup/myProgram` <br />
**Explanation:** Run a backup of the /opt/myProgram/data folder saving it in the /mnt/share/myBackup/myProgram <br />

`./backup.sh -d /mnt/share/myBackup/myProgram -t -s /opt/myProgram/data` <br />
**Explanation:** Run a backup of the same folder and save it in the same location as above but time stamp the directory. <br />

###Notes
- If using the -t parameter on a directory, only the root directory will be given the timestamp. The files contained within will not contain the timestamp.

# [Prune Script](https://github.com/taylorflatt/bash-scripts/blob/master/prune.sh)
A prune script which removes files in a directory older than a set number of days prior.

###Usage
`./prune.sh -d DIRECTORY -n NUM_DAYS [-a]`

###File Parameters
-d,--directory:   The directory from which files will be pruned.<br />
-n,--days:        Files modded prior to n days ago is subject to pruning. <br />
-a,--automated:   Runs the script without interaction and perform the least destructive operations.

###Examples
`./prune.sh -d /opt/backup -n 30` <br />
**Explanation:** Runs a prune on the /opt/backup directory and remove files (or directories) last modified over 30 days ago.

`./prune -n 2 --directory /opt/backup --automated` <br />
**Explanation:** Runs a prune on the /opt/backup directory and removes files (or directories) last modified 2 days ago without prompts.

###Notes:
- This will not remove the CWD if that is ever possible (it should not be).
- This cannot be run as sudo/root to help reduce the risk of undetermined behavior.
- Running the script in an automated fashion will always leave AT LEAST ONE file left (newest file) in the backup directory.
- Running the script with prompts will ask for confirmation for each delete to be made.
- This deletes both files AND directories.
