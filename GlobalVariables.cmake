  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    message (STATUS "This is the GlobalVariables.cmake file that was included - it contains global definitions!")
  endif()

  set_property(GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES "${CMAKE_ROLLOUT_CMAKE_FILES}/bmad-external-packages")
  # this should come from switch given to cmake build line - jsl

  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    # but not ${BMAD_EXTERNAL_PACKAGES} - need to understand
    message("All of the packages to be built can be found at ${CMAKE_ROLLOUT_CMAKE_FILES}/bmad-external-packages and ${BMAD_EXTERNAL_PACKAGES}")
  endif()



  # if the CMAKE_INSTALL_PREFIX is not an absolute path, then put the path in front!
  if(IS_ABSOLUTE "${CMAKE_INSTALL_PREFIX}")
    # nothing to do!
    message("The string is a full path.")
  else()
    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message("1. The string is not a full path. - setting with path - '${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_INSTALL_PREFIX}' - '${CMAKE_INSTALL_PREFIX}'")
    endif()
    message("Setting CMAKE_INSTALL_PREFIX TO SOURCE_DIR/INSTALL_PREFIX")
    set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_INSTALL_PREFIX})
    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message("2. The string is not a full path. - setting with path - '${CMAKE_INSTALL_PREFIX}'")
    endif()
  endif()

  set_property(GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY ${BUILD_DIR})

  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    message (STATUS "CMAKE INSTALL DIRECTORY IS '${CMAKE_INSTALL_PREFIX}'")
    message (STATUS "SETTING EXTERNAL_BMAD_DIRECTORY to value of ${BUILD_DIR}")
  endif()

  set (APPEND_BUILD_TYPE "production")
  # now add on to the CMAKE_INSTALL_PREFIX the BUILD_TYPE
  if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
    set (APPEND_BUILD_TYPE "debug")
  endif()


  if (EXISTS "${CMAKE_MODULE_PATH}")
#  if (CMAKE_MODULE_PATH)
     message(FAILURE "HERE")
    set (CMAKE_MODULE_PATH ${CMAKE_INSTALL_PREFIX} ${CMAKE_INSTALL_PREFIX}/${APPEND_BUILD_TYPE} ${CMAKE_MODULE_PATH} ${CMAKE_MODULE_PATH}/${APPEND_BUILD_TYPE})
  else()
     message(FAILURE "HERE2")
    set (CMAKE_MODULE_PATH ${CMAKE_INSTALL_PREFIX} ${CMAKE_INSTALL_PREFIX}/${APPEND_BUILD_TYPE})
  endif()

  set (CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX}/${APPEND_BUILD_TYPE})

  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    message (STATUS "2. CMAKE INSTALL DIRECTORY IS '${CMAKE_INSTALL_PREFIX}'")
    message (STATUS "2. SETTING EXTERNAL_BMAD_DIRECTORY to value of ${BUILD_DIR}")
  endif()  

  set(INSTALL_IN_SEPARATE_DIRS 0)
#set_property(GLOBAL PROPERTY INSTALL_IN_SEPARATE_DIRS 0)

  if(DEFINED CACHE{CMAKE_SEPARATE_DIRS})

#-CMAKE_SEPARATE_DIRS=true
    message (STATUS "BUILD REQUESTED TO PUT EACH LIBRARY IN ITS OWN SEPARATE DIRECTORY")
#    message (STATUS "SETTING EXTERNAL_BMAD_DIRECTORY to value of ${BUILD_DIR}")
    set(INSTALL_IN_SEPARATE_DIRS 1)
  endif()

  set_property(GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY ${CMAKE_ROLLOUT_CMAKE_FILES}/bmad-external-packages)

#define a function

  function(install_package package_name)

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message(STATUS "In a function called install_package - called with argument ${package_name}")
    endif()
    get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message(STATUS "Making sure the directory ${GLOBAL1} exists - if it does not, we create it")
    endif()
#jsl - do we need this anymore?
#    ensure_directory_exists("" ${GLOBAL1} "yes")
    install_the_external_package(${GLOBAL1} ${package_name})
  endfunction()

  #define a function
  function(install_the_external_package path package_name)

    message(STATUS "Now in 'install_the_external...' - A function with argument ${package_name}")
# do we know the name of the directory for this package_name 
# is it different than the package name itself?

#jsl - do we need this anymore?
#    ensure_directory_exists(${path} ${package_name} "no")
    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)

    message(STATUS "1. Going to look for ${GLOBAL2}/${package_name} - the directory with our source files - that was cloned from git")
    if (EXISTS ${GLOBAL2}/${package_name})
      message(STATUS "Found the (directory) package ${GLOBAL2}/${package_name}") # found package_name
      message(STATUS "Building the package ${package_name}!")
      build_package(${GLOBAL1}/${package_name} ${package_name})
    else()
      message(STATUS "Did not find the package ${GLOBAL2}/${package_name} - This is a problem.")
    endif()
  endfunction()

  #define a function
  function(install_the_external_package1 path package_name)
    message(STATUS "Now in 'install_the_external...' - A function with argument ${package_name}")

#jsl - do we need this anymore?
#    ensure_directory_exists(${path} ${package_name} "no")
    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
# does it have anything in it?
# if no, copy the tarfile to this location and untar it

    message(STATUS "2. Going to look for ${GLOBAL2}/${package_name}.tar.gz")
    if (EXISTS ${GLOBAL2}/${package_name}.tar.gz)
      message(STATUS "Found the package ${GLOBAL2}/${package_name}.tar.gz file") # found package_name
      message(STATUS "Now will copy it to ${GLOBAL1}/${package_name}/${package_name}.tar.gz")
      configure_file(${GLOBAL2}/${package_name}.tar.gz ${GLOBAL1}/${package_name}/${package_name}.tar.gz COPYONLY)
      if (EXISTS ${GLOBAL1}/${package_name}/${package_name}.tar.gz)
        message(STATUS "Now have the copied file where we want it - let's build it!")
	build_package(${GLOBAL1}/${package_name} ${package_name})
      else()
	message(FATAL_ERROR, "For some reason, could not copy file into place - ${GLOBAL1}/${package_name}/${package_name}.tar.gz - for now, I think better to just give up at this point")
      endif()
    else()
# did not exist
      message(STATUS "Looked but did not find the package ${package_name}.tar.gz") # found package_name
      message(FATAL_ERROR, "I think better to just give up at this point")
#	    configure_file(${GLOBAL2}/${package_name}.tar.gz ${GLOBAL1}/${package_name}/${package_name}.tar.gz COPYONLY)
    endif()
#	file()
#	install_the_external_package(${package_name})
  endfunction()


  function(ensure_directory_exists path dirname shouldcreate)

# FYI - For windows
#set(USER_HOME_DIRECTORY $ENV{USERPROFILE})
#message(STATUS "User Home Directory: ${USER_HOME_DIRECTORY}")
    message(STATUS "ensure directory exists - called with 1) '${path}' and 2 '${dirname}'")
    set(P_WITH_D_MAYBE "${path}/${dirname}")
    if ("${path}" STREQUAL "")
#	message("Yes it is empty!")
      set(P_WITH_D_MAYBE "${dirname}")
    endif()
    message(STATUS "P_WITH_D_MAYBE is '${P_WITH_D_MAYBE}'")
    message(STATUS "Making sure directory exists ${P_WITH_D_MAYBE}")

