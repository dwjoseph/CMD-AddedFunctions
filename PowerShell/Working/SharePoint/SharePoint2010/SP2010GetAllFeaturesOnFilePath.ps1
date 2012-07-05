﻿## SharePoint Server: Using PowerShell to list all Feature IDs and Feature Titles on a File System Path

# Specify the directory path/s where your features are that you want to list

# For SharePoint / MOSS 2007

cd "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\12\TEMPLATE\FEATURES"

# For SharePoint Server 2010

cd "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\14\TEMPLATE\FEATURES"

gci -recurse -filter  feature.xml | % { $contents=get-content $_.fullname; $x=[XML]$contents; "{0} {1}" -f $x.Feature.Id, $x.feature.title }