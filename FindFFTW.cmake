message(STATUS "In FindFFTW.cmake - checking package ${CMAKE_FIND_PACKAGE_NAME}")

if (${CHECK_FFTW_DEVEL})
  message(STATUS "Including check for fftw_devel to indicate have valid fftw")
endif()

# it looks like /usr/include comes for free
find_path(fftw_INCLUDE_DIR NAMES fftw.h fftw3.h ${CMAKE_MODULE_PATH}/include/fftw)
message(STATUS "Looking in ${fftw_SRCDIR} ${CMAKE_MODULE_PATH} for fftw library .a or .so")
#find_library(fftw_LIBRARY ${fftw_SRCDIR} fftw)
#it looks like /usr/lib/ and /usr/lib64 come for free
#find_library(fftw_LIBRARY NAMES libfftw3.so libfftw.so ${fftw_SRCDIR} ${CMAKE_MODULE_PATH}/lib /usr/lib)
find_library(fftw_LIBRARY NAMES fftw3 libfftw.so PATHS ${fftw_SRCDIR} ${CMAKE_MODULE_PATH}/lib)

if(fftw_INCLUDE_DIR)
  message (STATUS "found fftw.h or fftw3.h - in ${fftw_INCLUDE_DIR} - so now have a valid include dir")
endif()
if(fftw_LIBRARY)
  message (STATUS "found fftw.so or fftw3.so or .a - in ${fftw_LIBRARY} - so now have a valid library")
endif()

if(DEFINED fftw_INCLUDE_DIR AND DEFINED fftw_LIBRARY)

# so far so, good, now check if we need to check for fftw3

  if (${CHECK_FFTW_DEVEL})

# it looks like /usr/include comes for free    
#    find_path(fftw3_INCLUDE_DIR fftw3.h ${CMAKE_MODULE_PATH}/include /usr/include)
    find_path(fftw3_INCLUDE_DIR fftw3.h PATHS ${CMAKE_MODULE_PATH}/include)
#find_library(fftw_LIBRARY fftw)
#find_path(fftw_INCLUDE_DIR fftw.h)
#find_library(fftw_LIBRARY fftw)
    message(STATUS "Looking in ${fftw_SRCDIR} ${CMAKE_MODULE_PATH} /usr/local for fftw3 library .a or .so")
#find_library(fftw_LIBRARY ${fftw_SRCDIR} fftw)
# it looks like /usr/lib and /usr/lib64 come for free
#    find_library(fftw3_LIBRARY libfftw3.so ${fftw_SRCDIR} ${CMAKE_MODULE_PATH} /usr/lib)
    find_library(fftw3_LIBRARY libfftw3.so PATHS ${fftw_SRCDIR} ${CMAKE_MODULE_PATH})

    if(fftw3_INCLUDE_DIR)
      message (STATUS "found fftw3.h - so now have a valid include dir")
    endif()
    if(fftw3_LIBRARY)
	message (STATUS "found fftw3.so or .a -  - so now have a valid library")
    endif()

    if(fftw3_INCLUDE_DIR AND fftw3_LIBRARY)
      set(FFTW_FOUND TRUE)
      set(FFTW_FOUND TRUE PARENT_SCOPE)
      message(STATUS "All is good - have fftw and fftw-devel")
    else()
      message(FAILURE "1 Issues - Had FFTW - but could not find fftw-devel - this will be a problem")
    endif()
  else()
    message(STATUS "Had FFTW - user did not ask to check if have fftw-devel - returning success")
    set(FFTW_FOUND TRUE)
    set(FFTW_FOUND TRUE PARENT_SCOPE)
    message(STATUS "All is good - have fftw")
  endif()
else()
  message(FAILURE "Issues - missing FFTW (didn't even check for fftw-devel - trouble ahead")
endif()


if(FFTW_FOUND)
#  set (FFTW_VERSION 0.1) 
  message(STATUS "WE NOW INDICATE A VALUE FFTW package - ${FFTW_FOUND}")
  set(FFTW_LIBRARIES ${fftw_LIBRARY})
  set(FFTW_INCLUDE_DIRS ${fftw_INCLUDE_DIR})
  set(FFTW_LIBRARIES ${fftw_LIBRARY} PARENT_SCOPE)
  set(FFTW_INCLUDE_DIRS ${fftw_INCLUDE_DIR} PARENT_SCOPE)
  set(fftw_LIBRARIES ${fftw_LIBRARY})
  set(fftw_INCLUDE_DIRS ${fftw_INCLUDE_DIR})
  set(fftw_LIBRARIES ${fftw_LIBRARY} PARENT_SCOPE)
  set(fftw_INCLUDE_DIRS ${fftw_INCLUDE_DIR} PARENT_SCOPE)
else()
  message(STATUS "WE NOW INDICATE THAT FFTW Package was not found!")
endif()
