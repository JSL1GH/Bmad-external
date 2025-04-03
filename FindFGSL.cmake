find_path(fgsl_INCLUDE_DIR fgsl.mod ${CMAKE_MODULE_PATH}/include/fgsl)
#find_library(fgsl_LIBRARY fgsl)
#find_path(fgsl_INCLUDE_DIR fgsl.h)
#find_library(fgsl_LIBRARY fgsl)
message(STATUS "Looking in ${fgsl_SRCDIR} ${CMAKE_MODULE_PATH} for fgsl library .a or .so")
#find_library(fgsl_LIBRARY ${fgsl_SRCDIR} fgsl)
find_library(fgsl_LIBRARY libfgsl.so ${fgsl_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(fgsl_INCLUDE_DIR)
	message (STATUS "found fgsl.h - so now have a valid include dir")
endif()
if(fgsl_LIBRARY)
	message (STATUS "found fgsl.so or .a -  - so now have a valid library")
endif()

if(fgsl_INCLUDE_DIR AND fgsl_LIBRARY)
  set(fgsl_FOUND TRUE)
  set(JSL_FOUND TRUE)
  message(STATUS "All is good - continuing")
else()
  message(STATUS "Issues - missing something - trouble ahead")
endif()

if(fgsl_FOUND)
  message("I FOUND FGSL!")
  set(fgsl_LIBRARIES ${fgsl_LIBRARY})
  set(fgsl_INCLUDE_DIRS ${fgsl_INCLUDE_DIR})
endif()

# FindFgsl.cmake
#
# Finds the fgsl library
#
# This will define the following variables
#
#    Fgsl_FOUND
#    Fgsl_INCLUDE_DIRS
#
# and the following imported targets
#
#     Fgsl::FgslFi
#
# Author: Pablo Arias - pabloariasal@gmail.com
#
#find_package(PkgConfig)
#pkg_check_modules(PC_Fgsl QUIET Fgsl)
#
#find_path(Fgsl_INCLUDE_DIR
#    NAMES fgsl.h
#    PATHS ${PC_Fgsl_INCLUDE_DIRS}
#    PATH_SUFFIXES fgsl
#)
#
#set(Fgsl_VERSION ${PC_Fgsl_VERSION})
#
##mark_as_advanced(Fgsl_FOUND Fgsl_INCLUDE_DIR Fgsl_VERSION)
#
#include(FindPackageHandleStandardArgs)
#find_package_handle_standard_args(Fgsl
#    REQUIRED_VARS Fgsl_INCLUDE_DIR
#    VERSION_VAR Fgsl_VERSION
#)
#
#if(Fgsl_FOUND)
#    set(Fgsl_INCLUDE_DIRS ${Fgsl_INCLUDE_DIR})
#endif()
#
#if(Fgsl_FOUND AND NOT TARGET Fgsl::Fgsl)
##    add_library(Fgsl::Fgsl INTERFACE IMPORTED)
#    add_library(Fgsl::Fgsl IMPORTED)
#    set_target_properties(Fgsl::Fgsl PROPERTIES
##        INTERFACE_INCLUDE_DIRECTORIES "${Fgsl_INCLUDE_DIR}"
#    )
#endif()
#
