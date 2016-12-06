# Genome Research Bash Scripts

# [cDir](https://github.com/taylorflatt/bash-scripts/blob/master/Genome/cDir.sh)
Creates the file structure necessary to separate the experiments between test sets.

**Usage**: `./cDir.sh TEST_SET_NUM TEST_NUM`

###Examples
`./cDir.sh 1 1` <br />
**Explanation:** Creates the Scripts, Data, and Log folders for Test 1 from Test Set 1.<br />

###Notes
- This actually creates two folders primarily. It creates the Logs folder which will contain the error/output logs and the Scripts folder which contains the config.txt.
- This will not overwrite any folders and errors if it encounters existing folders. It only creates the structure if it can complete successfully.

# [tCreate](https://github.com/taylorflatt/bash-scripts/blob/master/Genome/tCreate.sh)
Creates the specific test by reading the config.txt and generating the assembly.sh file. It then adds the job to the scheduler.

**Usage**: `./tCreate.sh TEST_SET_NUM TEST_NUM`

###Examples
`./tCreate.sh 1 1` <br />
**Explanation:** Creates the assembly.sh script based off the config.txt for Test 1 from Test Set 1. After successful creation, it adds the job to the scheduler for processing.<br />

###Notes
- This will not create the proper file structure so cDir needs to be run prior to this or else the script will fail.
- This assumes that the config.txt is located in the Scripts folder created by cDir.sh.

# [tCheck](https://github.com/taylorflatt/bash-scripts/blob/master/Genome/tCheck)
Checks specified jobs to determine if they completed successfully.

**Usage**: `./tCheck.sh TEST_SET_NUM FIRST_TEST LAST_TEST`

###Examples
`./tCheck.sh 1 1 5` <br />
**Explanation:** Checks Test 1 to Test 5 from Test Set 5 and will determine if they exist, have started, or are still running.<br />

###Notes
- This won't necessarily catch a job that has completed but has errored out.

# [tFinish](https://github.com/taylorflatt/bash-scripts/blob/master/Genome/tFinish)
Moves the output of the specified range of jobs to an output directory.

**Usage**: `./cFinish.sh TEST_SET_NUM FIRST_TEST LAST_TEST`

###Examples
`./tFinish.sh 1 1 5` <br />
**Explanation:** Moves the outputs (CTG/SCF/POSMAP) for Test 1 to Test 5 from Test Set 1 to an output directory.<br />

###Notes
- This will only grab jobs who have created the output files. If they don't exist, then the program will not copy them. It doesn't go any further. It doesn't check if the job is currently running so there isn't a way for it to know if it is still running or errored out. You'll have to check this yourself.