#	get_filename_component(_fullpath "${_dir}" REALPATH)
    if (EXISTS "${P_WITH_D_MAYBE}")
	# "${_fullpath}/CMakeLists.txt")
      message (STATUS "directory found - ${P_WITH_D_MAYBE}")
    else()
      message (STATUS "Check if should create the directory - since we didn't find it ${P_WITH_D_MAYBE}")
      if ("${shouldcreate}" STREQUAL "yes")
        message (STATUS "'${dirname}' directory not found - use wants to create it")
	#should this be done at 1 install time, 2 build system generation time, or at 3 build time?
	# the only one that worked for me was number 2 - and it was created after my first cmake .
	#	1
	#		install(DIRECTORY DESTINATION ${path}${dirname})
	#	2
	# create the directory
			

	file(MAKE_DIRECTORY ${P_WITH_D_MAYBE})
		
	# a last check to make sure we created it - otherwise, fail out of everything
	message (STATUS "Just created the directory ${P_WITH_D_MAYBE} - check again to see if it exists")
	if (EXISTS "${P_WITH_D_MAYBE}")
	# "${_fullpath}/CMakeLists.txt")
	  message (STATUS "directory was successfully created - directory found")
	else()
	  message (FATAL_ERROR "directory still not found - I tried my best - aborting - ")
	endif()
	#	3
	#		${CMAKE_COMMAND} -E make_directory ${dirname}
      else()

	message (STATUS "'${dirname}' directory was not found - this routine called with flag to not create it")
	message (STATUS "was just curious - not creating ${dirname}")

      endif()
    endif()
  endfunction()


  function(build_package path dirname)

    message(STATUS "building ${path} ${dirname}")
#	COMMAND ${CMAKE_COMMAND} -E tar xvzf {path}/${dirname}.tar.gz
#no longer doing extract - just files should be here now!
#	file(ARCHIVE_EXTRACT INPUT ${path}/${dirname}.tar.gz DESTINATION ${path})
#    message(STATUS "HERE NOW ${path}")
    if ("${dirname}" STREQUAL "hdf5")
      build_hdf5()
#      message (STATUS "is ${dirname} hdf5")
    else()
#      message (STATUS "is ${dirname} not hdf5")
      if ("${dirname}" STREQUAL "lapack")
        build_lapack()
      elseif ("${dirname}" STREQUAL "plplot")			
	build_plplot()
      elseif ("${dirname}" STREQUAL "fftw")			
	build_fftw()
      elseif ("${dirname}" STREQUAL "openmpi")			
	build_openmpi()
#		elseif ("${dirname}" STREQUAL "gsl")			
#			build_gsl()
      elseif ("${dirname}" STREQUAL "fgsl")
        if (EXISTS ${path}/${dirname})
#			    MESSAGE (STATUS "CHECKING IF ${path}/${dirname} exists AND REMOVING")
	  file(REMOVE_RECURSE "${path}/${dirname}")
	endif()
#			file(RENAME ${path}/${dirname}-1.6.0 ${path}/${dirname})
#			MESSAGE (STATUS "Renaming ${path}/${dirname}-1.6.0 to ${path}/${dirname}")
	build_fgsl()
      elseif ("${dirname}" STREQUAL "lapack95")
        # before we build it, we change out the CMakeLists.txt file
	# the one shipped with Bmad is not good for our purposes
#	MESSAGE (STATUS "For LAPACK95 - will place CMakeLists.txt file into ${path}/${dirname}")
#	file(COPY ${THE_PARENT_PATH}/external_project/LAPACK95_CMakeLists.txt DESTINATION ${path}/${dirname})

#			file(COPY /Users/jlaster/BmadFiles/LAPACK95_CMakeLists.txt DESTINATION ${path}/${dirname})
#			file(RENAME ${path}/${dirname}/LAPACK95_CMakeLists.txt ${path}/${dirname}/CMakeLists.txt)
	build_lapack95()
      elseif ("${dirname}" STREQUAL "xraylib")
	build_xraylib()
      endif()

    endif()
#	cd 
  endfunction()
	

  function(test_function)
    add_custom_target( unZip ALL)
#	add_custom_command(TARGET unZip
    add_custom_command(TARGET unZip PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/${dirname}/
    COMMAND ${CMAKE_COMMAND} -E tar xzf {CMAKE_SOURCE_DIR}/${dirname}.tar.gz
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    DEPENDS ${CMAKE_SOURCE_DIR}/${dirname}.tar.gz
    COMMENT "Unpacking ${dirname}.tar.gz"
#	add_custom_command(TARGET unZip PRE_BUILD
#		COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/abc/
#		COMMAND ${CMAKE_COMMAND} -E tar xzf {CMAKE_SOURCE_DIR}/abc.zip
#	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
#	DEPENDS ${CMAKE_SOURCE_DIR}/abc.zip
#	COMMENT "Unpacking abc.zip"
    VERBATIM)
  endfunction()

  function(build_hdf5)

    set (func_name hdf5)
    set (func_name_cap HDF5)

    enable_language(Fortran)

    include(ExternalProject)

#    message (STATUS "IN SETTING OF HDF5_DESTDIR (function build_hdf5) - CMAKE_INSTALL_PREFIX IS ${CMAKE_INSTALL_PREFIX}")

    if(BUILD_${func_name_cap})

      message(STATUS "User wants to build ${func_name_cap}")


      if (BUILD_ANYWAY)
      # user does not care if there is a version of HDF5 on the system
      # user desires to build a fresh copy

        message(STATUS "User wants to build ${func_name_cap} even if already installed")
        now_really_build_hdf5()

      else()

        message(STATUS "Checking to see if we should build ${func_name_cap} - will not build if it is already installed")

#        find_package(${func_name_cap} COMPONENTS Fortran)
#        if(${func_name_cap}_Fortran_FOUND)

    # set hdf5_DESTDIR to have install directory by default
    set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
      set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
    endif()

        file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})


	find_package(${func_name_cap} COMPONENTS Fortran)
        if (${func_name}_FOUND)
  
#jsl - I do not see where this file exists - maybe a Scott special?
          message(STATUS "${func_name_cap}_Fortran was found - continuing - Scott had a test that I am not implementing right now - do we need it?")
#          message(STATUS "${func_name_cap}_Fortran was found - testing it")
#          message(STATUS "${func_name_cap} testing the fortran binary")

#          set(test_hdf5_fn "${CMAKE_CURRENT_BINARY_DIR}/test-hdf5.f90")

#          file(WRITE "${test_hdf5_fn}" "\
#            program hdf5_test\n\
#            use hdf5\n\
#            integer err\n\
#            call h5open_f(err)\n\
#            call h5close_f(err)\n\
#            end program hdf5_test\n"
#          )

#          message(STATUS "compiling the test_hdf5")

#          try_compile(test_hdf5
#            "${CMAKE_CURRENT_BINARY_DIR}/test-hdf5"
#            SOURCES "${test_hdf5_fn}"
#            LINK_LIBRARIES ${HDF5_Fortran_LIBRARIES}
#            CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${HDF5_Fortran_INCLUDE_DIRS}"
#          )
#          file(REMOVE "${test_hdf5_fn}")
#          message(STATUS "Do we have test_hdf5")

#          if (NOT test_hdf5)
#	    message(STATUS "We do not have a valid test_hdf5")
#            now_really_build_hdf5()

#          else()

#            message(STATUS "We have a valid version of ${func_name} - Add the ${func_name} target - 1")

#          endif()  
  
        else()

          message(STATUS "We do not have a valid version of the ${func_name} - Add the hdf5 target - 2")
          #maybe this is where we do the hdf5 build?
          now_really_build_hdf5()
        # had to comment this out - I do not understand why
        endif()

      endif()

    else()

      message(STATUS "No need to build ${func_name_cap}")

    endif()

  endfunction()


  function(now_really_build_hdf5)

    set (func_name hdf5)
    set (func_name_cap HDF5)

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message(STATUS "Have reached here (${func_name}) first")
      message(STATUS "Value of External bmad directory is ${ATEST1}")
      message(STATUS "Value of External bmad directory is ${EXTERNAL_BMAD_SOURCE_DIRECTORY}")
      message(STATUS "Value of GLOBAL1 is ${GLOBAL1}")
      message(STATUS "Value of GLOBAL2 is ${GLOBAL2}")
      message(STATUS "Value of cmake install prefix is ${CMAKE_INSTALL_PREFIX}")
    endif()

    # set hdf5_DESTDIR to have install directory by default
    set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
      set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
    endif()

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message(STATUS "Getting ready to set ${func_name}_DESTDIR to ${${func_name}_DESTDIR}")
    endif()

#    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
#      message ("Set ${func_name}_DESTDIR - value is now - ${${func_name}_DESTDIR}")
#    endif()

