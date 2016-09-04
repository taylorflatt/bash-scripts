# bash-backup-script
Simple bash script I use to run scheduled backups in Linux.

Usage: ./backup.sh SOURCE DEST [-d]

Source: The location of the file/directory that will be backed up.
Dest: The location in which the backed up data will end up.
-d: Optional parameter to include the name in the dest name (if backing up a directory) or the file name (if backing up a single file). This helps retain extra daily logs or files rather than simply overwriting the file.

I might expand upon this in the future.
