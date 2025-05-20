
#do not expect a lapack95 header file
find_path(lapack95_INCLUDE_DIR NAMES lapack95.mod f95_lapack.mod ${CMAKE_MODULE_PATH}/include/lapack95)
#find_library(lapack95_LIBRARY lapack95)
#find_path(lapack95_INCLUDE_DIR lapack95.h)
#find_library(lapack95_LIBRARY lapack95)
mymessage(2 STATUS "Looking in ${lapack95_SRCDIR} ${CMAKE_MODULE_PATH} for lapack95 library .a or .so")
#find_library(lapack95_LIBRARY ${lapack95_SRCDIR} lapack95)
find_library(lapack95_LIBRARY liblapack95.so ${lapack95_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

#mymessage(4 STATUS "JSL - Value is ${lapack95_INCLUDE_DIR}")
if(lapack95_INCLUDE_DIR)
  message (STATUS "found lapack95.mod - so now have a valid include dir")
endif()
      
if(lapack95_LIBRARY)
  mymessage (2 STATUS "found lapack95.so or .a -  - so now have a valid library")
  # note, if we did not find the lapack95_INCLUDE_DIR, but did find, the lapack95_LIBRARY, let's check one level up
  if (NOT lapack95_INCLUDE_DIR)
#    set(UP_ONE_LEVEL ${lapack95_LIBRARY}
    get_filename_component(PARENT_DIR ${lapack95_LIBRARY} PATH)
    get_filename_component(PARENT_PARENT_DIR ${PARENT_DIR} PATH)
    mymessage (4 STATUS "Looking for lapack95.mod or f95_lapack.mod in ${PARENT_PARENT_DIR}")
    find_path(lapack95_INCLUDE_DIR NAMES lapack95.mod f95_lapack.mod PATH ${PARENT_PARENT_DIR} PATH_SUFFIXES modules lib include)
    mymessage(4 STATUS "MYVALUE is ${lapack95_INCLUDE_DIR}")
    if(lapack95_INCLUDE_DIR})
      mymessage (3 STATUS "found lapack95.mod or f95_lapack.mod - so now have a valid include dir - ${lapack95_INCLUDE_DIR}")
    endif()
  endif()
endif()

#if(lapack95_INCLUDE_DIR AND lapack95_LIBRARY)
if(lapack95_LIBRARY)
  set(LAPACK95_FOUND TRUE)
  set(LAPACK95_FOUND TRUE PARENT_SCOPE)
  set(LAPACK95_LIBRARY ${lapack95_LIBRARY})
  set(LAPACK95_LIBRARY ${lapack95_LIBRARY} PARENT_SCOPE)
  set(LAPACK95_INCLUDE_DIR ${lapack95_INCLUDE_DIR})
  set(LAPACK95_INCLUDE_DIR ${lapack95_INCLUDE_DIR} PARENT_SCOPE)

  mymessage(2 STATUS "All is good for package lapack95 - continuing - library - ${LAPACK95_LIBRARY} - cflags - ${LAPACK95_INCLUDE_DIR}")
else()
  mymessage(1 STATUS "Issues - missing something in lapack95 - trouble ahead")
endif()

if(LAPACK_FOUND)
#  set(lapack95_LIBRARIES ${lapack95_LIBRARY})
  set(lapack95_INCLUDE_DIRS ${lapack95_INCLUDE_DIR} PARENT_SCOPE)
  
endif()
