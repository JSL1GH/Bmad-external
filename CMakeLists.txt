# CMake external example

## [main]

  message("Add the following to cmake build line for debug information to be printed out '-DCMAKE_PRINT_DEBUG=True'")
  message("Default installation area set to $ENV{HOME}/bmad/external - user may override by specifying '-DCMAKE_INSTALL_PREFIX=/full/dir/path/to/bmad_external_package_directory'")

  cmake_minimum_required(VERSION 3.1...3.20)

#-DBUILD_FGSL=ON -DBUILD_HDF5=ON -DBUILD_LAPACK=ON -DBUILD_LAPACK95=ON -DBUILD_PLPLOT=ON -DBUILD_XRAYLIB=ON -DBUILD_FFTW=ON -DBUILD_OPENMPI=ON -DBUILD_ANYWAY=ON


# allow for a flag to have build libraries placed in their own separate directories - rather than
# globbed into one big directory of lib/bin/include
# I did this only because I initially coded it this way - was easy to just leave in place
# in case a user thinks it is more clean and would like it this way
# -CMAKE_SEPARATE_DIRS=true

  project(
    ModernCMakeExternalExample
    VERSION 1.0
    LANGUAGES C CXX Fortran
  )

#This for ExternalProject_Add
  include(ExternalProject)

  option(BUILD_SHARED_LIBS "Build using shared libraries" ON)
