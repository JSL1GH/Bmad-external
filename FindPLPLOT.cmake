find_path(plplot_INCLUDE_DIR plplot.h ${CMAKE_MODULE_PATH}/include/plplot)
#find_library(plplot_LIBRARY plplot)
#find_path(plplot_INCLUDE_DIR plplot.h)
#find_library(plplot_LIBRARY plplot)
message(STATUS "Looking in ${plplot_SRCDIR} ${CMAKE_MODULE_PATH} for plplot library .a or .so")
#find_library(plplot_LIBRARY ${plplot_SRCDIR} plplot)
find_library(plplot_LIBRARY libplplot.so ${plplot_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(plplot_INCLUDE_DIR)
	message (STATUS "found plplot.h - so now have a valid include dir")
endif()
if(plplot_LIBRARY)
	message (STATUS "found plplot.so or .a -  - so now have a valid library")
endif()

if(plplot_INCLUDE_DIR AND plplot_LIBRARY)
  set(PLPLOT_FOUND TRUE)
  message(STATUS "All is good - continuing")
else()
  message(STATUS "Issues - missing something - trouble ahead")
endif()

if(PLPLOT_FOUND)
  set(plplot_LIBRARIES ${plplot_LIBRARY})
  set(plplot_INCLUDE_DIRS ${plplot_INCLUDE_DIR})
  set(PLPLOT_LIBRARIES ${plplot_LIBRARY})
  set(PLPLOT_INCLUDE_DIRS ${plplot_INCLUDE_DIR})
endif()

# FindPlplot.cmake
#
# Finds the plplot library
#
# This will define the following variables
#
#    Plplot_FOUND
#    Plplot_INCLUDE_DIRS
#
# and the following imported targets
#
#     Plplot::PlplotFi
#
# Author: Pablo Arias - pabloariasal@gmail.com
#
#find_package(PkgConfig)
#pkg_check_modules(PC_Plplot QUIET Plplot)
#
#find_path(Plplot_INCLUDE_DIR
#    NAMES plplot.h
#    PATHS ${PC_Plplot_INCLUDE_DIRS}
#    PATH_SUFFIXES plplot
#)
#
#set(Plplot_VERSION ${PC_Plplot_VERSION})
#
##mark_as_advanced(Plplot_FOUND Plplot_INCLUDE_DIR Plplot_VERSION)
#
#include(FindPackageHandleStandardArgs)
#find_package_handle_standard_args(Plplot
#    REQUIRED_VARS Plplot_INCLUDE_DIR
#    VERSION_VAR Plplot_VERSION
#)
#
#if(Plplot_FOUND)
#    set(Plplot_INCLUDE_DIRS ${Plplot_INCLUDE_DIR})
#endif()
#
#if(Plplot_FOUND AND NOT TARGET Plplot::Plplot)
##    add_library(Plplot::Plplot INTERFACE IMPORTED)
#    add_library(Plplot::Plplot IMPORTED)
#    set_target_properties(Plplot::Plplot PROPERTIES
##        INTERFACE_INCLUDE_DIRECTORIES "${Plplot_INCLUDE_DIR}"
#    )
#endif()
#