#    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
#      message ("Set ${func_name}_DESTDIR - value before ExternalProject_Add is now - ${${func_name}_DESTDIR}")
#    endif()

    set(${func_name}_build_type "--enable-build-mode=production")

    if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
      set(${func_name}_build_type "--enable-build-mode=debug")
    endif()

    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})

    ExternalProject_Add(${func_name}
      SOURCE_DIR "${GLOBAL1}/${func_name}"

      CMAKE_CACHE_ARGS
        -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
	-DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

      CONFIGURE_COMMAND
	"${GLOBAL1}/${func_name}/configure"
	"--prefix=${${func_name}_DESTDIR}"
#NOTE - IF THERE IS A NEED FOR .a instead of .so, would need to build in an if/endif() and have separate ExternalProject_Add - or at least separate variables
        "${${func_name}_build_type}"
	"--enable-fortran"
	"--enable-cxx"
	"--without-zlib"
	"--enable-shared"
# THIS SWITCH DECIDES if .a or .so
	"--disable-static"
	"--disable-tests"
	"--includedir=${${func_name}_DESTDIR}/include/${func_name}"
# THIS did not work!! - directory doesn't exist - guessing I have to make it on my own if this is desired!
#	"--with-fmoddir=${${func_name}_DESTDIR}/lib/fortran/modules/${func_name}"

# THIS IS STILL CONFUSING - WHY IS BUILD_COMMAND OF JUST make - DOING A make install?
# I THINK I READ SOMEWHERE THAT ExternalProject_Add ALWAYS DOES A make install - DOES THIS MAKE SENSE?
        BUILD_ALWAYS true
	BUILD_COMMAND make
	INSTALL_COMMAND make install
    )

    message ("Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

    install(
      DIRECTORY
      COMPONENT ${func_name}
      DESTINATION "${${func_name}_DESTDIR}"
      USE_SOURCE_PERMISSIONS
    )

#    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
#
#    message(STATUS "Copy - From - ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake to ${${func_name}_DESTDIR}")
    message(STATUS "Finished setting up the build needed for ${func_name}")

  endfunction()


  function(build_lapack)

    set (func_name lapack)
    set (func_name_cap LAPACK)

    include(ExternalProject)

    if(BUILD_${func_name_cap})

      message(STATUS "User wants to build ${func_name_cap}")

      if (BUILD_ANYWAY)

          message(STATUS "User wants to build ${func_name_cap} even if already installed")
#	  set(CMAKE_DISABLE_FIND_PACKAGE_lapack TRUE)
#	  message(STATUS "Value of CMAKE_DISABLE_FIND_PACKAGE_LAPACK is ${CMAKE_DISABLE_FIND_PACKAGE_lapack}")
          now_really_build_lapack()

        else()

          message(STATUS "Checking to see if we should build ${func_name_cap} - will not build if it is already installed")



        # first layout how to find the file!
        # set ${func_name}_DESTDIR to have install directory by default
        set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

        if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
          set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
        endif()

    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})


          find_package(${func_name_cap})
          if(${func_name}_FOUND)
            message(STATUS "No need to build ${func_name_cap} - already found")
          else()
	    message(STATUS "Could not find ${func_name_cap} - building ${func_name} now")
	  now_really_build_lapack()
        endif()

      endif()

    else()

      message(STATUS "No need to build ${func_name_cap}")

    endif()

  endfunction()

  function(now_really_build_lapack)

    set (func_name lapack)
    set (func_name_cap LAPACK)

    message(STATUS "Now really building ${func_name}")

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

    # set ${func_name}_DESTDIR to have install directory by default
    set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
	set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
    endif()

    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
        message ("Set ${func_name}_DESTDIR - value has been set to - ${${func_name}_DESTDIR}")
    endif()

    ExternalProject_Add(${func_name}
	SOURCE_DIR "${GLOBAL1}/${func_name}"

	CMAKE_ARGS
	  -DCMAKE_INSTALL_PREFIX:PATH=${${func_name}_DESTDIR}
	  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
	  # need this otherwise end up with ${func_name} and blas in /lib64!
#          -DBUILD_INDEX64_EXT_API:STRING="OFF"
          -DBUILD_INDEX=OFF
          -DBUILD_INDEX64_EXT_API=OFF
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
#	  -DCMAKE_IN
#	  -DCMAKE_Fortran_FLAGS=-m32
#          -DCMAKE_C_FLAGS=-m32
# -D CMAKE_Fortran_FLAGS="-m32"

#		-DCMAKE_INSTALL_PREFIX=${OUTPUT_DIR} \
#		-DBUILD_SHARED_LIBS=ON \
#		-DBUILD_TESTING=${TEST_STATUS} \
		-DBUILD_DEPRECATED=YES
		-DCBLAS=OFF
		-DLAPACKE=ON
		-DLAPACKE_WITH_TMG=ON
#		-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
#		-DCMAKE_INSTALL_LIBDIR=${${func_name}_DESTDIR}/lib
	#jsl - this from david - but I am adding library name!
		-DCMAKE_INSTALL_LIBDIR=${${func_name}_DESTDIR}/lib
                -DCMAKE_INSTALL_INCLUDEDIR=${${func_name}_DESTDIR}/include/${func_name}
#		-DCMAKE_INSTALL_INCDIR=${${func_name}_DESTDIR}/lib/lapack

	
#jsl - NOT SURE IF SHOULD BE SENT TO ./lib/fortran/modules/plplot or ./lib/fortran/modules

       		-DCMAKE_Fortran_MODULE_DIRECTORY=${${func_name}_DESTDIR}/lib/fortran/modules/${func_name}

#		-DCMAKE_Fortran_MODULE_DIRECTORY=${${func_name}_DESTDIR}/lib/fortran/modules


#		-DCMAKE_Fortran_COMPILER=${FC} \
#		-DCMAKE_Fortran_COMPILER_WORKS=TRUE \
#		-DCMAKE_C_COMPILER_WORKS=TRUE \



        CMAKE_CACHE_ARGS
	  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

        BUILD_ALWAYS true
	BUILD_COMMAND make
	INSTALL_COMMAND make install
	)

    message ("Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

    install(
        DIRECTORY
        COMPONENT ${func_name}
    	DESTINATION "${${func_name}_DESTDIR}"
    	USE_SOURCE_PERMISSIONS
    )

#    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})

    message(STATUS "Finished setting up the build needed for ${func_name}")

  endfunction()


  function(build_plplot)

    set (func_name plplot)
    set (func_name_cap PLPLOT)

    include(ExternalProject)

    if (BUILD_${func_name_cap})

      if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
        message(STATUS "User wants to build ${func_name_cap}")
      endif()

      if (BUILD_ANYWAY)

        if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
          message(STATUS "User wants to build ${func_name_cap} even if already installed")
        endif()

        now_really_build_plplot()

      else()

        if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
          message(STATUS "Checking to see if we should build ${func_name_cap} - will not build if it is already installed")
        endif()


        # first layout how to find the file!
        # set ${func_name}_DESTDIR to have install directory by default
        set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

        if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
          set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
        endif()

    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})

        find_package(${func_name_cap})

