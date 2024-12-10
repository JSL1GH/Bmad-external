# CMake external example

## [main]

# Almost all CMake files should start with this
# You should always specify a range with the newest
# and oldest tested versions of CMake. This will ensure
# you pick up the best policies.
cmake_minimum_required(VERSION 3.1...3.29)

# This is your project statement. You should always list languages;
# Listing the version is nice here since it sets lots of useful variables
project(
  ModernCMakeExternalExample
  VERSION 1.0
  LANGUAGES C CXX Fortran)

#https://bb.cgd.ucar.edu/cesm/threads/porting-test-build-failed-when-im-trying-to-port-cesm1_2_2.2864/
#ENABLE_LANGUAGE(Fortran)

#This for ExternalProject_Add

include(ExternalProject)

# If you set any CMAKE_ variables, that can go here.
# (But usually don't do this, except maybe for C++ standard)

set(BUILD_DIR ${CMAKE_CURRENT_SOURCE_DIR})
cmake_path(GET CMAKE_CURRENT_SOURCE_DIR PARENT_PATH THE_PARENT_PATH)

set(CMAKE_INSTALL_PREFIX ${THE_PARENT_PATH}/${CMAKE_INSTALL_EXTERNAL_PREFIX})

# create the name of the global include file - with all the definitions!
set(GLOBAL_VARIABLE_FILE ${THE_PARENT_PATH}/global/GlobalVariables.cmake)


message (STATUS "Global variable file is ${GLOBAL_VARIABLE_FILE}")
message (STATUS "CMAKE_INSTALL_PREFIX variable file is ${CMAKE_INSTALL_PREFIX}")

#return()

#include(/Users/jlaster/modern-cmake-master/examples/global1/GlobalVariables.cmake)
include (${GLOBAL_VARIABLE_FILE})

get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
message (STATUS "In external-project/Value of global variable is '${GLOBAL1}'")

#JSL - COMMENTING OUT 11/5/2024 - needed?
#set_property (GLOBAL PROPERTY LIST_OF_PATHS /Users/jlaster/.bmad_external1)
set_property (GLOBAL PROPERTY LIST_OF_PATHS ${CMAKE_INSTALL_PREFIX})

# hdf5 is supported by h5cc - and it has its own special path (though maybe not when I place in .bmad_external directory)
# I also found this CMake check for hdf5 -  https://cmake.org/cmake/help/latest/module/FindHDF5.html

#option(BUILD_FGSL "Build FGSL" ON)
#option(BUILD_HDF5 "Build HDF5, if needed" ON)
#option(BUILD_LAPACK95 "Build LAPACK95" ON)
#option(BUILD_PLPLOT "Build PLplot" ON)
#option(BUILD_XRAYLIB "Build xraylib" ON)

#return()

#first test list(APPEND EXT_LIBS boost fetch lapack h5cc)
#list(APPEND EXT_LIBS boost lapack h5cc plplot)
#list(APPEND EXT_LIBS h5cc boost lapack plplot)
#list(APPEND EXT_LIBS h5cc lapack plplot gsl fgsl)
#list(APPEND EXT_LIBS h5cc lapack plplot gsl fgsl lapack95 )
list(APPEND EXT_LIBS h5cc lapack plplot gsl fgsl-1.6.0 fgsl-1.5.0 fgsl-1.4.0 lapack95 xraylib)
#list(APPEND EXT_LIBS gsl fgsl-1.6.0 fgsl-1.5.0 fgsl-1.4.0)
#list(APPEND EXT_LIBS xraylib)

#list(APPEND EXT_LIBS hdf5)

message( STATUS "CMAKE_PROJECT_NAME is ${CMAKE_PROJECT_NAME} - and PROJECT_NAME = ${PROJECT_NAME}" )

set_property(GLOBAL PROPERTY EXTERNALTEST ALL_GOOD)
set_property(GLOBAL PROPERTY GLOBALTEST TRUE1)

# this allows us to find packages in paths that we specify - alternate paths from the system!
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)

	message(STATUS "invoked locally (building external packages - whichever ones are not available)")
	
	foreach( PACKAGE IN ITEMS ${EXT_LIBS} )

