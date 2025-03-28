find_path(hdf5_INCLUDE_DIR hdf5.h ${CMAKE_MODULE_PATH}/include)
#find_library(hdf5_LIBRARY hdf5)
#find_path(hdf5_INCLUDE_DIR hdf5.h)
#find_library(hdf5_LIBRARY hdf5)
message(STATUS "Looking in ${hdf5_SRCDIR} ${CMAKE_MODULE_PATH} for hdf5 library .a or .so")
#find_library(hdf5_LIBRARY ${hdf5_SRCDIR} hdf5)
find_library(hdf5_LIBRARY libhdf5.so ${hdf5_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(hdf5_INCLUDE_DIR)
	message (STATUS "found hdf5.h - so now have a valid include dir")
endif()
if(hdf5_LIBRARY)
	message (STATUS "found hdf5.so or .a -  - so now have a valid library")
endif()

if(hdf5_INCLUDE_DIR AND hdf5_LIBRARY)
  set(hdf5_FOUND TRUE)
  message(STATUS "All is good - continuing")
else()
  message(STATUS "Issues - missing something - trouble ahead")
endif()

if(hdf5_FOUND)
  set(hdf5_LIBRARIES ${hdf5_LIBRARY})
  set(hdf5_INCLUDE_DIRS ${hdf5_INCLUDE_DIR})
endif()

# FindHdf5.cmake
#
# Finds the hdf5 library
#
# This will define the following variables
#
#    Hdf5_FOUND
#    Hdf5_INCLUDE_DIRS
#
# and the following imported targets
#
#     Hdf5::Hdf5Fi
#
# Author: Pablo Arias - pabloariasal@gmail.com
#
#find_package(PkgConfig)
#pkg_check_modules(PC_Hdf5 QUIET Hdf5)
#
#find_path(Hdf5_INCLUDE_DIR
#    NAMES hdf5.h
#    PATHS ${PC_Hdf5_INCLUDE_DIRS}
#    PATH_SUFFIXES hdf5
#)
#
#set(Hdf5_VERSION ${PC_Hdf5_VERSION})
#
##mark_as_advanced(Hdf5_FOUND Hdf5_INCLUDE_DIR Hdf5_VERSION)
#
#include(FindPackageHandleStandardArgs)
#find_package_handle_standard_args(Hdf5
#    REQUIRED_VARS Hdf5_INCLUDE_DIR
#    VERSION_VAR Hdf5_VERSION
#)
#
#if(Hdf5_FOUND)
#    set(Hdf5_INCLUDE_DIRS ${Hdf5_INCLUDE_DIR})
#endif()
#
#if(Hdf5_FOUND AND NOT TARGET Hdf5::Hdf5)
##    add_library(Hdf5::Hdf5 INTERFACE IMPORTED)
#    add_library(Hdf5::Hdf5 IMPORTED)
#    set_target_properties(Hdf5::Hdf5 PROPERTIES
##        INTERFACE_INCLUDE_DIRECTORIES "${Hdf5_INCLUDE_DIR}"
#    )
#endif()
#