#       if(PLPLOT_FOUND)
        if (${func_name}_FOUND)
          if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    	    message(STATUS "No need to build ${func_name_cap} - already found")
          endif()
        else()
    	  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
  	    message(STATUS "Could not find ${func_name_cap} - building ${func_name} now")
	  endif()
	  now_really_build_plplot()
        endif()
      endif()

    else()

      if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
        message(STATUS "No need to build ${func_name_cap}")
      endif()

    endif()

  endfunction()

  function(now_really_build_plplot)

    set (func_name plplot)
    set (func_name_cap PLPLOT)

    message(STATUS "Now really building ${func_name}")

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message(STATUS "Values - global1 ${GLOBAL1} global2 ${GLOBAL2} ${func_name}_destdir ${${func_name}_DESTDIR}")
    endif()

    # set ${func_name}_DESTDIR to have install directory by default
    set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
      set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
    endif()

    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message ("Set ${func_name}_DESTDIR - value has been set to - ${${func_name}_DESTDIR}")
    endif()

    ExternalProject_Add(${func_name}

      SOURCE_DIR "${GLOBAL1}/${func_name}"

      CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${${func_name}_DESTDIR}
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DDEFAULT_NO_DEVICES=ON
        -DDEFAULT_NO_QT_DEVICES=ON
# This caused the ${func_name}.mod file to not be built!
        -DDEFAULT_NO_BINDINGS=ON
        -DENABLE_fortran:BOOL=ON
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DFORTRAN_MOD_DIR=${${func_name}_DESTDIR}/lib/fortran/modules

      CMAKE_CACHE_ARGS
        -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

      CMAKE_ARGS
        -DPLD_pdfcairo=ON
        -DPLD_pscairo=ON
        -DPLD_pngcairo=ON
        -DPLD_svgcairo=ON
        -DPLD_xwin=ON
        -DHAVE_SHAPELIB=OFF
        -DCMAKE_VERBOSE_MAKEFILE=true
        -DUSE_RPATH=ON
        -DPLD_psc=OFF
        -DPL_HAVE_QHULL=OFF
        -DENABLE_tk=OFF
        -DENABLE_tcl=OFF
        -DENABLE_java=OFF
        -DENABLE_python=OFF
        -DENABLE_ada=OFF
        -DENABLE_wxwidgets=OFF
        -DENABLE_cxx=OFF
        -DENABLE_octave=OFF
        -DBUILD_TEST=OFF
    
      BUILD_ALWAYS true
      BUILD_COMMAND make
      INSTALL_COMMAND make install
    )

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message (STATUS "Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")
    endif()

    install(
      DIRECTORY
      COMPONENT ${func_name}
      DESTINATION "${${func_name}_DESTDIR}"
      USE_SOURCE_PERMISSIONS
    )

    message (STATUS "Value of CMAKE_MODULE_PATH IS ${CMAKE_MODULE_PATH}")

#    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name}lib.cmake DESTINATION ${GLOBAL1}/${func_name})
#    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/FindPLPLOT.cmake DESTINATION ${GLOBAL1}/${func_name})
#    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
#
    message(STATUS "Finished setting up the build needed for ${func_name}")

  endfunction()

  function(build_fftw)

    set (func_name fftw)
    set (func_name_cap FFTW)

    include(ExternalProject)

    if(BUILD_${func_name_cap})

      message(STATUS "User wants to build ${func_name_cap}")

      if (BUILD_ANYWAY)

        message(STATUS "User wants to build ${func_name_cap} even if already installed")
        now_really_build_fftw()

      else()

        message(STATUS "Checking to see if we should build ${func_name_cap} - will not build if it is already installed")

        # first layout how to find the file!
        # set ${func_name}_DESTDIR to have install directory by default
        set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

        if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
          set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
        endif()

	file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})

        find_package(${func_name_cap})
        if(${func_name}_FOUND)
          message(STATUS "No need to build ${func_name_cap} - already found")
        else()
	  message(STATUS "Could not find ${func_name_cap} - building ${func_name} now")
	  now_really_build_fftw()
        endif()

      endif()

    else()

      message(STATUS "No need to build ${func_neme_cap}")

    endif()

  endfunction()

  function(now_really_build_fftw)

    set (func_name fftw)
    set (func_name_cap FFTW)

    message(STATUS "Now really building ${func_name}")

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

    message(STATUS "Values - global1 ${GLOBAL1} global2 ${GLOBAL2} ${func_name}_destdir ${${func_name}_DESTDIR}")

    # set ${func_name}_DESTDIR to have install directory by default
    set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
      set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
    endif()

#    set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})

	file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message ("Set ${func_name}_DESTDIR - value has been set to - ${${func_name}_DESTDIR}")
    endif()

    set(${func_name}_build_type "")

    if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
      set(${func_name}_build_type "--enable-debug")
    endif()

    ExternalProject_Add(${func_name}

      SOURCE_DIR "${GLOBAL1}/${func_name}"
      CONFIGURE_COMMAND
        "${GLOBAL1}/${func_name}/configure"
        "--prefix=${${func_name}_DESTDIR}"
        # need this otherwise end up with lapack and blas ${func_name}3 in /lib64 and not a shared object!!
	"--enable-shared"
	"--includedir=${${func_name}_DESTDIR}/include/${func_name}"
	"${${func_name}_build_type}"
	

      CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${${func_name}_DESTDIR}
#        -DCMAKE_INSTALL_INCLUDEDIR=${${func_name}_DESTDIR}/include/${func_name}
	-DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DENABLE_fortran:BOOL=ON

      CMAKE_CACHE_ARGS
	-DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
	-DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

      CMAKE_ARGS
	-DCMAKE_VERBOSE_MAKEFILE=true
    
      BUILD_ALWAYS true
      BUILD_COMMAND make
      INSTALL_COMMAND make install
    )

    message ("Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

    install(
        DIRECTORY
        COMPONENT ${func_name}
    	DESTINATION "${${func_name}_DESTDIR}"
    	USE_SOURCE_PERMISSIONS
    )

#    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name}lib.cmake DESTINATION ${${func_name}_DESTDIR})

    message(STATUS "Finished setting up the build needed for ${func_name}")

  endfunction()

  function(build_openmpi)

    set (func_name openmpi)
    set (func_name_cap OPENMPI)

    include(ExternalProject)

    if(BUILD_${func_name_cap})

      message(STATUS "User wants to build ${func_name_cap}")

      if (BUILD_ANYWAY)

        message(STATUS "User wants to build ${func_name_cap} even if already installed")
        now_really_build_openmpi()

      else()

        message(STATUS "Checking to see if we should build ${func_name_cap} - will not build if it is already installed")

        set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

        if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
          set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
        endif()

#  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name}lib.cmake  DESTINATION ${${func_name}_DESTDIR})
  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name}.cmake  DESTINATION ${${func_name}_DESTDIR})

        find_package(${func_name_cap})
        if(${func_name}_FOUND)
          message(STATUS "No need to build ${func_name_cap} - already found")
        else()
	  message(STATUS "Could not find ${func_name_cap} - building ${func_name} now")
  	now_really_build_openmpi()
        endif()

      endif()
    else()

      message(STATUS "No need to build ${func_name_cap}")

    endif()

  endfunction()

  function(now_really_build_openmpi)

    set(func_name "openmpi")
    set(func_name "OPENMPI")

    message(STATUS "Now really building ${func_name}")

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

