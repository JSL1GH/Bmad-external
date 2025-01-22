## FindxraylibLib.cmake
find_path(xraylib_INCLUDE_DIR xraylib.h)
#find_library(xraylib_LIBRARY xraylib)
#find_path(xraylib_INCLUDE_DIR xraylib.h)
#find_library(xraylib_LIBRARY xrl)
message(STATUS "Looking in ${xraylib_SRCDIR} for xrl library .a or .so")
find_library(xraylib_LIBRARY ${xraylib_SRCDIR} xrl)

if(xraylib_INCLUDE_DIR)
	message (STATUS "found xraylib.h - so now have a valid include dir")
endif()
if(xraylib_LIBRARY)
	message (STATUS "found xraylib.so or .a -  - so now have a valid library")
endif()

if(xraylib_INCLUDE_DIR AND xraylib_LIBRARY)
  set(xraylib_FOUND TRUE)
  message(STATUS "All is good - continuing")
else()
  message(STATUS "Issues - missing something - trouble ahead")
endif()

if(xraylib_FOUND)
  set(xraylib_LIBRARIES ${xraylib_LIBRARY})
  set(xraylib_INCLUDE_DIRS ${xraylib_INCLUDE_DIR})
endif()

# FindXraylib.cmake
#
# Finds the xraylib library
#
# This will define the following variables
#
#    Xraylib_FOUND
#    Xraylib_INCLUDE_DIRS
#
# and the following imported targets
#
#     Xraylib::XraylibFi
#
# Author: Pablo Arias - pabloariasal@gmail.com
#
#find_package(PkgConfig)
#pkg_check_modules(PC_Xraylib QUIET Xraylib)
#
#find_path(Xraylib_INCLUDE_DIR
#    NAMES xraylib.h
#    PATHS ${PC_Xraylib_INCLUDE_DIRS}
#    PATH_SUFFIXES xraylib
#)
#
#set(Xraylib_VERSION ${PC_Xraylib_VERSION})
#
##mark_as_advanced(Xraylib_FOUND Xraylib_INCLUDE_DIR Xraylib_VERSION)
#
#include(FindPackageHandleStandardArgs)
#find_package_handle_standard_args(Xraylib
#    REQUIRED_VARS Xraylib_INCLUDE_DIR
#    VERSION_VAR Xraylib_VERSION
#)
#
#if(Xraylib_FOUND)
#    set(Xraylib_INCLUDE_DIRS ${Xraylib_INCLUDE_DIR})
#endif()
#
#if(Xraylib_FOUND AND NOT TARGET Xraylib::Xraylib)
##    add_library(Xraylib::Xraylib INTERFACE IMPORTED)
#    add_library(Xraylib::Xraylib IMPORTED)
#    set_target_properties(Xraylib::Xraylib PROPERTIES
##        INTERFACE_INCLUDE_DIRECTORIES "${Xraylib_INCLUDE_DIR}"
#    )
#endif()
#
