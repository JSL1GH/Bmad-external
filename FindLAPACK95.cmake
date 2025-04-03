find_path(lapack95_INCLUDE_DIR lapack95.h ${CMAKE_MODULE_PATH}/include/lapack95)
#find_library(lapack95_LIBRARY lapack95)
#find_path(lapack95_INCLUDE_DIR lapack95.h)
#find_library(lapack95_LIBRARY lapack95)
message(STATUS "Looking in ${lapack95_SRCDIR} ${CMAKE_MODULE_PATH} for lapack95 library .a or .so")
#find_library(lapack95_LIBRARY ${lapack95_SRCDIR} lapack95)
find_library(lapack95_LIBRARY liblapack95.so ${lapack95_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(lapack95_INCLUDE_DIR)
	message (STATUS "found lapack95.h - so now have a valid include dir")
endif()
if(lapack95_LIBRARY)
	message (STATUS "found lapack95.so or .a -  - so now have a valid library")
endif()

if(lapack95_INCLUDE_DIR AND lapack95_LIBRARY)
  set(lapack95_FOUND TRUE)
  message(STATUS "All is good - continuing")
else()
  message(STATUS "Issues - missing something - trouble ahead")
endif()

if(lapack95_FOUND)
  set(lapack95_LIBRARIES ${lapack95_LIBRARY})
  set(lapack95_INCLUDE_DIRS ${lapack95_INCLUDE_DIR})
endif()

# FindLapack95.cmake
#
# Finds the lapack95 library
#
# This will define the following variables
#
#    Lapack95_FOUND
#    Lapack95_INCLUDE_DIRS
#
# and the following imported targets
#
#     Lapack95::Lapack95Fi
#
# Author: Pablo Arias - pabloariasal@gmail.com
#
#find_package(PkgConfig)
#pkg_check_modules(PC_Lapack95 QUIET Lapack95)
#
#find_path(Lapack95_INCLUDE_DIR
#    NAMES lapack95.h
#    PATHS ${PC_Lapack95_INCLUDE_DIRS}
#    PATH_SUFFIXES lapack95
#)
#
#set(Lapack95_VERSION ${PC_Lapack95_VERSION})
#
##mark_as_advanced(Lapack95_FOUND Lapack95_INCLUDE_DIR Lapack95_VERSION)
#
#include(FindPackageHandleStandardArgs)
#find_package_handle_standard_args(Lapack95
#    REQUIRED_VARS Lapack95_INCLUDE_DIR
#    VERSION_VAR Lapack95_VERSION
#)
#
#if(Lapack95_FOUND)
#    set(Lapack95_INCLUDE_DIRS ${Lapack95_INCLUDE_DIR})
#endif()
#
#if(Lapack95_FOUND AND NOT TARGET Lapack95::Lapack95)
##    add_library(Lapack95::Lapack95 INTERFACE IMPORTED)
#    add_library(Lapack95::Lapack95 IMPORTED)
#    set_target_properties(Lapack95::Lapack95 PROPERTIES
##        INTERFACE_INCLUDE_DIRECTORIES "${Lapack95_INCLUDE_DIR}"
#    )
#endif()
#