#    message(STATUS "Values - global1 ${GLOBAL1} global2 ${GLOBAL2} ${func_name}_destdir ${${func_name}_DESTDIR}")

  # set ${func_name}_DESTDIR to have install directory by default
    set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
      set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
    endif()

  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name}.cmake  DESTINATION ${${func_name}_DESTDIR})

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message ("Set ${func_name}_DESTDIR - value has been set to - ${${func_name}_DESTDIR}")
    endif()

    message(STATUS "autoreconf dir is ${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
    set(${func_name}_autoreconfdir "${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")

    if(EXISTS ${GLOBAL1}/${func_name}/configure.ac)
      message (STATUS "Directory ${GLOBAL1}/${func_name} does exist!")
    else()
      message (STATUS "Directory ${GLOBAL1}/${func_name} does not exist")
    endif()

    execute_process(
      WORKING_DIRECTORY "${GLOBAL1}/${func_name}"
      COMMAND "autogen.pl"
      "--force"
#  "--install"
#    COMMAND "autoreconf" "--install"
#    COMMAND "autoreconf" "-f" "-i"
      RESULT_VARIABLE status
    )

    execute_process(
      WORKING_DIRECTORY "${GLOBAL1}/${func_name}"
#    COMMAND "autogen.pl"
#  "--install"
      COMMAND "autoreconf"
      "--install"
#    COMMAND "autoreconf" "-f" "-i"
      RESULT_VARIABLE status
    )

#  execute_process(
#    WORKING_DIRECTORY "${GLOBAL1}/${func_name}"
#    COMMAND "autogen.pl"
#  "--install"
#    COMMAND "autoreconf" "--install"
#    COMMAND "autoreconf" "-f" "-i"
#    RESULT_VARIABLE status
#  )

#  message (STATUS "Result of autoreconf is ${status}")

    message(STATUS "finished with autoreconf dir in ${GLOBAL1}/${func_name} - status is ${status}")

    set (${func_name}_build_type "")
    if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
      set(${func_name}_build_type "--enable-debug")
    endif()

    ExternalProject_Add(${func_name}

      SOURCE_DIR "${GLOBAL1}/${func_name}"
      CONFIGURE_COMMAND
        "${GLOBAL1}/${func_name}/configure"
        "--prefix=${${func_name}_DESTDIR}"
        "--enable-shared=${BUILD_SHARED_LIBS}"
        "${${func_name}_build_type}"

      CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${${func_name}_DESTDIR}
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DENABLE_fortran:BOOL=ON

      CMAKE_CACHE_ARGS
        -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

      CMAKE_ARGS
        -DCMAKE_VERBOSE_MAKEFILE=true
    
      BUILD_ALWAYS true  
      BUILD_COMMAND make
      INSTALL_COMMAND make install
    )

    message ("Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

    install(
      DIRECTORY
      COMPONENT ${func_name}
      DESTINATION "${${func_name}_DESTDIR}"
      USE_SOURCE_PERMISSIONS
    )

#  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name}lib.cmake  DESTINATION ${${func_name}_DESTDIR})

    message(STATUS "Finished setting up the build needed for ${func_name}")

  endfunction()


  function(build_fgsl1)

    include(ExternalProject)

    if(BUILD_FGSL)

      message(STATUS "User wants to build FGSL")

      if (BUILD_ANYWAY)

        message(STATUS "User wants to build FGSL even if already installed")
        now_really_build_fgsl()

    else()

      message(STATUS "Checking to see if we should build FGSL - will not build if it is already installed")


        # set ${func_name}_DESTDIR to have install directory by default
        set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

        if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
          set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
        endif()

      file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name}.cmake DESTINATION ${GLOBAL1}/${func_name})

      find_package(FGSL)
#      if(${func_name}_FOUND)
#      find_package(${func_name_cap})

#      if(${func_name}_FOUND)

#      if(fgsl_FOUND)
      message (STATUS "value of JSL_FOUND is ${JSL_FOUND}")
      if(JSL_FOUND)
        message(STATUS "No need to build FGSL - already found")
      else()
#	message(STATUS "Could not find FGSL - building fgsl now")
	now_really_build_fgsl()
      endif()

    endif()

  else()

    message(STATUS "No need to build FGSL")

  endif()

endfunction()

function(now_really_build_fgsl)

  set(pre_func_name "gsl")
  set(pre_func_name_cap "GSL")
  set(func_name "fgsl")
  set(func_name_cap "FGSL")

  message(STATUS "Now really building ${func_name}")

  message(STATUS "Have reached here - ${func_name}")

  get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
  get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