#	foreach(PACKAGE boost nextboost)

		set (VAR1 ${PACKAGE})

		if (${PACKAGE} STREQUAL "h5cc")
			message(STATUS "Package is h5cc - checking if we have hdf5 instead")
#			install_package(${VAR1})
			set (VAR1 "hdf5")
		endif()
		
		message(STATUS "(In CMakeLists.txt) now testing for ${VAR1}")

#       this worked for finding lapack!		
#		find_package(${PACKAGE} PATHS  /Users/jlaster/bmad/bmad-ecosystem/production/lib/cmake/lapack-3.12.0 CONFIG)
#		find_package(${PACKAGE} PATHS  /Users/jlaster/bmad/bmad-ecosystem/production/lib CONFIG)
#       It looks like this is enough for it to find the package lapack - 
#		find_package(${PACKAGE} PATHS /Users/jlaster/bmad/bmad-ecosystem/production CONFIG)
#       but not hdf5?
#		find_package(${PACKAGE} PATHS /Users/jlaster/bmad/bmad-ecosystem/production /Users/jlaster/bmad/bmad-ecosystem/production/lib /Users/jlaster/bmad/bmad-ecosystem/hdf5/production CONFIG)

#		find_package(${VAR1} PATHS /Users/jlaster/bmad/bmad-ecosystem/production /Users/jlaster/bmad/bmad-ecosystem/hdf5/production /Users/jlaster/.bmad_external /Users/jlaster/.bmad_external/lib /Users/jlaster/.bmad_external/bin /Users/jlaster/.bmad_external/hdf5 /Users/jlaster/.bmad_external/hdf5/hdf5 /Users/jlaster/.bmad_external/bin/config CONFIG)


		
		set (PACKAGE_TEST_NAME ${VAR1})
		if (${VAR1} STREQUAL "hdf5")
			#special test for hdf5
			set (PACKAGE_TEST_NAME "HDF5")
	 		find_package(HDF5 COMPONENTS Fortran)
		else()
#			find_package(${VAR1} PATHS /Users/jlaster/bmad/bmad-ecosystem/production /Users/jlaster/bmad/bmad-ecosystem/hdf5/production /Users/jlaster/.bmad_external /Users/jlaster/.bmad_external/lib /Users/jlaster/.bmad_external/bin /Users/jlaster/.bmad_external/hdf5 /Users/jlaster/.bmad_external/hdf5/hdf5 /Users/jlaster/.bmad_external/bin/config CONFIG)
			find_package(${VAR1} PATHS ${LIST_OF_PATHS} CONFIG)
		endif()

		if ( ${PACKAGE_TEST_NAME}_FOUND )
			message(STATUS "${VAR1} was found - continuing")
		else()
		
			message (STATUS "Did not find package ${VAR1} - building" )


			# let's check if we have the package in our local bmad area - ~/.bmad_external
			
			
			message (STATUS "Building package ${VAR1}")
			
			if (${PACKAGE} STREQUAL "h5cc")
				message(STATUS "Package is h5cc - attempting to install hdf5 instead")
#				install_package(${VAR1})
				set (VAR1 "hdf5")

			else()	
#				install_package(${VAR1})
					
			endif()
			
			message (STATUS "Now attempting to install packages ${VAR1}")			
			install_package(${VAR1})
			


#at this point, I think the rest was not correct - because the install (just above) doesn't happen until the 'make' is executed!

#			# now that we build the package, we check again to see if it is now found - if it is great, if not, we really have to give up at this point
#			message (STATUS "ARE WE GOOD - AT A")
##			find_package(${PACKAGE} PATHS /Users/jlaster/bmad/bmad-ecosystem/production /Users/jlaster/bmad/bmad-ecosystem/hdf5/production CONFIG)
#			find_package(${PACKAGE} PATHS /Users/jlaster/bmad/bmad-ecosystem/production /Users/jlaster/bmad/bmad-ecosystem/hdf5/production /Users/jlaster/.bmad_external /Users/jlaster/.bmad_external/lib /Users/jlaster/.bmad_external/bin /Users/jlaster/.bmad_external/${path}/${path} CONFIG)
#
##			FindHDF5(
#			message (STATUS "ARE WE GOOD - AT B")
#
#			if ( ${PACKAGE}_FOUND )
#				message(STATUS "Newly installed ${PACKAGE} is now found - excellent = continuing")
#			else()
##				message (FATAL_ERROR "After attempt to install package '${PACKAGE}', we still cannot find it\nPlease seek further assistance\nExiting...")
#				message (STATUS "After attempt to install package '${PACKAGE}', we still cannot find it\nPlease seek further assistance\nExiting...")
#				message (STATUS "For now, allowing to continue, even thought should be FATAL")
#			endif()
#
#			
#			set_property(GLOBAL PROPERTY EXTERNALTEST PROBLEM)




