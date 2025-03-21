# CMake external example

## [main]

message("Add the following to cmake build line for debug information to be printed out '-DCMAKE_PRINT_DEBUG=True'")
message("Default installation area set to $ENV{HOME}/bmad/external - user may override by specifying '-DCMAKE_INSTALL_PREFIX=/full/dir/path/to/bmad_external_package_directory'")

# Almost all CMake files should start with this
# You should always specify a range with the newest
# and oldest tested versions of CMake. This will ensure
# you pick up the best policies.
cmake_minimum_required(VERSION 3.1...3.20)


#if(NOT DEFINED CMAKE_INSTALL_PREFIX})

#  message(STATUS "CMAKE IS NOT DEFINED")
#elseif()
#  message(STATUS "CMAKE IS DEFINED")


#endif()


# allow for a flag to have build libraries placed in their own separate directories - rather than
# globbed into one big directory of lib/bin/include
# I did this only because I initially coded it this way - was easy to just leave in place
# in case a user thinks it is more clean and would like it this way
# -CMAKE_SEPARATE_DIRS=true


#if(NOT DEFINED ${CMAKE_INSTALL_PREFIX})

#  message(STATUS "CMAKE IS NOT DEFINED")
#elseif()
#  message(STATUS "CMAKE IS DEFINED")


#endif()


# This is your project statement. You should always list languages;
# Listing the version is nice here since it sets lots of useful variables
project(
  ModernCMakeExternalExample
  VERSION 1.0
  LANGUAGES C CXX Fortran)


message("Set it")
#set(CMAKE_INSTALL_PREFIX "$ENV{HOME}/bmad/external" CACHE PATH "Default directory for Bmad external project installation")
#set(CMAKE_INSTALL_PREFIX "A value")
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  message(STATUS "In routine of check for CMAKE_INSTALL_PREFIX - was not set!")
#  SET(CMAKE_INSTALL_PREFIX "/path/to/subdir" CACHE PATH "install prefix" FORCE)
endif(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
message("After set it")

#https://bb.cgd.ucar.edu/cesm/threads/porting-test-build-failed-when-im-trying-to-port-cesm1_2_2.2864/
#ENABLE_LANGUAGE(Fortran)

#This for ExternalProject_Add

if(NOT DEFINED ${CMAKE_INSTALL_PREFIX})

  message(STATUS "CMAKE IS NOT DEFINED")
elseif()
  message(STATUS "CMAKE IS DEFINED")


endif()

include(ExternalProject)

# If you set any CMAKE_ variables, that can go here.
# (But usually don't do this, except maybe for C++ standard)



option(BUILD_SHARED_LIBS "Build using shared libraries" ON)

#set_property(GLOBAL PROPERTY BMAD_BUILD_SHARED_LIBS "ON") 

#set(BUILD_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_ROLLOUT_CMAKE_FILES ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(CMAKE_BINARY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/build")

set(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR})

#if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
#if(DEFINED CMAKE_PRINT_DEBUG)
if(DEFINED CMAKE_INSTALL_PREFIX)
    message(STATUS "BUILD DIRECTORY IS ${BUILD_DIR}")
    message(STATUS "cmake launched from ${CMAKE_CURRENT_BINARY_DIR}")
endif()


#cmake_path(GET CMAKE_CURRENT_SOURCE_DIR PARENT_PATH THE_PARENT_PATH)
get_filename_component(THE_PARENT_PATH ../ ABSOLUTE)


#set(CMAKE_INSTALL_PREFIX ${THE_PARENT_PATH}/${CMAKE_INSTALL_EXTERNAL_PREFIX})
#set(CMAKE_INSTALL_PREFIX ${THE_PARENT_PATH})

if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    message (STATUS "User has decided to set '${CMAKE_INSTALL_PREFIX}' as the installation area")
endif()

#set(CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_EXTERNAL_PREFIX})

# create the name of the global include file - with all the definitions!
#set(GLOBAL_VARIABLE_FILE ${THE_PARENT_PATH}/global/GlobalVariables.cmake)
#set(GLOBAL_VARIABLE_FILE ${BUILD_DIR}/GlobalVariables.cmake)
set(GLOBAL_VARIABLE_FILE ${CMAKE_ROLLOUT_CMAKE_FILES}/GlobalVariables.cmake)

