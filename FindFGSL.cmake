message(STATUS "In FindFGSL.cmake - checking package ${CMAKE_FIND_PACKAGE_NAME}")

#find_path(fgsl_INCLUDE_DIR NAMES fgsl.h fgsl.mod ${CMAKE_MODULE_PATH}/include/fgsl)
find_path(fgsl_INCLUDE_DIR NAMES fgsl.h fgsl.mod PATHS ${CMAKE_MODULE_PATH}/include/fgsl)

#message(STATUS "Looking in ${fgsl_SRCDIR} ${CMAKE_MODULE_PATH} for fgsl library .a or .so")
message(STATUS "Looking in ${CMAKE_MODULE_PATH} for fgsl library .a or .so or fgsl.dylib")

#find_library(fgsl_LIBRARY NAMES libfgsl.dylib ${CMAKE_MODULE_PATH}/lib)
find_library(fgsl_LIBRARY NAMES fgsl PATHS ${CMAKE_MODULE_PATH}/lib)


if (APPLE)
#find_library(fgsl_LIBRARY NAMES libfgsl.so libfgsl.dylib ${fgsl_SRCDIR} ${CMAKE_MODULE_PATH}/lib)
else()
#find_library(fgsl_LIBRARY NAMES libfgsl.so libfgsl.dylib ${fgsl_SRCDIR} ${CMAKE_MODULE_PATH}/lib)
endif()

if(fgsl_INCLUDE_DIR)
  message (STATUS "found fgsl.h - so now have a valid include dir")
endif()
message(STATUS "Value of lib is ${fgsl_LIBRARY}")
if(fgsl_LIBRARY)
  message (STATUS "found fgsl.so or .a - so now have a valid library")
endif()

# also, let's check for a valid version of gsl - if not, we fail this!
set(valid_gsl 0)

set(pre_func_name_cap "GSL")
set(pre_func_name "gsl")

# need to account that user may have already installed a version of GSL in their
# own special place - Just like when we look in our outer GlobalVariables.cmake

#message(STATUS "Will look for ${pre_func_name_cap} in ${CMAKE_PREFIX_PATH}")
message(STATUS "Will look for ${pre_func_name_cap} in ${CMAKE_MODULE_PATH}")
#find_package(${pre_func_name_cap} HINTS ${CMAKE_PREFIX_PATH})

find_package(GSL)

  if(${pre_func_name_cap}_FOUND)

    set(STR1 ${${pre_func_name_cap}_VERSION})
    set(STR2 "2.6")

    message(STATUS "Version of ${pre_func_name} found is (library) ${${pre_func_name_cap}_LIBRARY} and (includes) ${${pre_func_name_cap}_INCLUDE_DIR} - VERSION is ${${pre_fu
nc_name_cap}_VERSION}")

    if("${STR1}" VERSION_LESS "${STR2}")
      message(STATUS "Installed version is less than 2.6 - build GSL")
#      set(NEED_TO_BUILD_${pre_func_name_cap} 1)
    else()
      set(valid_gsl 1)
      message(STATUS "We have a valid version of ${pre_func_name} - when checking for FGSL")
      set(GSL_LIBS ${${pre_func_name_cap}_LIBRARY})
      set(GSL_LIBS ${${pre_func_name_cap}_LIBRARY} PARENT_SCOPE)
      set(gsl_LIBS ${${pre_func_name_cap}_LIBRARY})
      set(gsl_LIBS ${${pre_func_name_cap}_LIBRARY} PARENT_SCOPE)
      set(GSL_LIBRARIES ${${pre_func_name_cap}_LIBRARY})
      set(GSL_LIBRARIES ${${pre_func_name_cap}_LIBRARY} PARENT_SCOPE)
      set(gsl_LIBRARIES ${${pre_func_name_cap}_LIBRARY})
      set(gsl_LIBRARIES ${${pre_func_name_cap}_LIBRARY} PARENT_SCOPE)

      find_path(gsl_INCLUDE_DIR gsl_blas.h ${gsl_LIBS})
      
      set(GSL_CFLAGS ${gsl_INCLUDE_DIR})
      set(gsl_CFLAGS ${gsl_INCLUDE_DIR} PARENT_SCOPE)
    endif()
  else()
    message(STATUS "No version of GSL found!")
  endif()

set(FGSL_FOUND "FALSE")
  
if(DEFINED fgsl_INCLUDE_DIR AND DEFINED fgsl_LIBRARY AND valid_gsl)
  set(FGSL_FOUND "TRUE")
  set(FGSL_FOUND "TRUE" PARENT_SCOPE)
  message(STATUS "All is good for having gsl/fgsl packages - continuing")
else()
  message(STATUS "Issues - missing something for fgsl/gsl packages - could be trouble ahead - but also could be we have not yet built gsl and/or fgsl - ${GSL_LIBS}")
endif()

if(${FGSL_FOUND})
  set(fgsl_LIBRARIES ${fgsl_LIBRARY})
  set(fgsl_INCLUDE_DIRS ${fgsl_INCLUDE_DIR})
  set(fgsl_LIBRARIES ${fgsl_LIBRARY} PARENT_SCOPE)
  set(fgsl_INCLUDE_DIRS ${fgsl_INCLUDE_DIR} PARENT_SCOPE)
  message(STATUS "IN FindFGSL.cmake - value of FGSL_FOUND IS ${FGSL_FOUND} - using values of ${fgsl_LIBRARY} and ${fgsl_INCLUDE_DIR}")
endif()

#find_package(GSL)
#
#  if(${pre_func_name_cap}_FOUND)
#  
#    set(STR1 ${${pre_func_name_cap}_VERSION})
#    set(STR2 "2.6")
#
#    message(3 STATUS "Version of ${pre_func_name} found is ${${pre_func_name_cap}_LIBRARY} and includes ${${pre_func_name_cap}_INCLUDE_DIR} - VERSION is ${${pre_func_name_cap}_VERSION}")
#
#
#    if("${STR1}" VERSION_LESS "${STR2}")
#
#      message(3 STATUS "Installed version is less than 2.6 - build GSL")
##      set(NEED_TO_BUILD_${pre_func_name_cap} 1)
# 
#    else()
#
#      set(valid_gsl 1)
#      message(3 STATUS "We have a valid version of ${pre_func_name} - when checking for FGSL")
#    endif()
#  else()
#    message(1 STATUS "No version of GSL found!")
#  endif()
#
#if(fgsl_INCLUDE_DIR AND fgsl_LIBRARY AND valid_gsl)s
#  set(FGSL_FOUND "TRUE")
#  set(FGSL_FOUND "TRUE" PARENT_SCOPE)
#  message(3 STATUS "All is good for having gsl/fgsl packages - continuing")
#else()
#  message(1 STATUS "Issues - missing something for fgsl/gsl packages - trouble ahead")
#endif()
#
#if(${FGSL_FOUND})
#  set(fgsl_LIBRARIES ${fgsl_LIBRARY})
#  set(fgsl_INCLUDE_DIRS ${fgsl_INCLUDE_DIR})
#  message(3 STATUS "IN FindFGSL.cmake - value of FGSL_FOUND IS ${FGSL_FOUND}")
#endif()
