#!/usr/bin/perl -w

use strict;
use File::Basename;
use File::Copy;
use File::stat;
use POSIX qw(strftime);
use Sys::Hostname;

my $phase = shift;
my $host = hostname;

# Configuration
my $duply_config 	= "pve_$host"; # Name of the duply config, defaults to "pve_hostname";
my $duply_backup 	= "backup+purge_cleanup_status --force"; # This will do a duply backup with purge to cleanup outdated backups and prints status at end

if ($phase eq 'job-start' ||
    $phase eq 'job-end'  ||
    $phase eq 'job-abort') {

    my $dumpdir = $ENV{DUMPDIR};
    my $storeid = $ENV{STOREID};
	
	# Check if duply is configured
	if ($phase eq 'job-start') {
		if(system("/usr/bin/duply /etc/duply/$duply_config status") > 0) {
			print "There was an error looking up status from duply backup!\n";
			exit(1);
		}
	}

	# Start duplicity backup on job-end
    if ($phase eq 'job-end') {
        if(system("/usr/bin/duply /etc/duply/$duply_config $duply_backup") > 0) {
			print "Failed to execute external Backup! $!";
			exit(1);
		}
    }

} elsif ($phase eq 'backup-start' ||
         $phase eq 'backup-end' ||
         $phase eq 'backup-abort' ||
         $phase eq 'log-end' ||
         $phase eq 'pre-stop' ||
         $phase eq 'pre-restart' ||
         $phase eq 'post-restart') {

    my $mode = shift; # stop/suspend/snapshot
    my $vmid = shift;
    my $vmtype = $ENV{VMTYPE}; # openvz/qemu
    my $dumpdir = $ENV{DUMPDIR};
    my $storeid = $ENV{STOREID};
    my $hostname = $ENV{HOSTNAME};
    my $tarfile = $ENV{TARFILE};
    my $logfile = $ENV{LOGFILE};
	
	# Deletes the logfile to prevent pollution of the dump dir. Checks filesize to avoid deleting wrong files by accident
	if ($phase eq 'log-end') {
		if(stat($logfile)->size < 5048576) {
			unlink $logfile or die "Delete logfile failed!";
		} else {
			die "Logfile is to big, really a logfile? $logfile";
		}
	}

    # Rename the resulting backupfile to an common name without timestamp. ! Overwrites the last backup
    if ($phase eq 'backup-end') {
        my @exts = qw(.tar.gz .vma.gz .tar.lzo .vma.lzo .tar .vma);
        my ($fname, $fdir, $fext) = fileparse($tarfile, @exts) or die "Error getting file $!";
        my $upFilename = "vzdump-${vmtype}-${vmid}_${hostname}${fext}";

        print "Copy file to $dumpdir\n";
        move("$tarfile", "$dumpdir/$upFilename") or die "Move failed: $!";
        print "Copy finished, Filename: $upFilename\n";
    }
}

exit (0);
