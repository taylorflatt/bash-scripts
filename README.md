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
A prune script which removes files in a directory older than a set number of days prior. This can be added to the crontab and run non-interactively with the -a flag on a backup directory to remove old backups.

###Usage
`./prune.sh -d DIRECTORY -n NUM_DAYS [-ah]`

###File Parameters
-d,--directory:   The directory from which files will be pruned.<br />
-n,--days:        Files modded prior to n days ago is subject to pruning. <br />
-a,--automated:   Runs the script without interaction and perform the least destructive operations. <br />
-h,--help:        Displays information on how to use the script in detail.

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

# [Install Launcher Icons](https://github.com/taylorflatt/bash-scripts/blob/master/install_desktop_icons.sh)
A script used to add \*.desktop and icons to the /usr/share/applications directory. If you're needing to roll out a few dozen applications for an image, this can help expedite the process by bringing all the files together and transferring them automatically (replacing any contents).

###Usage
`sudo ./install_launcher_icons.sh`

###File Parameters
None

###Examples
`sudo ./install_launcher_icons.sh` <br />
**Explanation:** Copies the \*.desktop files (if any) from launcher_desktop and nonlauncher_desktop directories to /usr/share/applications folder. In addition, it will copy *any* files in the local icons directory to /usr/share/applications/Icons/48x48 (can be changed at the top of the script).

###Notes:
- This must be run as sudo since it copies files into a permission locked zone (/usr/share/applications).
- The file structure is __IMPORTANT__ for this script to run properly. There must be a folder named launcher_desktop, nonlauncher_desktop, and icons in the local directory of the script. If any of them are not correctly placed, the script will error out and tell you which ones are not correct.
- There is an if-statement included that will narrow down the files that are copied in the icons directory if you so wish. You can add any others that you need to that as well. In my situation, it didn't matter. It might in yours.
- This program will overwrite a .desktop contained within /usr/share/applications if it differs from a local copy contained within either two local launcher directories. So if you have launcher_desktop/firefox.desktop differing from  /usr/share/applications/firefox.desktop then the former will overwrite the latter. Please take notice of this and make a backup of your /usr/share/applications directory if you are unsure.

# [Create Launcher Icons](https://github.com/taylorflatt/bash-scripts/blob/master/create_launcher_icons.sh)
A script used to add \*.desktop and icons to the /usr/share/applications directory. If you're needing to roll out a few dozen applications for an image, this can help expedite the process by bringing all the files together and transferring them automatically (replacing any contents).

###Usage
`sudo ./create_launcher_icons.sh`

###File Parameters
None

###Examples
`sudo ./create_launcher_icons.sh` <br />
**Explanation:** Adds any \*.desktops contained within the launcher_desktop directory to the launcher in Ubuntu (Unity).

###Notes:
- This must NOT be run as sudo since it uses gsettings which will save the settings for the user running the script. In fact, the script will not run as sudo.
- The file structure is __IMPORTANT__ for this script to run properly. There must be a folder named launcher_desktop in the local directory of the script. If it is not there, then it will not change the launcher icons whatsoever.
- Currently, this does not remove any launcher icons from the launcher.
- Uses gsettings to get and set the launcher.
- You can reset your launcher using `gsettings reset com.canonical.Unity.Launcher favorites`
