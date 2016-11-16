# proxmox_duplicity
Scripts for backup proxmox virtual machines with duplicity<br />
A German StepByStep Tutorial is available under: [blog.tincit.de](https://blog.tincit.de/series/duplicity-duply-mit-proxmoxve-vzdump/)<br />

# Description
This Howto will help to store your ProxmoxVE Backups to an offsite storage location with duplicity in a encrypted and bandwidth efficient way.

## Compressor
Default compressor with ProxmoxVE is lzop but it is not very rsync friendly and will lead to bigger incremental backups than necessary.
You can either going with "RAW" or "GZIP" backups, this depends on the storage backup you have locally.
If you pick GZIP for compression i would advice to install and use pigz for that task and enable it in the vzdump.conf file because of its multicore features and much faster compression towards the default gzip.

## Filenaming
By default ProxmoxVE vzdump backups have a timestring in there name, this prevents duplicity and common backuptools from making incremental backups because the files are identified by filename.
Because of this we need a vzdump hook script that gives the backup files a common name.

## Strategy
There are multiple ways of triggering the duplicity backup.

#### 1. Execute duplicity on job-end in the vzdump hook script.
This is the easiest and cleanest way of backup because we can use the notification system of vzdump for our duplicity output, but for this strategy the backup target should be located on a local or fast storage.
The big disadvantage is that vzdump keep a global-lock so all other backups have to wait till the complete task includes duplicity upload is finished.<br />
See [examples/standalone](examples/standalone/)

#### 2. Execute duplicity external
This is a good solution if you have for example many ProxmoxVE Servers and a backup server that can run duplicity on its one.<br />
Scripts coming soon.

## Duplicity / Duply
For ease of use i utilize duply as a duplicity managment tool. Please refer to the docs:<br />
[Duplicity](http://duplicity.nongnu.org/)<br />
[Duply](http://duply.net/)

# Example usage
This is some example data from my own private ProxmoxVE Server and the reason why i did use this kind off backup.
At the Server location i only have a 10 Mbit connection but i wanted daily backups off all my virtual machines and did not like to bother with piking importend machines over not so importend machines for backup at different times.
Goal was to backup all virtual machines once daily to an offsite location and the results are:
- Making a Fullbackup once a week with 27GB in 8 Hours
- Rest of the week making incremental Backups around 1-2GB in under a hour
