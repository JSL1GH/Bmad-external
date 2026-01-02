find_path(plplot_INCLUDE_DIR plplot.h PATHS ${CMAKE_MODULE_PATH}/include/plplot)
message(STATUS "Looking in ${plplot_SRCDIR} ${CMAKE_MODULE_PATH} for plplot library .a or .so")

find_library(plplot_LIBRARY plplot PATHS ${plplot_SRCDIR} ${CMAKE_MODULE_PATH}/lib)
find_library(plplotfortran_LIBRARY plplotfortran PATHS ${plplot_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(plplot_INCLUDE_DIR)
  message (STATUS "found plplot.h - so now have a valid include dir")
endif()
if(plplot_LIBRARY)
  message (STATUS "found plplot.so or .a -  - so now have a valid library")
# this fixes finding the plplotfortan library - but maybe not the right one
# according to Scott, with the .cmake files in .../lib/cmake/<LIB>/...Config.cmake, it should be found
# and it is there in my install 
# -rw-r--r--   1 jlaster  staff  3751 Dec 11 12:58 /Users/jlaster/bmad/external/lib/cmake/plplot/export_plplotfortran.cmake
#
#  if(plplotfortran_LIBRARY)
#      list(APPEND plplot_LIBRARY ${plplotfortran_LIBRARY})
#  endif()
endif()

if(DEFINED plplot_INCLUDE_DIR AND DEFINED plplot_LIBRARY)
  set(PLPLOT_FOUND TRUE)
  set(PLPLOT_FOUND TRUE PARENT_SCOPE)
  message(STATUS "All is good for plplot - continuing")
else()
  message(STATUS "Issues - missing something with plplot - possible trouble ahead if this is not first build or expected to find it")
endif()

if(PLPLOT_FOUND)
  set(plplot_LIBRARIES ${plplot_LIBRARY})
  set(plplot_INCLUDE_DIRS ${plplot_INCLUDE_DIR} PARENT_SCOPE)
  set(plplot_LIBRARIES ${plplot_LIBRARY} PARENT_SCOPE)
  set(plplot_INCLUDE_DIRS ${plplot_INCLUDE_DIR})
endif()