# if install path exists, make sure user supplied a "continue_install" flag - otherwise, abort
if (EXISTS "${CMAKE_INSTALL_PREFIX}")
   
   # IF VALUE IS /usr/local, it means user did not supply a value - CMAKE DEFAULTS TO /usr/local!
   # therefore, we continue as if user supplied a value of $ENV{HOME}/bmad/external
   if (${CMAKE_INSTALL_PREFIX} STREQUAL "/usr/local")
      message("User did not set a value (or set a value of '/usr/local)' for CMAKE_INSTALL_PREFIX - defaulting to $ENV{HOME}/bmad/external")
      set(CMAKE_INSTALL_PREFIX $ENV{HOME}/bmad/external)
      # now check again to see if the new value we just set - exists 
      if (EXISTS "${CMAKE_INSTALL_PREFIX}")
         # did user supply force 
	    if(CUSER_FORCE)
	    #      message (STATUS "Directory path '${CMAKE_INSTALL_PREFIX}' already exists - user supplied force option! ('-force')")
	          message (STATUS "Directory path '${CMAKE_INSTALL_PREFIX}' already exists - user supplied force option! ('-force') - continuing and building into it")
	else()
            message (FATAL_ERROR "Directory path '${CMAKE_INSTALL_PREFIX}' already exists - please modify or supply a build flag to override - in order continue installation ('-DCUSER_FORCE=true)...cancel'")
#       message (FATAL_ERROR "Directory path")
#       message(FATAL_ERROR "Missing required file: important_file.txt")
#    cmake_exit(-1) # not available in our version of cmake (3.25 or later)

          endif()
      endif()
   else()
      message("User has set a value of {CMAKE_INSTALL_PREFIX}")
   endif()


endif()

#if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
if(CMAKE_PRINT_DEBUG)
    message (STATUS "Global variable file is ${GLOBAL_VARIABLE_FILE}")
    message (STATUS "CMAKE_INSTALL_PREFIX variable file is ${CMAKE_INSTALL_PREFIX}")
endif()

#return()

#include(/Users/jlaster/modern-cmake-master/examples/global1/GlobalVariables.cmake)
if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    message (STATUS "Including a file that has all of our global definitions - '${GLOBAL_VARIABLE_FILE}'")
endif()

include (${GLOBAL_VARIABLE_FILE})

get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
message (STATUS "In external-project/Value of global variable (EXTERNAL_BMAD_DIRECTORY) is '${GLOBAL1}'")

#JSL - COMMENTING OUT 11/5/2024 - needed?
#set_property (GLOBAL PROPERTY LIST_OF_PATHS /Users/jlaster/.bmad_external1)
#JSL - COMMENTING OUT ON 1/14/2025 - does this help find it?
#set_property (GLOBAL PROPERTY LIST_OF_PATHS ${CMAKE_INSTALL_PREFIX})

set( LIST_OF_PATHS ${CMAKE_PREFIX_PATH})
#set_property (GLOBAL PROPERTY LIST_OF_PATHS ${CMAKE_PREFIX_PATH})

# hdf5 is supported by h5cc - and it has its own special path (though maybe not when I place in .bmad_external directory)
# I also found this CMake check for hdf5 -  https://cmake.org/cmake/help/latest/module/FindHDF5.html

option(BUILD_FGSL "Build FGSL" OFF)
option(BUILD_HDF5 "Build HDF5, if needed" OFF)
option(BUILD_LAPACK "Build LAPACK" OFF)
option(BUILD_LAPACK95 "Build LAPACK95" OFF)
option(BUILD_PLPLOT "Build plplot" OFF)
option(BUILD_XRAYLIB "Build xraylib" OFF)
option(BUILD_FFTW "Build fftw" OFF)
option(BUILD_OPENMPI "Build openmpi" OFF)
option(BUILD_ALL "Build all" "OFF")

message(STATUS "CMakeLists.txt - status of build_all is ${BUILD_ALL}")


#return()

