mymessage(2 STATUS "In FindFGSL.cmake - checking package ${CMAKE_FIND_PACKAGE_NAME}")

find_path(fgsl_INCLUDE_DIR NAMES fgsl.h fgsl.mod ${CMAKE_MODULE_PATH}/include/fgsl)

mymessage(3 STATUS "Looking in ${fgsl_SRCDIR} ${CMAKE_MODULE_PATH} for fgsl library .a or .so")

find_library(fgsl_LIBRARY NAMES libfgsl.so libfgsl.dylib ${fgsl_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(fgsl_INCLUDE_DIR)
  mymessage (3 STATUS "found fgsl.h - so now have a valid include dir")
endif()
if(fgsl_LIBRARY)
  mymessage (3 STATUS "found fgsl.so or .a - so now have a valid library")
endif()

# also, let's check for a valid version of gsl - if not, we fail this!
set(valid_gsl 0)

set(pre_func_name_cap "GSL")
set(pre_func_name "gsl")

# need to account that user may have already installed a version of GSL in their
# own special place - Just like when we look in our outer GlobalVariables.cmake

mymessage(3 STATUS "Will look for ${pre_func_name_cap} in ${CMAKE_PREFIX_PATH}")
#find_package(${pre_func_name_cap} HINTS ${CMAKE_PREFIX_PATH})

find_package(GSL)

  if(${pre_func_name_cap}_VERSION)

    set(STR1 ${${pre_func_name_cap}_VERSION})
    set(STR2 "2.6")

    mymessage(3 STATUS "Version of ${pre_func_name} found is ${${pre_func_name_cap}_LIBRARY} and includes ${${pre_func_name_cap}__INCLUDE_DIR} - VERSION is ${${pre_func_name_cap}_VERSION}")


    if("${STR1}" VERSION_LESS "${STR2}")

      mymessage(3 STATUS "Installed version is less than 2.6 - build GSL")
#      set(NEED_TO_BUILD_${pre_func_name_cap} 1)
 
    else()

      set(valid_gsl 1)
      mymessage(3 STATUS "We have a valid version of ${pre_func_name} - when checking for FGSL")
    endif()
  else()
    mymessage(1 STATUS "No version of GSL found!")
  endif()

if(fgsl_INCLUDE_DIR AND fgsl_LIBRARY AND valid_gsl)
  set(FGSL_FOUND "TRUE")
  set(FGSL_FOUND "TRUE" PARENT_SCOPE)
  mymessage(3 STATUS "All is good for having gsl/fgsl packages - continuing")
else()
  mymessage(1 STATUS "Issues - missing something for fgsl/gsl packages - trouble ahead")
endif()

if(${FGSL_FOUND})
  set(fgsl_LIBRARIES ${fgsl_LIBRARY})
  set(fgsl_INCLUDE_DIRS ${fgsl_INCLUDE_DIR})
  mymessage(3 STATUS "IN FindFGSL.cmake - value of FGSL_FOUND IS ${FGSL_FOUND}")
endif()
