find_path(lapack_INCLUDE_DIR lapack.h ${CMAKE_MODULE_PATH}/include/lapack)
#find_library(lapack_LIBRARY lapack)
#find_path(lapack_INCLUDE_DIR lapack.h)
#find_library(lapack_LIBRARY lapack)
message(STATUS "Looking in ${lapack_SRCDIR} ${CMAKE_MODULE_PATH} for lapack library .a or .so")
#find_library(lapack_LIBRARY ${lapack_SRCDIR} lapack)
find_library(lapack_LIBRARY liblapack.so ${lapack_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(lapack_INCLUDE_DIR)
	message (STATUS "found lapack.h - so now have a valid include dir")
endif()
if(lapack_LIBRARY)
	message (STATUS "found lapack.so or .a -  - so now have a valid library")
endif()

if(lapack_INCLUDE_DIR AND lapack_LIBRARY)
  set(lapack_FOUND TRUE)
  message(STATUS "All is good - continuing")
else()
  message(STATUS "Issues - missing something - trouble ahead")
endif()

if(lapack_FOUND)
  set(lapack_LIBRARIES ${lapack_LIBRARY})
  set(lapack_INCLUDE_DIRS ${lapack_INCLUDE_DIR})
endif()

# FindLapack.cmake
#
# Finds the lapack library
#
# This will define the following variables
#
#    Lapack_FOUND
#    Lapack_INCLUDE_DIRS
#
# and the following imported targets
#
#     Lapack::LapackFi
#
# Author: Pablo Arias - pabloariasal@gmail.com
#
#find_package(PkgConfig)
#pkg_check_modules(PC_Lapack QUIET Lapack)
#
#find_path(Lapack_INCLUDE_DIR
#    NAMES lapack.h
#    PATHS ${PC_Lapack_INCLUDE_DIRS}
#    PATH_SUFFIXES lapack
#)
#
#set(Lapack_VERSION ${PC_Lapack_VERSION})
#
##mark_as_advanced(Lapack_FOUND Lapack_INCLUDE_DIR Lapack_VERSION)
#
#include(FindPackageHandleStandardArgs)
#find_package_handle_standard_args(Lapack
#    REQUIRED_VARS Lapack_INCLUDE_DIR
#    VERSION_VAR Lapack_VERSION
#)
#
#if(Lapack_FOUND)
#    set(Lapack_INCLUDE_DIRS ${Lapack_INCLUDE_DIR})
#endif()
#
#if(Lapack_FOUND AND NOT TARGET Lapack::Lapack)
##    add_library(Lapack::Lapack INTERFACE IMPORTED)
#    add_library(Lapack::Lapack IMPORTED)
#    set_target_properties(Lapack::Lapack PROPERTIES
##        INTERFACE_INCLUDE_DIRECTORIES "${Lapack_INCLUDE_DIR}"
#    )
#endif()
#