#first test list(APPEND EXT_LIBS boost fetch lapack h5cc)
#list(APPEND EXT_LIBS boost lapack h5cc plplot)
#list(APPEND EXT_LIBS h5cc boost lapack plplot)
#list(APPEND EXT_LIBS h5cc lapack plplot gsl fgsl)
#list(APPEND EXT_LIBS h5cc lapack plplot gsl fgsl lapack95 )
#list(APPEND EXT_LIBS h5cc lapack plplot gsl fgsl )


#list(APPEND EXT_LIBS h5cc lapack plplot gsl fgsl lapack95 xraylib)
#list(APPEND EXT_LIBS gsl fgsl)
#list(APPEND EXT_LIBS fgsl)

#list(APPEND EXT_LIBS h5cc lapack plplot fgsl lapack95 xraylib)
#list(APPEND EXT_LIBS lapack95)

#list(APPEND EXT_LIBS plplot)


#list(APPEND EXT_LIBS h5cc lapack plplot gsl fgsl-1.6.0 fgsl-1.5.0 fgsl-1.4.0 lapack95 xraylib)
#HERE
#JSL
#list(APPEND EXT_LIBS h5cc lapack plplot gsl fgsl-1.6.0 fgsl-1.5.0 fgsl-1.4.0)
#list(APPEND EXT_LIBS lapack lapack95 xraylib)


#list(APPEND EXT_LIBS gsl fgsl-1.6.0 fgsl-1.5.0 fgsl-1.4.0 fgsl)
#list(APPEND EXT_LIBS gsl fgsl)
#list(APPEND EXT_LIBS xraylib)

#list(APPEND EXT_LIBS hdf5)

#list(APPEND EXT_LIBS h5cc lapack plplot fgsl lapack95 xraylib)
#list(APPEND EXT_LIBS h5cc lapack plplot fftw openmpi fgsl lapack95 xraylib)
list(APPEND EXT_LIBS h5cc lapack plplot fftw fgsl lapack95 xraylib)

#list(APPEND EXT_LIBS lapack)


message( STATUS "CMAKE_PROJECT_NAME is ${CMAKE_PROJECT_NAME} - and PROJECT_NAME = ${PROJECT_NAME}" )

set_property(GLOBAL PROPERTY EXTERNALTEST ALL_GOOD)
set_property(GLOBAL PROPERTY GLOBALTEST TRUE1)
set_property(GLOBAL PROPERTY BUILD_AT_LEAST_ONE 0)

# this allows us to find packages in paths that we specify - alternate paths from the system!
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)

	message(STATUS "invoked locally (building external packages - whichever ones are not available)")
	

	# first go through all of our libraries that we handle and see if any are set
	# if BUILD_ALL is set, we BUILD_ALL
	# if none are set, we assume BUILD_ALL
	# if one are more are set (and BUILD_ALL is not), we do not assume BUILD_ALL, and build only those requested
	set_property(GLOBAL PROPERTY BUILD_AT_LEAST_ONE 0)
#	set_property (BUILD_AT_LEAST_ONE 0)
	message(STATUS "1 Value of BUILD_AT_LEAST_ONE is ${BUILD_AT_LEAST_ONE}")
	foreach( PACKAGE IN ITEMS ${EXT_LIBS} )
	   should_build_package(${PACKAGE} retval)
	   message(STATUS "after_should_build_package ${package} - Value of BUILD_AT_LEAST_ONE is ${BUILD_AT_LEAST_ONE}")
	endforeach()
	get_property(MY_LOC_AT_LEAST_1 GLOBAL PROPERTY BUILD_AT_LEAST_ONE)

	message(STATUS "2 Value of BUILD_AT_LEAST_ONE is ${MY_LOC_AT_LEAST_1}")
	if (${MY_LOC_AT_LEAST_1} EQUAL 0)
	   message(STATUS "Found no libraries requested to build - user must want to build all of them.")
