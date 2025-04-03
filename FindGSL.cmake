find_path(gsl_INCLUDE_DIR gsl.h ${CMAKE_MODULE_PATH}/include/gsl)
#find_library(gsl_LIBRARY gsl)
#find_path(gsl_INCLUDE_DIR gsl.h)
#find_library(gsl_LIBRARY gsl)
message(STATUS "Looking in ${gsl_SRCDIR} ${CMAKE_MODULE_PATH} for gsl library .a or .so")
#find_library(gsl_LIBRARY ${gsl_SRCDIR} gsl)
find_library(gsl_LIBRARY libgsl.so ${gsl_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(gsl_INCLUDE_DIR)
	message (STATUS "found gsl.h - so now have a valid include dir")
endif()
if(gsl_LIBRARY)
	message (STATUS "found gsl.so or .a -  - so now have a valid library")
endif()

if(gsl_INCLUDE_DIR AND gsl_LIBRARY)
  set(gsl_FOUND TRUE)
  message(STATUS "All is good - continuing")
else()
  message(STATUS "Issues - missing something - trouble ahead")
endif()

if(gsl_FOUND)
  message("I FOUND GSL!")
  set(gsl_LIBRARIES ${gsl_LIBRARY})
  set(gsl_INCLUDE_DIRS ${gsl_INCLUDE_DIR})
endif()

# FindGsl.cmake
#
# Finds the gsl library
#
# This will define the following variables
#
#    Gsl_FOUND
#    Gsl_INCLUDE_DIRS
#
# and the following imported targets
#
#     Gsl::GslFi
#
# Author: Pablo Arias - pabloariasal@gmail.com
#
#find_package(PkgConfig)
#pkg_check_modules(PC_Gsl QUIET Gsl)
#
#find_path(Gsl_INCLUDE_DIR
#    NAMES gsl.h
#    PATHS ${PC_Gsl_INCLUDE_DIRS}
#    PATH_SUFFIXES gsl
#)
#
#set(Gsl_VERSION ${PC_Gsl_VERSION})
#
##mark_as_advanced(Gsl_FOUND Gsl_INCLUDE_DIR Gsl_VERSION)
#
#include(FindPackageHandleStandardArgs)
#find_package_handle_standard_args(Gsl
#    REQUIRED_VARS Gsl_INCLUDE_DIR
#    VERSION_VAR Gsl_VERSION
#)
#
#if(Gsl_FOUND)
#    set(Gsl_INCLUDE_DIRS ${Gsl_INCLUDE_DIR})
#endif()
#
#if(Gsl_FOUND AND NOT TARGET Gsl::Gsl)
##    add_library(Gsl::Gsl INTERFACE IMPORTED)
#    add_library(Gsl::Gsl IMPORTED)
#    set_target_properties(Gsl::Gsl PROPERTIES
##        INTERFACE_INCLUDE_DIRECTORIES "${Gsl_INCLUDE_DIR}"
#    )
#endif()
#
