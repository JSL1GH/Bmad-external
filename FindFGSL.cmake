#find_path(fgsl_INCLUDE_DIR fgsl.h ${CMAKE_MODULE_PATH}/include/fgsl)
find_path(fgsl_INCLUDE_DIR NAMES fgsl.h fgsl.mod ${CMAKE_MODULE_PATH}/include/fgsl)
#find_library(fgsl_LIBRARY fgsl)




#find_path(fgsl_INCLUDE_DIR fgsl.h)
#find_library(fgsl_LIBRARY fgsl)
message(STATUS "Looking in ${fgsl_SRCDIR} ${CMAKE_MODULE_PATH} for fgsl library .a or .so")
#find_library(fgsl_LIBRARY ${fgsl_SRCDIR} fgsl)
#find_library(fgsl_LIBRARY libfgsl.so ${fgsl_SRCDIR} ${CMAKE_MODULE_PATH}/lib)
find_library(fgsl_LIBRARY NAMES libfgsl.so libfgsl.dylib ${fgsl_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(fgsl_INCLUDE_DIR)
	message (STATUS "found fgsl.h - so now have a valid include dir")
endif()
if(fgsl_LIBRARY)
	message (STATUS "found fgsl.so or .a -  - so now have a valid library")
endif()

# also, let's check for a valid version of gsl - if not, we fail this!
set(valid_gsl 0)

set(pre_func_name_cap "GSL")

  find_package(${pre_func_name_cap})

  if(${pre_func_name_cap}_VERSION)

    set(STR1 ${${pre_func_name_cap}_VERSION})
    set(STR2 "2.6")

    if("${STR1}" VERSION_LESS "${STR2}")

      message(STATUS "Installed version is less than 2.6 - build GSL")
#      set(NEED_TO_BUILD_${pre_func_name_cap} 1)
 
    else()

      set(valid_gsl 1)
      message(STATUS "We have a valid version of gsl - when checking for FGSL")
    endif()
  endif()

if(fgsl_INCLUDE_DIR AND fgsl_LIBRARY AND valid_gsl)
  set(FGSL_FOUND "TRUE")
  set(FGSL_FOUND "TRUE" PARENT_SCOPE)
  message(STATUS "All is good - continuing")
else()
  message(STATUS "Issues - missing something - trouble ahead")
endif()

if(${FGSL_FOUND})
  
  set(fgsl_LIBRARIES ${fgsl_LIBRARY})
  set(fgsl_INCLUDE_DIRS ${fgsl_INCLUDE_DIR})
#  set(fgsl_LIBRARIES ${fgsl_LIBRARY})
#  set(fgsl_INCLUDE_DIRS ${fgsl_INCLUDE_DIR})
  message(STATUS "IN FindFGSL.cmake - value of FGSL_FOUND IS ${FGSL_FOUND}")
endif()

# Findfgsl.cmake
#
# Finds the fgsl library
#
# This will define the following variables
#
#    fgsl_FOUND
#    fgsl_INCLUDE_DIRS
#
# and the following imported targets
#
#     fgsl::fgslFi
#
# Author: Pablo Arias - pabloariasal@gmail.com
#
#find_package(PkgConfig)
#pkg_check_modules(PC_fgsl QUIET fgsl)
#
#find_path(fgsl_INCLUDE_DIR
#    NAMES fgsl.h
#    PATHS ${PC_fgsl_INCLUDE_DIRS}
#    PATH_SUFFIXES fgsl
#)
#
#set(fgsl_VERSION ${PC_fgsl_VERSION})
#
##mark_as_advanced(fgsl_FOUND fgsl_INCLUDE_DIR fgsl_VERSION)
#
#include(FindPackageHandleStandardArgs)
#find_package_handle_standard_args(fgsl
#    REQUIRED_VARS fgsl_INCLUDE_DIR
#    VERSION_VAR fgsl_VERSION
#)
#
#if(fgsl_FOUND)
#    set(fgsl_INCLUDE_DIRS ${fgsl_INCLUDE_DIR})
#endif()
#
#if(fgsl_FOUND AND NOT TARGET fgsl::fgsl)
##    add_library(fgsl::fgsl INTERFACE IMPORTED)
#    add_library(fgsl::fgsl IMPORTED)
#    set_target_properties(fgsl::fgsl PROPERTIES
##        INTERFACE_INCLUDE_DIRECTORIES "${fgsl_INCLUDE_DIR}"
#    )
#endif()
#
