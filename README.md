# rsync-backup

This is a Linux/Unix backup program to remotely back up Unix filesystems using rsync over SSH. It has grown from simpler versions that have been in continuous use in several deployments since 2002.

It minimizes disk space used for files that didn't change since the previous snapshot by means of the `rsync --link-dest` option for informal snapshots made of hardlink clones, and native filesystem snapshots using btrfs and zfs.

The program is typically run once or twice daily from a cron job.

This repository also includes sample configuration files and many associated scripts for testing, management, and maintenance.
