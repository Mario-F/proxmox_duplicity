# Standalone Duplicity / Duply backup with vzdump

### 1
Create a working duply config under /etc/duply/pve_{HOSTNAME} and make sure it works.
The "Source" directory for Duply should refer to your vzdump backup storage.<br />
Hint: Because the backup files from vzdump will be very large in scope of duplicity make some test and read optimizations further down.

### 2
Put the vz_hook.pl script under /opt/

### 3
Configure vzdump.conf in /etc/ to utilize the vz_hook.pl script

### 4
Edit the vz_hook.pl script to fit your backup strategy. Variables: <br />
$duply_config: Duply config name, use default naming by hostname (better portability) or choose your own.
$duply_backup: Duply backup string to execute, please refer to the [duply docs](http://duply.net/wiki/index.php/Duply-documentation)

## Optimizations

#### VzDump and hook scripts
In the actual Version of Proxmox(4.3-3) if a vzdump hook script exit with error (Code > 0) the message is successfull after all, so think of checking your duplicity backups regular or establish external checks with nagios for instance.

#### Backup directory
To prevent Duply from backup unfinished vzdumps (.tmp for example) or other garbage you can create a exclude file under the Duply config folder to include only valid filenames and exclude all other.
Example (DuplyConfig/exclude):<br />
```
+ **.gz
+ **.lzo
+ **.vma
+ **.tar
- **
```

#### Duplicity options

##### TMP Files
Mind the hint in duply config under "TMP_DIR" that this dir should have more free space than the largest file you want to restore.<br />
I would recommend to activate the "ARCH_DIR" option, this will speedup your incremental backups.

##### DUPL_PARAMS
I recommend two parameters to set in the "DUPL_PARAMS" at the end of duply config, we use this in production and get good results going with theese.<br />
"--asynchronous-upload": Is marked as experimental by duplicity but we never had any problem with it (Used: rsync, ftp, sftp, local), this will utilize your bandwidth efficiently.<br />
"--max-blocksize 262144": Because vzdump files will be many gigabyte this will increase the rsync scan for file changes resulting in faster diff creating (faster incremental backup) but slightly bigger filesize.