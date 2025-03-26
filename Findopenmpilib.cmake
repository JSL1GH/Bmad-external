## FindopenmpiLib.cmake
find_path(openmpi_INCLUDE_DIR openmpi.h)
#find_library(openmpi_LIBRARY openmpi)
#find_path(openmpi_INCLUDE_DIR openmpi.h)
#find_library(openmpi_LIBRARY openmpi)
message(STATUS "Looking in ${openmpi_SRCDIR} for openmpi library .a or .so")
find_library(openmpi_LIBRARY ${openmpi_SRCDIR} openmpi)

if(openmpi_INCLUDE_DIR)
	message (STATUS "found openmpi.h - so now have a valid include dir")
endif()
if(openmpi_LIBRARY)
	message (STATUS "found openmpi.so or .a -  - so now have a valid library")
endif()

if(openmpi_INCLUDE_DIR AND openmpi_LIBRARY)
  set(openmpi_FOUND TRUE)
  message(STATUS "All is good - continuing")
else()
  message(STATUS "Issues - missing something - trouble ahead")
endif()

if(openmpi_FOUND)
  set(openmpi_LIBRARIES ${openmpi_LIBRARY})
  set(openmpi_INCLUDE_DIRS ${openmpi_INCLUDE_DIR})
endif()

# FindOpenmpi.cmake
#
# Finds the openmpi library
#
# This will define the following variables
#
#    Openmpi_FOUND
#    Openmpi_INCLUDE_DIRS
#
# and the following imported targets
#
#     Openmpi::OpenmpiFi
#
# Author: Pablo Arias - pabloariasal@gmail.com
#
#find_package(PkgConfig)
#pkg_check_modules(PC_Openmpi QUIET Openmpi)
#
#find_path(Openmpi_INCLUDE_DIR
#    NAMES openmpi.h
#    PATHS ${PC_Openmpi_INCLUDE_DIRS}
#    PATH_SUFFIXES openmpi
#)
#
#set(Openmpi_VERSION ${PC_Openmpi_VERSION})
#
##mark_as_advanced(Openmpi_FOUND Openmpi_INCLUDE_DIR Openmpi_VERSION)
#
#include(FindPackageHandleStandardArgs)
#find_package_handle_standard_args(Openmpi
#    REQUIRED_VARS Openmpi_INCLUDE_DIR
#    VERSION_VAR Openmpi_VERSION
#)
#
#if(Openmpi_FOUND)
#    set(Openmpi_INCLUDE_DIRS ${Openmpi_INCLUDE_DIR})
#endif()
#
#if(Openmpi_FOUND AND NOT TARGET Openmpi::Openmpi)
##    add_library(Openmpi::Openmpi INTERFACE IMPORTED)
#    add_library(Openmpi::Openmpi IMPORTED)
#    set_target_properties(Openmpi::Openmpi PROPERTIES
##        INTERFACE_INCLUDE_DIRECTORIES "${Openmpi_INCLUDE_DIR}"
#    )
#endif()
#