#	   message(FATAL_ERROR "Found no libraries requested to build - user must want to build all of them.")
	   set (BUILD_ALL "ON")	
	endif()

	foreach( PACKAGE IN ITEMS ${EXT_LIBS} )

	# only build the package if BUILD_ON is true for the package or BUILD_ALL is true)
	# this doesn't seem to make sense - we only get to this point if the package is
	# in the EXT_LIBS list
	# so let's just check if the BUILD_ON is set for the package or BUILD_ALL is set
	set (retval 0)
	message (STATUS "1. value of should_build - ${PACKAGE} - in CMakeLists.txt is - ${retval}")
	should_build_package(${PACKAGE} retval)
	message (STATUS "2. value of should_build - ${PACKAGE} in CMakeLists.txt is - ${retval}")
	if (${retval} STREQUAL "NO")
	   continue() # skip the rest of the foreach loop for this iteration
	endif()

#	foreach(PACKAGE boost nextboost)

#jsl - add targerts		addtarget_
#          add_target(${PACKAGE})

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
		elseif (${VAR1} STREQUAL "xraylib")
			#special test for hdf5
			message (STATUS "Looking for package 'xraylib' using find_package in paths ${LIST_OF_PATHS}")
#			find_package(xrl PATHS ${LIST_OF_PATHS} CONFIG)
#  FIND_PACKAGE(LIBXRL REQUIRED)
#  INCLUDE_DIRECTORIES(${LIBXRL_INCLUDE_DIR})
#  SET(LINK_DIRECTORIES ${LIBXRL_LIBRARIES})
 # IF(NOT LIBXRL_INCLUDE_DIR)
 #   MESSAGE("xraylib not found! Please install xraylib and make it available in PATH or manually set the LIBXRL_LIBRARY and LIBXRL_INCLUDE variables.")
 # else()
 #  message("xraylib found1")
 # ENDIF()

#find_package(MyLib)

#if(MyLib_FOUND)
#    # Use the found library
#    target_link_libraries(MyProject ${MyLib_LIBRARIES})
#    target_include_directories(MyProject PRIVATE ${MyLib_INCLUDE_DIRS})
#endif()



#			find_package(xrl PATHS ${LIST_OF_PATHS} CONFIG)
#			find_package(xrl  MODULE)
#			if ( xrl_FOUND )
#			   message(STATUS "xrl was found - continuing")
#			else()
#			   message(STATUS "Did not find xrl - looking for xraylib")
#			   find_package(xraylib PATHS ${LIST_OF_PATHS} CONFIG)
			   find_package(xraylib MODULE)
#			endif()
		elseif (${VAR1} STREQUAL "plplot")
			#special test for hdf5
			message (STATUS "Looking for package 'plplot' using find_package in paths ${LIST_OF_PATHS}")
#			find_package(plplot MODULE)

		else()
#			find_package(${VAR1} PATHS /Users/jlaster/bmad/bmad-ecosystem/production /Users/jlaster/bmad/bmad-ecosystem/hdf5/production /Users/jlaster/.bmad_external /Users/jlaster/.bmad_external/lib /Users/jlaster/.bmad_external/bin /Users/jlaster/.bmad_external/hdf5 /Users/jlaster/.bmad_external/hdf5/hdf5 /Users/jlaster/.bmad_external/bin/config CONFIG)
			message (STATUS "Looking for package '${VAR1}' using find_package in paths ${LIST_OF_PATHS}")
			find_package(${VAR1} PATHS ${LIST_OF_PATHS} CONFIG)
		endif()

		set (NEED_TO_INSTALL_PACKAGE 0)


		if ( ${PACKAGE_TEST_NAME}_FOUND )
			message(STATUS "${VAR1} was found - continuing")
			if (${CMAKE_INSTALL_ANYWAY})
			   message(STATUS "Installing ${VAR1} anyway - that is, we found the package, but laying down code to build anyway")
			   set(NEED_TO_INSTALL_PACKAGE 1)
			endif()
		else()
		
			message (STATUS "Did not find package ${VAR1} - building" )
			set(NEED_TO_INSTALL_PACKAGE 1)

		endif()

# testing - JSL
#		set (NEED_TO_INSTALL_PACKAGE 0)
#		message (STATUS, "For now, not installing anything - just setting need to install to 0")

		if (${NEED_TO_INSTALL_PACKAGE})

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