#set_property(GLOBAL PROPERTY BMAD_BUILD_SHARED_LIBS "ON") 
  set(CMAKE_ROLLOUT_CMAKE_FILES ${CMAKE_CURRENT_SOURCE_DIR})
  set(CMAKE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
  set(CMAKE_BINARY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/build")

  set(MESSAGE_FUNCTION_FILE ${CMAKE_ROLLOUT_CMAKE_FILES}/mymessage.txt)

  include (${MESSAGE_FUNCTION_FILE})

  set(GLOBAL_VARIABLE_FILE ${CMAKE_ROLLOUT_CMAKE_FILES}/GlobalVariables.cmake)

  set(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR})

  option(GLOBAL_CMAKE_MESSAGE_LEVEL, "message level for which messages are printed during cmake step - the lower the number, the more that is printed (1-5)")
  if (DEFINED GLOBAL_CMAKE_MESSAGE_LEVEL)
# use user supplied value
    set(GLOBAL_CMAKE_MESSAGE_LEVEL ${GLOBAL_CMAKE_MESSAGE_LEVEL})
#    DON"T CACHE IT!
    unset(GLOBAL_CMAKE_MESSAGE_LEVEL CACHE)
  else()
# no value supplied, use a level of 1
    set(GLOBAL_CMAKE_MESSAGE_LEVEL 1)
  endif()

  if (NOT ${GLOBAL_CMAKE_MESSAGE_LEVEL} STREQUAL 5)
    mymessage(1 STATUS "Value of GLOBAL_CMAKE_MESSAGE_LEVEL is ${GLOBAL_CMAKE_MESSAGE_LEVEL}")
  endif()
#set(CMAKE_INSTALL_PREFIX "$ENV{HOME}/bmad/external" CACHE PATH "Default directory for Bmad external project installation")
#set(CMAKE_INSTALL_PREFIX "A value")
  if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
     mymessage(5 STATUS "In routine of check for CMAKE_INSTALL_PREFIX - was not set!")
#  SET(CMAKE_INSTALL_PREFIX "/path/to/subdir" CACHE PATH "install prefix" FORCE)
#   SET(CMAKE_INSTALL_PREFIX "$ENV{HOME}/bmad/external")
#   message(STATUS "User did not supply a value for CMAKE_INSTALL_PREFIX - defaulting to user's home area")
  endif(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

  if (NOT CMAKE_BUILD_TYPE)
#    message(STATUS "value of build type is ${CMAKE_BUILD_TYPE}")
#    message(STATUS "Did not find a definition for cmake_build_type, setting it to Release")
    mymessage(4 STATUS "No value set for CMAKE_BUILD_TYPE - [Release|Debug] - setting to Release") 
    set(CMAKE_BUILD_TYPE Release)
  endif()

  mymessage(4 STATUS "VALUE OF CMAKE_INSTALL_PREFIX IS ${CMAKE_INSTALL_PREFIX} ")

#if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
#if(DEFINED CMAKE_PRINT_DEBUG)
  if(DEFINED CMAKE_INSTALL_PREFIX)
    mymessage(4 STATUS "BUILD DIRECTORY IS ${BUILD_DIR}")
    mymessage(4 STATUS "cmake launched from ${CMAKE_CURRENT_BINARY_DIR}")
  endif()


#cmake_path(GET CMAKE_CURRENT_SOURCE_DIR PARENT_PATH THE_PARENT_PATH)
  get_filename_component(THE_PARENT_PATH ../ ABSOLUTE)


#set(CMAKE_INSTALL_PREFIX ${THE_PARENT_PATH}/${CMAKE_INSTALL_EXTERNAL_PREFIX})
#set(CMAKE_INSTALL_PREFIX ${THE_PARENT_PATH})

#  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
  if(DEFINED CACHE{CMAKE_INSTALL_PREFIX})
    mymessage (2 STATUS "User has decided to set '${CMAKE_INSTALL_PREFIX}' as the installation area")
  endif()

#set(CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_EXTERNAL_PREFIX})

#set(CMAKE_BUILD_TYPE Release)
#if(DEFINED CMAKE_BUILD_TYPE)
#    message (STATUS "User has decided to set '${CMAKE_INSTALL_PREFIX}' as the installation area")
#    set (CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE})
#endif()

# create the name of the global include file - with all the definitions!
#set(GLOBAL_VARIABLE_FILE ${THE_PARENT_PATH}/global/GlobalVariables.cmake)
#set(GLOBAL_VARIABLE_FILE ${BUILD_DIR}/GlobalVariables.cmake)
  set(GLOBAL_VARIABLE_FILE ${CMAKE_ROLLOUT_CMAKE_FILES}/GlobalVariables.cmake)

# if install path exists, make sure user supplied a "continue_install" flag - otherwise, abort
  if (EXISTS "${CMAKE_INSTALL_PREFIX}")
   
   # IF VALUE IS /usr/local, it means user did not supply a value - CMAKE DEFAULTS TO /usr/local!
   # therefore, we continue as if user supplied a value of $ENV{HOME}/bmad/external
    if (${CMAKE_INSTALL_PREFIX} STREQUAL "/usr/local")
      mymessage(STATUS 2 "User did not set a value (or set a value of '/usr/local)' for CMAKE_INSTALL_PREFIX - defaulting to $ENV{HOME}/bmad/external")
      set(CMAKE_INSTALL_PREFIX $ENV{HOME}/bmad/external)
      # now check again to see if the new value we just set - exists 
      if (EXISTS "${CMAKE_INSTALL_PREFIX}")
         # did user supply force 
	if(CUSER_FORCE)
	    #      message (STATUS "Directory path '${CMAKE_INSTALL_PREFIX}' already exists - user supplied force option! ('-force')")
	  mymessage (4 STATUS "Directory path '${CMAKE_INSTALL_PREFIX}' already exists - user supplied force option! ('-force') - continuing and building into it")
	else()
          message (FATAL_ERROR "Directory path '${CMAKE_INSTALL_PREFIX}' already exists - please modify or supply a build flag to override - in order continue installation ('-DCUSER_FORCE=true)...cancel'")
#         message (FATAL_ERROR "Directory path")
#         message(FATAL_ERROR "Missing required file: important_file.txt")
#         cmake_exit(-1) # not available in our version of cmake (3.25 or later)

        endif()
      endif()
    else()
      mymessage(3 STATUS "User has set a value of ${CMAKE_INSTALL_PREFIX}")
    endif()
  else()   
    mymessage (2 STATUS "No value given for CMAKE_INSTALL_PREFIX - defaulting to $ENV{HOME}/bmad/external")
  endif()

  if(CUSER_FORCE)
#   message(STATUS "User has set a value for CUSER_FORCE of ${CUSER_FORCE}")   
  endif()

#if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
  if(CMAKE_PRINT_DEBUG)
    mymessage (5 STATUS "Global variable file is ${GLOBAL_VARIABLE_FILE}")
    mymessage (4 STATUS "CMAKE_INSTALL_PREFIX variable file is ${CMAKE_INSTALL_PREFIX}")
  endif()


  if (DEFINED CMAKE_PREFIX_PATH)
    set (CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH};${CMAKE_INSTALL_PREFIX})
#;${CMAKE_INSTALL_PREFIX}/lib)
  else()
#    set (CMAKE_PREFIX_PATH ${CMAKE_INSTALL_PREFIX};${CMAKE_INSTALL_PREFIX}/lib)
    set (CMAKE_PREFIX_PATH ${CMAKE_INSTALL_PREFIX})
  endif()

  mymessage(2 STATUS "CMAKE_PREFIX_PATH IS NOW ${CMAKE_PREFIX_PATH}")

  set(REQUIRE_OPENMP False)
  set(HAVE_OPENMP False)

  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    mymessage (4 STATUS "Including a file that has all of our global definitions - '${GLOBAL_VARIABLE_FILE}'")
  endif()

  include (${GLOBAL_VARIABLE_FILE})

  mymessage(3 STATUS "Building the project with a build type of ${CMAKE_BUILD_TYPE}")

#return()

  get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
  mymessage (4 STATUS "In external-project/Value of global variable (EXTERNAL_BMAD_DIRECTORY) is '${GLOBAL1}'")

#JSL - COMMENTING OUT 11/5/2024 - needed?
#set_property (GLOBAL PROPERTY LIST_OF_PATHS /Users/jlaster/.bmad_external1)
#JSL - COMMENTING OUT ON 1/14/2025 - does this help find it?
#set_property (GLOBAL PROPERTY LIST_OF_PATHS ${CMAKE_INSTALL_PREFIX})

#jsl - maybe needs to be CMAKE_MODULE_PATH?
#  set( LIST_OF_PATHS ${CMAKE_PREFIX_PATH})
#set(LIST_OF_PATHS ${CMAKE_MODULE_PATH})

set(LIST_OF_PATHS ${CMAKE_PREFIX_PATH})

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
#  option(BUILD_OPENMPI "Build with openmpi" OFF)
  option(BUILD_OPENMPI "Enable openmpi" OFF)
  option(BUILD_ALL "Build all" OFF)

  option(BUILD_ANYWAY "Build all packages - or the specified ones - even if they are available on the system!" OFF)

  option(OWN_FINDPACKAGE "Use our definition of find_package for non standard packages!" ON)

  if (DEFINED OWN_FINDPACKAGE )
# use user supplied value
    set(OWN_FINDPACKAGE ${OWN_FINDPACKAGE})
#    DON"T CACHE IT!
    unset(OWN_FINDPACKAGE CACHE)
  else()
# no value supplied, use a level of 5
    set(OWN_FINDPACKAGE ON)
  endif()

  option(OWN_FIND_ALL_PACKAGE "Use our definition of find_package - even if they are available on the system!" OFF)

  if (DEFINED OWN_FIND_ALL_PACKAGE )
# use user supplied value
    set(OWN_FIND_ALL_PACKAGE ${OWN_FIND_ALL_PACKAGE})
#    DON"T CACHE IT!
    unset(OWN_FIND_ALL_PACKAGE CACHE)
  else()
# no value supplied, use a level of 5
    set(OWN_FIND_ALL_PACKAGE OFF)
  endif()

  option(CHECK_FFTW_DEVEL "Check for fftw-devel" OFF)

#  mymessage(6 STATUS "here is my message")

  set(CMAKE_INSTALL_ANYWAY ${BUILD_ANYWAY})

  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    mymessage(3 STATUS "User has set a value for BUILD_ANYWAY to be ${CMAKE_INSTALL_ANYWAY}")
    mymessage(1 STATUS "If value is ON - packages will be built - no matter what")
  endif()
#return()

#return()
#list(APPEND EXT_LIBS h5cc lapack plplot fftw openmpi fgsl lapack95 xraylib)
  list(APPEND EXT_LIBS h5cc lapack plplot fftw fgsl lapack95 xraylib)

#message( STATUS "CMAKE_PROJECT_NAME is ${CMAKE_PROJECT_NAME} - and PROJECT_NAME = ${PROJECT_NAME}" )

  set_property(GLOBAL PROPERTY EXTERNALTEST ALL_GOOD)
  set_property(GLOBAL PROPERTY GLOBALTEST TRUE1)
  set_property(GLOBAL PROPERTY BUILD_AT_LEAST_ONE 0)

# this allows us to find packages in paths that we specify - alternate paths from the system!
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)

  if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