#		    return()
#		message(FATAL_ERROR "${PACKAGE} not everything is installed - quitting")

		endif()

	endforeach()


	# a final check to make sure everything built?
	
#	message ( STATUS "Encountered a problem when working to make sure we have all the packages we need")
#	message ( FATAL_ERROR "Stopping external package install - Please examine issues ...")
#jsl	message ( FATAL_ERROR "\nEncountered a problem when working to make sure we have all the packages we need\n" "Stopping external package install - Please examine issues ...")

else()

	message(STATUS "in progress")
#	message(STATUS "invoked from outer (ensuring external packages are available)")
#
##list(APPEND EXT_LIBS boost nextboost)
#
#message(STATUS "value of libs is ${EXT_LIBS}")
#
##set(EXT_LIBSS "")
#
#foreach( PACKAGE IN ITEMS ${EXT_LIBS} )
##foreach(PACKAGE boost nextboost)
#	set (VAR1 ${PACKAGE})
#	message(STATUS "now testing for ${VAR1}")
#	find_package(${PACKAGE} CONFIG)
#	if ( ${PACKAGE}_FOUND )
#		message(STATUS "${PACKAGE} was found - continuing")
#	else()
#	    set_property(GLOBAL PROPERTY EXTERNALTEST PROBLEM)
#	    return()
##		message(FATAL_ERROR "${PACKAGE} not everything is installed - quitting")
#	endif()
#endforeach()

return()



	

# Find packages go here.
find_package(boost CONFIG)
message(STATUS "In find_package for boost")
if ( boost_FOUND ) 
        message(STATUS "boost was found - continuing")
#        set_property(GLOBAL PROPERTY VAR1 TRUE)
        set_property(GLOBAL PROPERTY GLOBALTEST TRUE1)
#        get_property(VAR1 DIRECTORY external-project) 
#		set(VAR1 TRUE)
#		get_property(avalue GLOBAL PROPERTY "${VAR1}" )
		get_property(GLOBALRESULT GLOBAL PROPERTY GLOBALTEST)
#		message ( "avalue Value of VAR1 is '${VAR1}'" )
		message ( "avalue Value of VAR1 is '${GLOBALRESULT}'" )
else()
        message(STATUS "boost not found")

        message("Or use this as an opportunity to install boost - local or global")

#jsl       message(FATAL_ERROR "this is considered a fatal error - quitting")
        
        
#        return()
endif()

find_package(lapack CONFIG)

if ( lapack_FOUND )
        message(STATUS "lapack was found - continuing")
        
else()
        message(STATUS "lapack not found")

        message("Or use this as an opportunity to install lapack - local or global")

#       message(FATAL_ERROR "this is considered a fatal error - quitting")
        
        
        return()
endif()


# You should usually split this into folders, but this is a external example

# This is a "default" library, and will match the *** variable setting.
# Other common choices are STATIC, SHARED, and MODULE
# Including header files here helps IDEs but is not required.
# Output libname matches target name, with the usual extensions on your system
#add_library(MyLibExample external_lib.cpp external_lib.hpp)

# Link each target with other targets or add options, etc.

# Adding something we can run - Output name matches target name
#add_executable(MyExample external_example.cpp)

# Make sure you link your targets with this command. It can also link libraries and
# even flags, so linking a target that does not exist will not give a configure-time error.
#target_link_libraries(MyExample PRIVATE MyLibExample)

## [main]

# This part is so the Modern CMake book can verify this example builds. For your code,
# you'll probably want tests too
enable_testing()
add_test(NAME MyExample COMMAND MyExample)


endif()
