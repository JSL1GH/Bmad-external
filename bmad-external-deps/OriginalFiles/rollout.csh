#!/bin/tcsh

echo "Running rollout"

if ( "$1" == "" ) then
    echo "Please pass in the name of the directory for rollout"
    exit
else
    echo "Using directory name $1"

    if (! -d $1) then
	echo "Directory $1 must exist - exiting"
	exit
    else
 	echo "verified directory $1 exists - continuing with rollout"

	set c=`ls -a $1 | wc | awk '{print $1}'`
  	 # IS dir is empty
   	if ( "${c}" == 2 ) then 
	    echo "Empty directory - $1 - continuing"
    	else 	#dir has files
	    echo "Dir has files - "$1
            echo "Directory must be empty for rollout - exiting"
	    exit
    	endif
    endif
endif

# Here we assume we have copied everything we need into ~/bmad_project/OriginalFiles
set rolloutdir = "$HOME/bmad_project/OriginalFiles"

if (! -d $rolloutdir) then
    echo "Rollout directory $rolloutdir must exist - exiting"
    exit
else
    echo "verified rollout directory $rolloutdir exists - continuing with rollout"
endif

echo "Creating necessary directories"

set basedir = "$1/bmad_world"
echo "Creating $basedir"
mkdir $basedir

foreach dir (global external_project .bmad_external)
    set createdir = "$basedir/$dir"
    echo "Creating $createdir"
    mkdir $createdir
end

# handle global
echo "Copying GlobalVariables.cmake from $rolloutdir/GlobalVariables.cmake to $basedir/global"
cp -p $rolloutdir/GlobalVariables.cmake $basedir/global

# handle external_project
foreach filetocopy (mycmake.csh myclean.csh CMakeLists.txt LAPACK95_CMakeLists.txt)
    echo "Copying from $rolloutdir/$filetocopy to $basedir/external_project"
    cp -p $rolloutdir/$filetocopy $basedir/external_project
end

# handle .bmad_external

#mkdir $1/bmad_world/global
#mkdir $1/bmad_world/external_project

echo "Copying over needed files from $rolloutdir/bmad-external-deps to $1/bmad_world/external_project"
cp -pr  $rolloutdir/bmad-external-deps $1/bmad_world/external_project

echo "cd into directory for build"
cd $1/bmad_world/external_project

echo "Performing cmake"
./mycmake.csh

echo "Performing make"
make

echo "Finished with rollout"