#	message(STATUS "invoked locally (building external packages - whichever ones are not available)")
    set_build_flags()

#   message(STATUS "JSL95 - value is ${REQUIRE_OPENMP}")

    # first go through all of our libraries that we handle and see if any are set
    # if BUILD_ALL is set, we BUILD_ALL
    # if none are set, we assume BUILD_ALL
    # if one are more are set (and BUILD_ALL is not), we do not assume BUILD_ALL, and build only those requested

    foreach( PACKAGE IN ITEMS ${EXT_LIBS} )
      package_map(${PACKAGE} package_name)

      if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
  #     message(STATUS "Checking BUILD_${package_name}")
      endif()
      if (NOT BUILD_${package_name})
        if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
          mymessage(3 STATUS "1. No need to build ${PACKAGE} ${package_name}")
        endif()
        continue()
      else()
        mymessage(3 STATUS "We need to build ${PACKAGE} ${package_name}")
        mymessage(5 STATUS "In install_package latest value of REQUIRE_OPENMP is ${REQUIRE_OPENMP}")
      endif()

      set (VAR1 ${PACKAGE})
      if (${PACKAGE} STREQUAL "h5cc")
        if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
          mymessage(5 STATUS "Package is h5cc - we will check for hdf5 instead")
#			install_package(${VAR1})
        endif()
        set (VAR1 "hdf5")
      endif()		
      mymessage(5 STATUS "(In CMakeLists.txt) now testing for ${VAR1}")

      set (PACKAGE_TEST_NAME ${VAR1})
      if (${VAR1} STREQUAL "hdf5")
	#special test for hdf5
	set (PACKAGE_TEST_NAME "HDF5")
	# if BUILD_ANYWAY, we do not test for find_package!
	if (${BUILD_ANYWAY} STREQUAL "OFF")
          #executing the find_package step yields this warning message
          #f951: Warning: ‘-Werror=’ argument ‘-Werror=format-security’ is not valid for Fortran
	  find_package(HDF5 COMPONENTS Fortran)
	endif()
      elseif (${VAR1} STREQUAL "xraylib")
      elseif (${VAR1} STREQUAL "plplot")
      else()
      endif()
    set (NEED_TO_INSTALL_PACKAGE 0)
    if ( ${PACKAGE_TEST_NAME}_FOUND )
      mymessage(3 STATUS "Using build-in cmake package search (not our custom 'Find' search) - ${VAR1} was found - continuing")
      if (${CMAKE_INSTALL_ANYWAY} STREQUAL "ON")
        mymessage(2 STATUS "Installing ${VAR1} anyway - that is, we found the package, but laying down code to build anyway")
        set(NEED_TO_INSTALL_PACKAGE 1)
      endif()
    else()
      mymessage (2 STATUS "We did did not find package (CMake built-in search - next will try to use our custom Find search) ${VAR1} - building" )
      set(NEED_TO_INSTALL_PACKAGE 1)
    endif()
    if (${NEED_TO_INSTALL_PACKAGE})
     # let's check if we have the package in our local bmad area - ~/.bmad_external
      mymessage (2 STATUS "Now our custom build package for ${VAR1}")
      if (${PACKAGE} STREQUAL "h5cc")
        mymessage(2 STATUS "Package is h5cc - attempting to install hdf5 instead")
	set (VAR1 "hdf5")
      else()	
      endif()
      mymessage (2 STATUS "- Now attempting to install packages ${VAR1}")			
      install_package(${VAR1})
    endif()
  endforeach()

  # a final check to make sure everything built?	
  else()
    message(STATUS "in progress")
  endif()
#  return()

