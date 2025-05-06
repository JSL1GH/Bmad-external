
find_path(xraylib_INCLUDE_DIR xraylib.mod ${CMAKE_MODULE_PATH}/include)

mymessage(2 STATUS "Looking in ${xraylib_SRCDIR} ${CMAKE_MODULE_PATH} for xraylib library .a or .so")

find_library(xraylib_LIBRARY libxraylib.so ${xraylib_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(xraylib_INCLUDE_DIR)
  mymessage (2 STATUS "found xraylib.h - so now have a valid include dir")
endif()
#if(xraylib_LIBRARY)
#  mymessage (2 STATUS "found xraylib.so or .a -  - so now have a valid library")
#endif()

#if(xraylib_INCLUDE_DIR AND xraylib_LIBRARY)
if(xraylib_INCLUDE_DIR)
  set(XRAYLIB_FOUND "TRUE" PARENT_SCOPE)
  set(XRAYLIB_FOUND TRUE)
  mymessage(2 STATUS "All is good with xraylib - continuing - ${XRAYLIB_FOUND}")
else()
  mymessage(1 STATUS "Issues - missing something in xraylib - trouble ahead")
endif()

if(XRAYLIB_FOUND)
#  set(xraylib_LIBRARIES ${xraylib_LIBRARY})
  set(xraylib_INCLUDE_DIRS ${xraylib_INCLUDE_DIR} PARENT_SCOPE)
endif()
