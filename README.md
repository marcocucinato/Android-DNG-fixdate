# Android-DNG-fixdate
## Fix the timestamps in DNG files gnerated by the Android Camera2 API

This is a Perl / ExifTool script to fix the files created by the Android Camera2 DNG API.

the API has a bug, causing the creation Timestamp to be set at the instance creation and not at the image capture time:
[Issue 157238:	Incorrect Date on DNG Images from Camera2 API](https://code.google.com/p/android/issues/detail?id=157238)

I included the Perl source and a W32 executable created with pp (PAR Packager).

For usage instructions, execute the script with -h or --help options.
