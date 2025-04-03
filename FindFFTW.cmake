find_path(fftw_INCLUDE_DIR fftw.h ${CMAKE_MODULE_PATH}/include/fftw)
#find_library(fftw_LIBRARY fftw)
#find_path(fftw_INCLUDE_DIR fftw.h)
#find_library(fftw_LIBRARY fftw)
message(STATUS "Looking in ${fftw_SRCDIR} ${CMAKE_MODULE_PATH} for fftw library .a or .so")
#find_library(fftw_LIBRARY ${fftw_SRCDIR} fftw)
find_library(fftw_LIBRARY libfftw.so ${fftw_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(fftw_INCLUDE_DIR)
	message (STATUS "found fftw.h - so now have a valid include dir")
endif()
if(fftw_LIBRARY)
	message (STATUS "found fftw.so or .a -  - so now have a valid library")
endif()

if(fftw_INCLUDE_DIR AND fftw_LIBRARY)
  set(fftw_FOUND TRUE)
  message(STATUS "All is good - continuing")
else()
  message(STATUS "Issues - missing something - trouble ahead")
endif()

if(fftw_FOUND)
  set(fftw_LIBRARIES ${fftw_LIBRARY})
  set(fftw_INCLUDE_DIRS ${fftw_INCLUDE_DIR})
endif()

# FindFftw.cmake
#
# Finds the fftw library
#
# This will define the following variables
#
#    Fftw_FOUND
#    Fftw_INCLUDE_DIRS
#
# and the following imported targets
#
#     Fftw::FftwFi
#
# Author: Pablo Arias - pabloariasal@gmail.com
#
#find_package(PkgConfig)
#pkg_check_modules(PC_Fftw QUIET Fftw)
#
#find_path(Fftw_INCLUDE_DIR
#    NAMES fftw.h
#    PATHS ${PC_Fftw_INCLUDE_DIRS}
#    PATH_SUFFIXES fftw
#)
#
#set(Fftw_VERSION ${PC_Fftw_VERSION})
#
##mark_as_advanced(Fftw_FOUND Fftw_INCLUDE_DIR Fftw_VERSION)
#
#include(FindPackageHandleStandardArgs)
#find_package_handle_standard_args(Fftw
#    REQUIRED_VARS Fftw_INCLUDE_DIR
#    VERSION_VAR Fftw_VERSION
#)
#
#if(Fftw_FOUND)
#    set(Fftw_INCLUDE_DIRS ${Fftw_INCLUDE_DIR})
#endif()
#
#if(Fftw_FOUND AND NOT TARGET Fftw::Fftw)
##    add_library(Fftw::Fftw INTERFACE IMPORTED)
#    add_library(Fftw::Fftw IMPORTED)
#    set_target_properties(Fftw::Fftw PROPERTIES
##        INTERFACE_INCLUDE_DIRECTORIES "${Fftw_INCLUDE_DIR}"
#    )
#endif()
#
