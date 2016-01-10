nagios_check_all_open_files
=======================

This is a Nagios-check which verify all open files against a threshold.

Installation
--------------
Add the following to the sudoers file to grand permissions to lsof. This can also be done for the nagios user.

```
Cmnd_Alias NRPE_CHECK_ALL_OPEN_FILES = /sbin/lsof

nrpe    ALL=(ALL) NOPASSWD: NRPE_CHECK_ALL_OPEN_FILES
```

Usage
-------
```
./check_all_open_files.sh <WARNING-Value> <CRITICAL-Value>
```
Example:
```
./check_all_open_files.sh 10000 12000
```