#  message ("Value of global1 is ${GLOBAL1}")
#  message ("Value of global2 is ${GLOBAL2}")
#  message ("Value of CMAKE_CURRENT_BINARY_DIR is ${CMAKE_CURRENT_BINARY_DIR}")

  set(${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})
  set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

  if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
    set (${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/gsl)
    set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
  endif()

  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    message ("Set ${pre_func_name}_DESTDIR - value has been set to - ${${pre_func_name}_DESTDIR}")
    message ("Set ${func_name}_DESTDIR - value has been set to - ${${func_name}_DESTDIR}")
  endif()

  message(STATUS "In GlobalVariables.cmake - Building the project with a build type of ${CMAKE_BUILD_TYPE}")

  set(NEED_TO_BUILD_GSL 0)

        # set ${func_name}_DESTDIR to have install directory by default
        set(${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

        if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
          set (${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${pre_func_name})
        endif()

  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${pre_func_name_cap}.cmake  DESTINATION ${${pre_func_name}_DESTDIR})
  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${GLOBAL1}/${${func_name}_DESTDIR})

  find_package(${pre_func_name_cap})

  if(${pre_func_name}_VERSION)

    set(STR1 ${${pre_func_name}_VERSION})
    set(STR2 "2.6")

    if("${STR1}" VERSION_LESS "${STR2}")

      message(STATUS "Installed version is less than 2.6 - build GSL")
      set(NEED_TO_BUILD_${pre_func_name} 1)
 
    else()

      message(STATUS "Installed version is equal to or greater than 2.6 - no need to build ${pre_func_name}")
      if (${CMAKE_INSTALL_ANYWAY})
        message(STATUS "Installing ${pre_func_name} anyway - that is, we found the right version, but laying down code to build anyway")
	set(NEED_TO_BUILD_${pre_func_name} 1)
      endif()
	
    endif()

  else()

    message(STATUS "No ${pre_func_name} version found - probably not installed - build ${pre_func_name}")
    set(NEED_TO_BUILD_${pre_func_name} 1)

  endif()

  if (${NEED_TO_BUILD_${pre_func_name}} EQUAL 1)

    set(${pre_func_name}_build_type "")

    if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
      set(${pre_func_name}_build_type "CFLAGS=-g -O0")
#      set(gsl_build_type "-d")
    endif()

    ExternalProject_Add(${pre_func_name}

      SOURCE_DIR "${GLOBAL1}/${pre_func_name}"

      CONFIGURE_COMMAND

        "${GLOBAL1}/${pre_func_name}/configure"
        "--prefix=${${pre_func_name}_DESTDIR}"
        "--enable-shared"
        "--disable-static"
	"--disable-tests"
	"${${pre_func_name}_build_type}"

      CMAKE_ARGS
	-DCMAKE_INSTALL_PREFIX:PATH=${${pre_func_name}_DESTDIR}
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}

      CMAKE_CACHE_ARGS
	-DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

      BUILD_ALWAYS true
      BUILD_COMMAND make
      INSTALL_COMMAND make install
    )

    message ("Set ${pre_func_name}_DESTDIR - value After ExternalProject_Add is now - ${${pre_func_name}_DESTDIR}")

    install(
      DIRECTORY
      COMPONENT ${pre_func_name}
      DESTINATION "${${pre_func_name}_DESTDIR}"
      USE_SOURCE_PERMISSIONS
    )

    message(STATUS "Finished the NEED TO BUILD section for ${pre_func_name}")

  else()

    add_custom_target(${pre_func_name} "true")
    message(STATUS "No reason to build ${pre_func_name}")

  endif()

  message(STATUS "Finished setting up the build needed for ${pre_func_name}")

  if(EXISTS ENV{PKG_CONFIG_PATH})
    message ("pkg_config_path does exist")
    set(${func_name}_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/${pre_func_name}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
  else()
    message ("pkg_config_path does not exist")
    set(${func_name}_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/${pre_func_name}/lib/pkgconfig")
  endif()

  message ("Starting setup of ${func_name}")

  if (CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    set(${func_name}_fcflags "-ffree-line-length-none")
  endif()

  if ("${CMAKE_Fortran_FLAGS}" STREQUAL "" AND DEFINED ${func_name}_fcflags)
    set (${func_name}_fcflags "FCFLAGS=${${func_name}_fcflags}")
  elseif (NOT "${CMAKE_Fortran_FLAGS}" STREQUAL "" AND NOT DEFINED ${func_name}_fcflags)
    set (${func_name}_fcflags "FCFLAGS=${CMAKE_Fortran_FLAGS}")
  elseif (NOT "${CMAKE_Fortran_FLAGS}" STREQUAL "" AND DEFINED ${func_name}_fcflags)
    set (${func_name}_fcflags "FCFLAGS=${CMAKE_Fortran_FLAGS} ${${func_name}_fcflags}")
  endif()

  set(${func_name}_pc_flags "PKG_CONFIG_PATH=${CMAKE_CURRENT_BINARY_DIR}/${pre_func_name}-prefix/src/${pre_func_name}-build:$ENV{PKG_CONFIG_PATH}")

  message(STATUS "Defining ExternalProject_Add for ${func_name}")

  message(STATUS "set ${func_name}_srcdir to ${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")

  set(${func_name}_srcdir "${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
	
  message(STATUS "Execute process autoreconf now!")

  message(STATUS " Another test")

  message(STATUS "autoreconf dir is ${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
  set(${func_name}_autoreconfdir "${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")

  if(EXISTS ${GLOBAL1}/${func_name}/configure.ac)
    message (STATUS "Directory ${GLOBAL1}/${func_name} does exist!")
  else()
    message (STATUS "Directory ${GLOBAL1}/${func_name} does not exist")
  endif()
  
# NOTE - JSL - I do not know how to set this to build into the build directory - modifies - that is, puts files into - the external package area.

  execute_process(
    WORKING_DIRECTORY "${GLOBAL1}/${func_name}"
    COMMAND "autoreconf" "--install"
    RESULT_VARIABLE status
  )

  message(STATUS "finished with autoreconf dir in ${GLOBAL1}/${func_name} - status is ${status}")

  message("PKG_CONFIG_PATH: $ENV{PKG_CONFIG_PATH} ${${func_name}_pc_flags}") 

  set(${func_name}_build_type "")

  if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
      set(${func_name}_build_type "CFLAGS=-g -O0")
#    set(fgsl_build_type "--debug")
  endif()

  ExternalProject_Add(${func_name}
    SOURCE_DIR "${GLOBAL1}/${func_name}"
    CONFIGURE_COMMAND
      "${GLOBAL1}/${func_name}/configure"
      "--prefix=${${func_name}_DESTDIR}"
      "--disable-static"
      "${${func_name}_fcflags}"
      "${${func_name}_pc_flags}"
      "${${func_name}_build_type}"

    CMAKE_ARGS
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}

    CMAKE_CACHE_ARGS
      -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

    BUILD_ALWAYS true
    BUILD_COMMAND make -j 1
    INSTALL_COMMAND make install
  )

  message ("Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

  if (${NEED_TO_BUILD_GSL} EQUAL 1)
    message(STATUS "If we had to build our own ${pre_func_name} - Set up dependency for ${func_name} - it depends on ${pre_func_name}!")
    add_dependencies(${func_name} ${pre_func_name})
  endif()

  install(
    DIRECTORY
    COMPONENT ${func_name}
    DESTINATION "${${func_name}_DESTDIR}"
    USE_SOURCE_PERMISSIONS
  )

# lastly, install a Findfgsllib.cmake file - for allowing cmake to find the build of fgsl (module)
#  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name}lib.cmake DESTINATION ${GLOBAL1}/${func_name})

  message(STATUS "Finished setting up the build needed for ${func_name}")

endfunction()



function(build_fgsl)

  set(func_name "fgsl")
  set(func_name_cap "FGSL")

  include(ExternalProject)

  if(BUILD_${func_name_cap})

    message(STATUS "User wants to build ${func_name_cap}")

    if (BUILD_ANYWAY)

      message(STATUS "User wants to build ${func_name_cap} even if already installed")
      now_really_build_fgsl()

    else()

      message(STATUS "Checking to see if we should build ${func_name_cap} - will not build if it is already installed")

        # set ${func_name}_DESTDIR to have install directory by default
        set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

        if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
          set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
        endif()

  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake  DESTINATION ${${func_name}_DESTDIR})

      find_package(${func_name_cap})
      if(${func_name}_FOUND)
        message(STATUS "No need to build ${func_name_cap} - already found")
      else()
	message(STATUS "Could not find ${func_name_cap} - building ${func_name} now")
	now_really_build_fgsl()
      endif()

    endif()

  else()

    message(STATUS "No need to build ${func_name_cap}")

  endif()

endfunction()

function(now_really_build_fgsl1)

  set(pre_func_name "gsl")
  set(pre_func_name_cap "GSL")
  set(func_name "fgsl")
  set(func_name_cap "FGSL")

  message(STATUS "Now really building ${func_name}")

  message(STATUS "Have reached here - ${func_name}")

  get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
  get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

#  message ("Value of global1 is ${GLOBAL1}")
#  message ("Value of global2 is ${GLOBAL2}")
#  message ("Value of CMAKE_CURRENT_BINARY_DIR is ${CMAKE_CURRENT_BINARY_DIR}")

  set(${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})
  set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

  if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
    set (${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${pre_func_name})
    set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
  endif()

  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    message ("Set ${pre_func_name}_DESTDIR - value has been set to - ${gsl_DESTDIR}")
    message ("Set ${func_name}_DESTDIR - value has been set to - ${${func_name}_DESTDIR}")
  endif()

  message(STATUS "In GlobalVariables.cmake - Building the project with a build type of ${CMAKE_BUILD_TYPE}")

  set(NEED_TO_BUILD_GSL 0)

        # set ${func_name}_DESTDIR to have install directory by default
        set(${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

        if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
          set (${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${pre_func_name})
        endif()

  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${pre_func_name_cap}.cmake  DESTINATION ${${pre_func_name}_DESTDIR})


  find_package(${pre_func_name_cap})

  if(GSL_VERSION)

    set(STR1 ${GSL_VERSION})
    set(STR2 "2.6")

    if("${STR1}" VERSION_LESS "${STR2}")

      message(STATUS "Installed version is less than 2.6 - build ${pre_func_name_cap}")
      set(NEED_TO_BUILD_GSL 1)
 
    else()

      message(STATUS "Installed version is equal to or greater than 2.6 - no need to build GSL")
      if (${CMAKE_INSTALL_ANYWAY})
        message(STATUS "Installing GSL anyway - that is, we found the right version, but laying down code to build anyway")
	set(NEED_TO_BUILD_GSL 1)
      endif()
	
    endif()

  else()

    message(STATUS "No GSL version found - probably not installed - build GSL")
    set(NEED_TO_BUILD_GSL 1)

  endif()

  if (${NEED_TO_BUILD_GSL} EQUAL 1)

    set(gsl_build_type "")

    if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
      set(gsl_build_type "CFLAGS=-g -O0")
#      set(gsl_build_type "-d")
    endif()

    ExternalProject_Add(gsl

      SOURCE_DIR "${GLOBAL1}/gsl"

      CONFIGURE_COMMAND

        "${GLOBAL1}/gsl/configure"
        "--prefix=${gsl_DESTDIR}"
        "--enable-shared"
        "--disable-static"
	"--disable-tests"
	"${gsl_build_type}"

      CMAKE_ARGS
	-DCMAKE_INSTALL_PREFIX:PATH=${gsl_DESTDIR}
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}

      CMAKE_CACHE_ARGS
	-DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

      BUILD_ALWAYS true
      BUILD_COMMAND make
      INSTALL_COMMAND make install
    )

    message ("Set gsl_DESTDIR - value After ExternalProject_Add is now - ${gsl_DESTDIR}")

    install(
      DIRECTORY
      COMPONENT gsl
      DESTINATION "${gsl_DESTDIR}"
      USE_SOURCE_PERMISSIONS
    )

    message(STATUS "Finished the NEED TO BUILD section for gsl")

  else()

    add_custom_target(gsl "true")
    message(STATUS "No reason to build gsl")

  endif()

  message(STATUS "Finished setting up the build needed for gsl")

  if(EXISTS ENV{PKG_CONFIG_PATH})
    message ("pkg_config_path does exist")
    set(${func_name}_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/${pre_func_name}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
  else()
    message ("pkg_config_path does not exist")
    set(${func_name}_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/${pre_func_name}/lib/pkgconfig")
  endif()

  message ("Starting setup of ${func_name}")

  if (CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    set(${func_name}_fcflags "-ffree-line-length-none")
  endif()

  if ("${CMAKE_Fortran_FLAGS}" STREQUAL "" AND DEFINED ${func_name}_fcflags)
    set (${func_name}_fcflags "FCFLAGS=${${func_name}_fcflags}")
  elseif (NOT "${CMAKE_Fortran_FLAGS}" STREQUAL "" AND NOT DEFINED ${func_name}_fcflags)
    set (${func_name}_fcflags "FCFLAGS=${CMAKE_Fortran_FLAGS}")
  elseif (NOT "${CMAKE_Fortran_FLAGS}" STREQUAL "" AND DEFINED ${func_name}_fcflags)
    set (${func_name}_fcflags "FCFLAGS=${CMAKE_Fortran_FLAGS} ${${func_name}_fcflags}")
  endif()

  set(${func_name}_pc_flags "PKG_CONFIG_PATH=${CMAKE_CURRENT_BINARY_DIR}/${pre_func_name}-prefix/src/${func_name}-build:$ENV{PKG_CONFIG_PATH}")

  message(STATUS "Defining ExternalProject_Add for ${func_name}")

  message(STATUS "set ${func_name}_srcdir to ${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")

  set(${func_name}_srcdir "${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
	
  message(STATUS "Execute process autoreconf now!")

  message(STATUS " Another test")

  message(STATUS "autoreconf dir is ${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
  set(${func_name}_autoreconfdir "${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")

  if(EXISTS ${GLOBAL1}/${func_name}/configure.ac)
    message (STATUS "Directory ${GLOBAL1}/${func_name} does exist!")
  else()
    message (STATUS "Directory ${GLOBAL1}/${func_name} does not exist")
  endif()
  
# NOTE - JSL - I do not know how to set this to build into the build directory - modifies - that is, puts files into - the external package area.

  execute_process(
    WORKING_DIRECTORY "${GLOBAL1}/${func_name}"
    COMMAND "autoreconf" "--install"
    RESULT_VARIABLE status
  )

  message(STATUS "finished with autoreconf dir in ${GLOBAL1}/${func_name} - status is ${status}")

  message("PKG_CONFIG_PATH: /home/cfsd/laster/bmad/external/lib $ENV{PKG_CONFIG_PATH} ${${func_name}_pc_flags}") 

  set(${func_name}_build_type "")

  if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
      set(${func_name}_build_type "CFLAGS=-g -O0")
#    set(fgsl_build_type "--debug")
  endif()

  ExternalProject_Add(${func_name}
    SOURCE_DIR "${GLOBAL1}/${func_name}"
    CONFIGURE_COMMAND
      "${GLOBAL1}/${func_name}/configure"
      "--prefix=${${func_name}_DESTDIR}"
      "--disable-static"
#      "--includedir=${${func_name}_DESTDIR}/lib/fortran/modules"
      "${${func_name}_fcflags}"
      "${${func_name}_pc_flags}"
      "${${func_name}_build_type}"

    CMAKE_ARGS
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}

    CMAKE_CACHE_ARGS
      -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

    BUILD_ALWAYS true
    BUILD_COMMAND make -j 1
    INSTALL_COMMAND make install
  )

  message ("Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

  if (${NEED_TO_BUILD_GSL} EQUAL 1)
    message(STATUS "If we had to build our own ${pre_func_name} - Set up dependency for ${func_name} - it depends on ${pre_func_name}!")
    add_dependencies(${func_name} ${pre_func_name})
  endif()

  install(
    DIRECTORY
    COMPONENT ${func_name}
    DESTINATION "${${func_name}_DESTDIR}"
    USE_SOURCE_PERMISSIONS
  )

# lastly, install a Findfgsllib.cmake file - for allowing cmake to find the build of fgsl (module)

#  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake  DESTINATION ${${func_name}_DESTDIR})

  message(STATUS "Finished setting up the build needed for ${func_name} - copied file to ${${func_name}_DESTDIR}")

endfunction()


function(build_lapack95)

  set (func_name lapack95)
  set (func_name_cap LAPACK95)

  include(ExternalProject)

  if(BUILD_${func_name_cap})

    message(STATUS "User wants to build ${func_name_cap}")

    if (BUILD_ANYWAY)

      message(STATUS "User wants to build ${func_name_cap} even if already installed")
      now_really_build_lapack95()

    else()

      message(STATUS "Checking to see if we should build ${func_name_cap} - will not build if it is already installed")

        set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

        if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
          set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
        endif()

	file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})

      find_package(${func_name_cap})
      if(${func_name}_FOUND)
        message(STATUS "No need to build ${func_name_cap} - already found")
      else()
	message(STATUS "Could not find ${func_name_cap} - building lapack95 now")
	now_really_build_lapack95()
      endif()

    endif()

  else()

    message(STATUS "No need to build ${func_name_cap}")

  endif()

endfunction()

function(now_really_build_lapack95)

  set(func_name "lapack95")
  set(func_name_cap "LAPACK95")

  message(STATUS "Now really building ${func_name}")

  get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
  get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

  MESSAGE (STATUS "For ${func_name} - will place  ${CMAKE_ROLLOUT_CMAKE_FILES}/${func_name_cap}_CMakeLists.txt file into ... ${GLOBAL1}/${func_name} and then rename it to ${GLOBAL1}/${func_name_cap}_CMakeLists.txt")

  MESSAGE (STATUS "Values: rename -  ${CMAKE_ROLLOUT_CMAKE_FILES}/${func_name_cap}_CMakeLists.txt   -  ${GLOBAL1}/${func_name}/CMakeLists.txt")
#  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/${func_name_cap}_CMakeLists.txt DESTINATION ${${func_name}_DESTDIR})
  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/${func_name_cap}_CMakeLists.txt DESTINATION ${GLOBAL1}/${func_name})
  file(RENAME ${GLOBAL1}/${func_name}/${func_name_cap}_CMakeLists.txt ${GLOBAL1}/${func_name}/CMakeLists.txt)

  set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

  if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
    set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
  endif()

  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})

  find_package(LAPACK)
  if (NOT LAPACK_FOUND)
    message(STATUS "BUILDING ${func_name} - LAPACK library not found")
  else()
    message(STATUS "BUILDING ${func_name} - FOUND LAPACK library")
  endif()
    
  # set lapack_DESTDIR to have install directory by default
  set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

  if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
    set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
  endif()

  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    message(STATUS "Getting ready to set ${func_name}_DESTDIR to ${CMAKE_INSTALL_PREFIX}/${func_name}")
  endif()

  ExternalProject_Add(${func_name}
    SOURCE_DIR "${GLOBAL1}/${func_name}"

    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${${func_name}_DESTDIR}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_Fortran_COMPILER:STRING=gfortran
      -DACC_CMAKE_VERSION=3.13.4
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}

    CMAKE_CACHE_ARGS
      -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

    BUILD_ALWAYS true
    BUILD_COMMAND make
    INSTALL_COMMAND make install
  )
	
  install(
    DIRECTORY
    COMPONENT ${func_name}
    DESTINATION "${${func_name}_DESTDIR}"
    USE_SOURCE_PERMISSIONS
  )

#  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})

  message(STATUS "Finished setting up the build needed for ${func_name}")

endfunction()


function(build_xraylib)

  set(func_name "xraylib")
  set(func_name_cap "XRAYLIB")

  include(ExternalProject)

  if(BUILD_${func_name_cap})

    message(STATUS "User wants to build ${func_name_cap}")

    if (BUILD_ANYWAY)

      message(STATUS "User wants to build ${func_name_cap} even if already installed")
      now_really_build_xraylib()

    else()

      message(STATUS "Checking to see if we should build ${func_name_cap} - will not build if it is already installed")

        set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

        if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
          set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
        endif()

  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake  DESTINATION ${${func_name}_DESTDIR})

      find_package(${func_name_cap})
      if(${func_name}_FOUND)
        message(STATUS "No need to build ${func_name_cap} - already found")
      else()
	message(STATUS "Could not find ${func_name_cap} - building ${func_name} now")
	now_really_build_xraylib()
      endif()

    endif()

  else()

    message(STATUS "No need to build ${func_name_cap}")

  endif()

endfunction()

function(now_really_build_xraylib)

  set(func_name "xraylib")
  set(func_name_cap "XRAYLIB")

  message(STATUS "Now really building ${func_name}")

  get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
  get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)


  # set ${func_name}_DESTDIR to have install directory by default
  set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

  if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
    set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
  endif()

  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake  DESTINATION ${${func_name}_DESTDIR})

  message(STATUS "set ${func_name}_srcdir to ${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix - value of ${func_name}_destdir is ${${func_name}_DESTDIR}")

  set(${func_name}_srcdir "${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
	
#  message(STATUS "Execute process autoreconf now!")

#  message(STATUS " Another test")

  message(STATUS "autoreconf dir is ${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
  set(${func_name}_autoreconfdir "${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")

  if(EXISTS ${GLOBAL1}/${func_name}/configure.ac)
  	message (STATUS "Directory ${GLOBAL1}/${func_name} does exist!")
  else()
  	message (STATUS "Directory ${GLOBAL1}/${func_name} does not exist")
  endif()

  execute_process(
    WORKING_DIRECTORY "${GLOBAL1}/${func_name}"
    COMMAND "autoreconf" "--install"
    RESULT_VARIABLE status
  )

#  message (STATUS "Result of autoreconf is ${status}")

  message(STATUS "finished with autoreconf dir in ${GLOBAL1}/${func_name} - status is ${status}")

  set (${func_name}_build_type "")
  if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
    set(${func_name}_build_type "--enable-debug")
  endif()

  ExternalProject_Add(${func_name}

    SOURCE_DIR "${GLOBAL1}/${func_name}"

    CONFIGURE_COMMAND
      "${GLOBAL1}/${func_name}/configure"
      "--prefix=${${func_name}_DESTDIR}"
      "--disable-idl"
      "--disable-java"
      "--disable-lua"
      "--disable-perl"
      "--disable-python"
      "--disable-python-numpy"
      "--disable-libtool-lock"
      "--disable-ruby"
      "--disable-php"
      "--disable-static"
      "${${func_name}_build_type}"

    CMAKE_ARGS
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}

    CMAKE_CACHE_ARGS
      -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

    BUILD_ALWAYS true
    BUILD_COMMAND make
    INSTALL_COMMAND make install
  )

  install(
    DIRECTORY
    COMPONENT ${func_name}
    DESTINATION "${${func_name}_DESTDIR}"
    USE_SOURCE_PERMISSIONS
  )

# lastly, install a Find${func_name}.cmake file - for allowing cmake to find the build of ${func_name} (module)
#  file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name}.cmake  DESTINATION ${${func_name}_DESTDIR})

  message(STATUS "Finished setting up the build needed for ${func_name}")

endfunction()

function(should_build_package package should_build)

  message(STATUS "Checking build for package ${package}")
  message(STATUS "status of build_all is ${BUILD_ALL}")
#	set (fgsl "FGSL")
  set (package_name_to_use "not set")
  package_map(${package} package_name_to_use)
  message(STATUS "3. VALUE OF package_name_to_use after calling package_map is now ${package_name_to_use}")
  mmessage(STATUS "VALUE OF BUILD_${package_name_to_use} is ${BUILD_${package_name_to_use}}")
  message(STATUS "VALUE OF BUILD_ALL is ${BUILD_ALL}")

  if (${BUILD_ALL} STREQUAL "ON")
    message(STATUS "Build all is ON!")
    set(${should_build} "YES" PARENT_SCOPE)
		
 else()
    message(STATUS - "BUILD_ALL IS NOT ON - package value is ${BUILD_${package_name_to_use}}")
    if (${BUILD_${package_name_to_use}} STREQUAL "ON")
      message(STATUS "Build for BUILD_${package_name_to_use} is ON!")
      set(${should_build} "YES" PARENT_SCOPE)
#			set(${BUILD_AT_LEAST_ONE} 1 PARENT_SCOPE)
      message(STATUS "Setting value of BUILD_AT_LEAST_ONE to be 1!")
      set_property(GLOBAL PROPERTY BUILD_AT_LEAST_ONE 1)
    else()		
      set(${should_build} "NO" PARENT_SCOPE)
    endif()
  endif()
#	message(STATUS "Value of should_build in GlobalVariables.cmake file should_build function is ${should_build}")
endfunction()


function(package_map package mapped_name)

if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
  message (STATUS "In a function called package_map")
endif()

  
#	message(STATUS "1. (package_map) called with ${package} : ${mapped_name}")
#	message(STATUS "(package_map) Checking build for package ${package}")
#	message(STATUS "(package_map) status of build_all is ${BUILD_ALL}")
#	set (fgsl "FGSL")
#	message(STATUS "(package_map) VALUE OF BUILD_${package} is ${BUILD_${package}}")
        set (local_mapped_name "NOT SET")

	if (${package} STREQUAL "fgsl")
 		set(${mapped_name} "FGSL" PARENT_SCOPE)
	        set (local_mapped_name "FGSL")
	elseif(${package} STREQUAL "h5cc")
 		set(${mapped_name} "HDF5" PARENT_SCOPE)
	        set (local_mapped_name "HDF5")
	elseif(${package} STREQUAL "lapack")
#		message(STATUS "(package_map) FOUND A MATCH for ${package}")
 		set(${mapped_name} "LAPACK" PARENT_SCOPE)
#		message(STATUS "2. now mapped_name in this function is ${mapped_name}")
	        set (local_mapped_name "LAPACK")
	elseif(${package} STREQUAL "lapack95")
 		set(${mapped_name} "LAPACK95" PARENT_SCOPE)
	        set (local_mapped_name "LAPACK95")
	elseif(${package} STREQUAL "plplot")
 		set(${mapped_name} "PLPLOT" PARENT_SCOPE)
	        set (local_mapped_name "PLPLOT")
	elseif(${package} STREQUAL "fftw")
 	        set(${mapped_name} "FFTW" PARENT_SCOPE)
	        set (local_mapped_name "FFTW")
	elseif(${package} STREQUAL "openmpi")
 		set(${mapped_name} "OPENMPI" PARENT_SCOPE)
	        set (local_mapped_name "OPENMPI")
	elseif(${package} STREQUAL "xraylib")
 		set(${mapped_name} "XRAYLIB" PARENT_SCOPE)
	        set (local_mapped_name "XRAYLIB")
	else()
		message(FATAL_ERROR "(package_map) Package name mapping not found - aborting - ${package}")
	endif()
        if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
	  message(STATUS "(package_map) Value of package - mapped name is ${package} - ${local_mapped_name}")
        endif()
endfunction()

function(set_build_flags)
# this function makes a determination if individual packages will be built, or if all packages will be built
# any package to be built will have its BUILD_PACKAGE_NAME variable set to ON after this function is called

if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
  message(STATUS "In set_build_flags function()")
endif()

  if (BUILD_ALL OR (NOT (BUILD_HDF5 OR BUILD_LAPACK OR BUILD_PLPLOT OR BUILD_FFTW OR BUILD_FGSL OR BUILD_LAPACK95 OR BUILD_XRAYLIB)))
    if (BUILD_ALL)
if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message(STATUS "BUILD_ALL is true, setting BUILD ON for all packages")
endif()
    else()
if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      message(STATUS "BUILD_ALL was not set, but no packages were set to build - user must want to build all packages")
endif()
    endif()
    set(BUILD_ALL ON PARENT_SCOPE)
    set(BUILD_HDF5 ON PARENT_SCOPE)
    set(BUILD_LAPACK ON PARENT_SCOPE)
    set(BUILD_PLPLOT ON PARENT_SCOPE)
    set(BUILD_FFTW ON PARENT_SCOPE)
    set(BUILD_FGSL ON PARENT_SCOPE)
    set(BUILD_LAPACK95 ON PARENT_SCOPE)
    set(BUILD_XRAYLIB ON PARENT_SCOPE)
#    set(BUILD_OPENMPI ON PARENT_SCOPE)
  endif()
  message(STATUS "Package(s) to be built:")
  foreach (PACKAGE HDF5 LAPACK PLPLOT FFTW FGSL LAPACK95 XRAYLIB) 
    if ( BUILD_${PACKAGE} )
      message(STATUS "\tBuilding package ${PACKAGE}")
    endif()
  endforeach()
  message(STATUS "")
endfunction()
