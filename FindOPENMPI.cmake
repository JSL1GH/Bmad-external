find_path(openmpi_INCLUDE_DIR openmpi.h ${CMAKE_MODULE_PATH}/include/openmpi)

message(VERBOSE "Looking in ${openmpi_SRCDIR} ${CMAKE_MODULE_PATH} for openmpi library .a or .so (LINUX) or .dylib (APPLE)")

find_library(openmpi_LIBRARY openmpi ${openmpi_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(openmpi_INCLUDE_DIR)
  message(VERBOSE "found openmpi.h - so now have a valid include dir")
endif()
if(openmpi_LIBRARY)
  message(VERBOSE "found openmpi - so now have a valid library")
endif()

if(DEFINED openmpi_INCLUDE_DIR AND openmpi_LIBRARY)
  set(openmpi_FOUND TRUE)
  set(openmpi_FOUND TRUE PARENT_SCOPE)
  message(STATUS "All is good for openmpi - continuing")
else()
  message(STATUS "Issues - missing something for openmpi - trouble ahead")
endif()

if(openmpi_FOUND)
  set(openmpi_LIBRARIES ${openmpi_LIBRARY})
  set(openmpi_LIBRARIES ${openmpi_LIBRARY} PARENT_SCOPE)
  set(openmpi_INCLUDE_DIRS ${openmpi_INCLUDE_DIR})
  set(openmpi_INCLUDE_DIRS ${openmpi_INCLUDE_DIR} PARENT_SCOPE)
endif()
