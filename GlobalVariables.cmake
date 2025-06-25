  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    mymessage(5 STATUS "This is the GlobalVariables.cmake file that was included - it contains global definitions!")
  endif()

  set_property(GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES "${CMAKE_ROLLOUT_CMAKE_FILES}/bmad-external-packages")
  # this should come from switch given to cmake build line - jsl

  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    # but not ${BMAD_EXTERNAL_PACKAGES} - need to understand
    mymessage(5 STATUS "All of the packages to be built can be found at ${CMAKE_ROLLOUT_CMAKE_FILES}/bmad-external-packages and ${BMAD_EXTERNAL_PACKAGES}")
  endif()

#  message("At this time, REQUIRE_OPENMP is ${REQUIRE_OPENMP}")

  # if the CMAKE_INSTALL_PREFIX is not an absolute path, then put the path in front!
  if(IS_ABSOLUTE "${CMAKE_INSTALL_PREFIX}")
    # nothing to do!
#    message("The string is a full path.")
  else()
    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
#      message("1. The string is not a full path. - setting with path - '${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_INSTALL_PREFIX}' - '${CMAKE_INSTALL_PREFIX}'")
    endif()
    mymessage(3 STATUS "Setting CMAKE_INSTALL_PREFIX TO SOURCE_DIR/INSTALL_PREFIX")
    set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_INSTALL_PREFIX})
    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
#      message("2. The string is not a full path. - setting with path - '${CMAKE_INSTALL_PREFIX}'")
    endif()
  endif()

  set_property(GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY ${BUILD_DIR})

  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    mymessage(5 STATUS "CMAKE INSTALL DIRECTORY IS '${CMAKE_INSTALL_PREFIX}'")
    mymessage(5 STATUS "SETTING EXTERNAL_BMAD_DIRECTORY to value of ${BUILD_DIR}")
  endif()

# Scott suggests user can add this to their INSTALL_PREFIX
#  set (APPEND_BUILD_TYPE "production")
#  # now add on to the CMAKE_INSTALL_PREFIX the BUILD_TYPE
#  if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
#    set (APPEND_BUILD_TYPE "debug")
#  endif()

#message(STATUS "VALUES - cmake_module_path: ${CMAKE_MODULE_PATH}")
#message(STATUS "ALPHA - ABCDE")
  if (EXISTS "${CMAKE_MODULE_PATH}")
    mymessage(2 STATUS "Module Path Enhanced - was already set")
#  if (CMAKE_MODULE_PATH)
#     set (CMAKE_MODULE_PATH ${CMAKE_INSTALL_PREFIX} ${CMAKE_INSTALL_PREFIX}/${APPEND_BUILD_TYPE} ${CMAKE_MODULE_PATH} ${CMAKE_MODULE_PATH}/${APPEND_BUILD_TYPE})
     set (CMAKE_MODULE_PATH ${CMAKE_PREFIX_PATH};${CMAKE_INSTALL_PREFIX};${CMAKE_MODULE_PATH})
  else()
    mymessage(3 STATUS "Module Path Enhanced - was not already set")
#     set (CMAKE_MODULE_PATH ${CMAKE_INSTALL_PREFIX} ${CMAKE_INSTALL_PREFIX}/${APPEND_BUILD_TYPE})
    set (CMAKE_MODULE_PATH ${CMAKE_PREFIX_PATH};${CMAKE_INSTALL_PREFIX})
  endif()

  mymessage(2 STATUS "VALUES - cmake_module_path: ${}")
  mymessage(2 STATUS "VALUES - cmake_prefix_path: ${CMAKE_PREFIX_PATH}")
  mymessage(2 STATUS "VALUES - cmake_install_prefix: ${CMAKE_INSTALL_PREFIX}")

  string(TIMESTAMP CURRENT_DATETIME "%m%d%Y_%H%M%S")
  mymessage(2 STATUS "Placing output of build in log file: ${CMAKE_CURRENT_BINARY_DIR}/build_${CURRENT_DATETIME}.log")
  set(CMAKE_BUILD_OUTPUT_LOGFILE ${CMAKE_CURRENT_BINARY_DIR}/build_${CURRENT_DATETIME}.log)
  
  set(RH9_RELEASE_FILE "/etc/os-release")
  mymessage(5 STATUS "DEFINING A VALUE FOR RH9_RELEASE_FILE - ${RH9_RELEASE_FILE}")

  #message(STATUS "CMAKE_MODULE_PATH now has a value of ${CMAKE_MODULE_PATH}")

  #  set (CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX}/${APPEND_BUILD_TYPE})
  if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    mymessage(5 STATUS "2. CMAKE INSTALL DIRECTORY IS '${CMAKE_INSTALL_PREFIX}'")
    mymessage(5 STATUS "2. SETTING EXTERNAL_BMAD_DIRECTORY to value of ${BUILD_DIR}")
  endif()  

  set(INSTALL_IN_SEPARATE_DIRS 0)
#set_property(GLOBAL PROPERTY INSTALL_IN_SEPARATE_DIRS 0)

  if(DEFINED CACHE{CMAKE_SEPARATE_DIRS})
    mymessage(1 STATUS "BUILD REQUESTED TO PUT EACH LIBRARY IN ITS OWN SEPARATE DIRECTORY")
    set(INSTALL_IN_SEPARATE_DIRS 1)
  endif()

  set_property(GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY ${CMAKE_ROLLOUT_CMAKE_FILES}/bmad-external-packages)



## ----------------------------------------------------------------------------------------
  #define functions

  function(install_package package_name)

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      mymessage(5 STATUS "In a function called install_package - called with argument ${package_name}")
    endif()
    get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
#    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
#      message(STATUS "Making sure the directory ${GLOBAL1} exists - if it does not, we create it")
#    endif()
#jsl - do we need this anymore?
#   ensure_directory_exists("" ${GLOBAL1} "yes")
    install_the_external_package(${GLOBAL1} ${package_name})

  endfunction()

## ----------------------------------------------------------------------------------------

  function(install_the_external_package path package_name)

    mymessage(5 STATUS "Now in 'install_the_external...' - A function with argument ${package_name}")
    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)

    mymessage(5 STATUS "1. Going to look for ${GLOBAL2}/${package_name} - the directory with our source files - that was cloned from git")
    if (EXISTS ${GLOBAL2}/${package_name})
      mymessage(5 STATUS "Found the (directory) package ${GLOBAL2}/${package_name}") # found package_name
      mymessage(5 STATUS "Will now build the package ${package_name}!")
      build_package(${GLOBAL1}/${package_name} ${package_name})
    else()
      mymessage(1 FATAL "Did not find the package ${GLOBAL2}/${package_name} - This is a problem.")
    endif()
  endfunction()

## ----------------------------------------------------------------------------------------

  function(build_package path dirname)

    mymessage(5 STATUS "In function build_package - building ${path} ${dirname}")
    if ("${dirname}" STREQUAL "hdf5")
      build_hdf5()
    else()
      if ("${dirname}" STREQUAL "lapack")
        build_package1("lapack" "LAPACK" "now_really_build_lapack")
      elseif ("${dirname}" STREQUAL "plplot")			
        build_package1("plplot" "PLPLOT" "now_really_build_plplot")
      elseif ("${dirname}" STREQUAL "fftw")
        build_package1("fftw" "FFTW" "now_really_build_fftw")
      elseif ("${dirname}" STREQUAL "openmpi")			
        build_package1("openmpi" "OPENMPI" "now_really_build_openmpi")
      elseif ("${dirname}" STREQUAL "fgsl")
        if (EXISTS ${path}/${dirname})
	  file(REMOVE_RECURSE "${path}/${dirname}")
	endif()
        build_package1("fgsl" "FGSL" "now_really_build_fgsl")
      elseif ("${dirname}" STREQUAL "lapack95")
        # before we build it, we change out the CMakeLists.txt file
	# the one shipped with Bmad is not good for our purposes
        build_package1("lapack95" "LAPACK95" "now_really_build_lapack95")
      elseif ("${dirname}" STREQUAL "xraylib")
        build_package1("xraylib" "XRAYLIB" "now_really_build_xraylib")
      endif()
    endif()
  endfunction()

## ----------------------------------------------------------------------------------------
	
  function(build_hdf5)

  # this should be transitioned into the build_package1 routine
  # looks like the only holdout is the arguments used in the call to find_package

    set (func_name hdf5)
    set (func_name_cap HDF5)

    enable_language(Fortran)
    include(ExternalProject)

#    message (STATUS "IN SETTING OF HDF5_DESTDIR (function build_hdf5) - CMAKE_INSTALL_PREFIX IS ${CMAKE_INSTALL_PREFIX}")

    if(BUILD_${func_name_cap})
      mymessage(2 STATUS "User wants to build ${func_name_cap}")
      if (BUILD_ANYWAY)
      # user does not care if there is a version of HDF5 on the system
      # user desires to build a fresh copy
        mymessage(2 STATUS "User wants to build ${func_name_cap} even if already installed")
        now_really_build_hdf5()
      else()
	mymessage(5 STATUS "Checking to see if we should build ${func_name_cap} - will not build if it is already installed")

        # set hdf5_DESTDIR to have install directory by default
        set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

        if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
          set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
        endif()

        if (OWN_FIND_ALL_PACKAGE)
          file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
        endif()

        find_package(${func_name_cap} COMPONENTS Fortran QUIET)

        if (${func_name_cap}_FOUND)
  
          mymessage(3 STATUS "${func_name_cap}_Fortran was found - continuing - Scott had a test that I am not implementing right now - do we need it?")
        else()

          mymessage(1 STATUS "We do not have a valid version of the ${func_name} - Add the hdf5 target - 2")
          #maybe this is where we do the hdf5 build?
          now_really_build_hdf5()
        endif()
      endif()
    else()
      mymessage(3 STATUS "No need to build ${func_name_cap}")
    endif()

  endfunction()

## ----------------------------------------------------------------------------------------

#try to use cmake build, not configure
  function(now_really_build_hdf5)

    set (func_name hdf5)
    set (func_name_cap HDF5)

    mymessage(3 STATUS "Now in function now_really_build_${func_name}")

    setup_build_arguments(${func_name} ${func_name_cap})

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

    mymessage(3 STATUS "Value of ${func_name}_DESTDIR is ${${func_name}_DESTDIR}")

    if (OWN_FIND_ALL_PACKAGE)
      file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
    endif()

#I don't do anything for DIST_BUILD - and I don't handle shared/static - just shared

    ExternalProject_Add(${func_name}
	SOURCE_DIR
          "${GLOBAL1}/${func_name}"

	CMAKE_ARGS
	  -DCMAKE_INSTALL_PREFIX:PATH=${${func_name}_DESTDIR}
	  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
	  # need this otherwise end up with ${func_name} and blas in /lib64!
          -DBUILD_INDEX=OFF
          -DBUILD_INDEX64_EXT_API=OFF
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
#          ${${func_name}_OPENMP}
#	  -DBUILD_DEPRECATED=YES
#	  -DCBLAS=OFF
#	  -DLAPACKE=ON
#	  -DLAPACKE_WITH_TMG=ON
	  # jsl - this from david - but I am adding library name!
	  -DCMAKE_INSTALL_LIBDIR=${${func_name}_DESTDIR}/lib
          # Scott suggests these should go to the include directory
          # -DCMAKE_Fortran_MODULE_DIRECTORY=${${func_name}_DESTDIR}/lib/fortran/modules/${func_name}
          -DCMAKE_Fortran_MODULE_DIRECTORY=${${func_name}_DESTDIR}/include
          # CMAKE_CACHE_ARGS
	  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

          -DBUILD_STATIC_LIBS=OFF
	  -DUSE_RPATH=ON
          -Wno-dev
          -DHDF5_INSTALL_CMAKE_DIR=${${func_name}_DESTDIR}/lib
          -DHDF5_BUILD_HL_LIB=ON
          -DHDF5_BUILD_FORTRAN=ON
	  -DHDF5_BUILD_GENERATORS=OFF
	  -DHDF5_ENABLE_SZIP_SUPPORT=OFF


#	${CMAKE_BINARY} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
#          -DCMAKE_INSTALL_PREFIX=${OUTPUT_DIR} \
#	  -DBUILD_SHARED_LIBS=$SHARED \
#	  -DBUILD_STATIC_LIBS=$STATIC \
#	  -DUSE_RPATH=${ENABLE_RPATH} \
#          -Wno-dev \
#          -DHDF5_INSTALL_CMAKE_DIR=lib/cmake/hdf5 \
#          -DHDF5_BUILD_HL_LIB=ON \
#          -DHDF5_BUILD_FORTRAN=ON \
#	  -DHDF5_BUILD_GENERATORS=OFF \
#	  -DHDF5_ENABLE_SZIP_SUPPORT=OFF \
#	  ..


        BUILD_ALWAYS true
	BUILD_COMMAND make
	INSTALL_COMMAND make install
	)

    mymessage(3 STATUS "Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

    install(
        DIRECTORY
        COMPONENT ${func_name}
    	DESTINATION "${${func_name}_DESTDIR}"
    	USE_SOURCE_PERMISSIONS
    )

    mymessage(3 STATUS "Finished setting up the build needed for ${func_name}")

  endfunction()


#rename something we don't use - this was the original configure build of hdf5
  function(now_really_build_hdf51)

    set (func_name hdf5)
    set (func_name_cap HDF5)

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

#    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      mymessage(2 STATUS "Have reached here (${func_name}) first")
      mymessage(2 STATUS "Value of External bmad directory is ${ATEST1}")
      mymessage(2 STATUS "Value of External bmad directory is ${EXTERNAL_BMAD_SOURCE_DIRECTORY}")
      mymessage(2 STATUS "Value of GLOBAL1 is ${GLOBAL1}")
      mymessage(2 STATUS "Value of GLOBAL2 is ${GLOBAL2}")
      mymessage(2 STATUS "Value of cmake install prefix is ${CMAKE_INSTALL_PREFIX}")
#    endif()

    # set hdf5_DESTDIR to have install directory by default
    set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
      set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
    endif()

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      mymessage(3 STATUS "Getting ready to set ${func_name}_DESTDIR to ${${func_name}_DESTDIR}")
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

#    mymessage(2 STATUS "JSL2 - Before setting messages value of REQUIRE_OPENMP is ${REQUIRE_OPENMP} ")
    set (${func_name}_OPENMP "")
    setopenmp(${func_name_cap} ${func_name})

    if (OWN_FIND_ALL_PACKAGE)
      file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
    endif()

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
        ${${func_name}_OPENMP}

#Scott says don't specify where include files ago
#	"--includedir=${${func_name}_DESTDIR}/include/${func_name}"
# THIS did not work!! - directory doesn't exist - guessing I have to make it on my own if this is desired!
#	"--with-fmoddir=${${func_name}_DESTDIR}/lib/fortran/modules/${func_name}"

# THIS IS STILL CONFUSING - WHY IS BUILD_COMMAND OF JUST make - DOING A make install?
# I THINK I READ SOMEWHERE THAT ExternalProject_Add ALWAYS DOES A make install - DOES THIS MAKE SENSE?
        BUILD_ALWAYS true
	BUILD_COMMAND make
	INSTALL_COMMAND make install
    )

    mymessage(3 STATUS "Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

    install(
      DIRECTORY
      COMPONENT ${func_name}
      DESTINATION "${${func_name}_DESTDIR}"
      USE_SOURCE_PERMISSIONS
    )

#    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
#
#    message(STATUS "Copy - From - ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake to ${${func_name}_DESTDIR}")

    mymessage(2 STATUS "Finished setting up the build needed for ${func_name}")

  endfunction()

## ----------------------------------------------------------------------------------------

  function(build_package1 package_lc package_uc build_function)

    mymessage(2 STATUS "In function build_package1 - called with args ${package_lc}, ${package_uc}")
    set (func_name ${package_lc})
    set (func_name_cap ${package_uc})
    include(ExternalProject)

    if(BUILD_${func_name_cap})

      mymessage(3 STATUS "User wants to build ${func_name_cap}")

      if (BUILD_ANYWAY)

        mymessage(2 STATUS "User wants to build ${func_name_cap} even if already installed")
#       This calls the function 'build_function' that was passed into this function
	cmake_language(CALL ${build_function})
      else()
        mymessage(3 STATUS "(IN GENERIC BUILD_PACKAGE1) Checking to see if we should build ${func_name_cap} - will not build if it is already installed")
      # set ${func_name}_DESTDIR to have install directory by default
        set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

        if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
          set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
        endif()

      # copy the file used to find the package - Find...cmake for the package
        findFileCopy(${func_name} ${func_name_cap})

        mymessage(5 STATUS "GENERIC build_package1 - HERE IS WHERE WE DO THE FIND_PACKAGE CHECK")
        mymessage(3 STATUS "${func_name_cap} Our find will use HINTS - CMAKE_MODULE_PATH - WHICH IS ${CMAKE_MODULE_PATH}")
        
        # use QUIET so we don't get messages - good or bad - if package found or not
        find_package(${func_name_cap} QUIET)

        mymessage(3 STATUS "Value of {func_name_cap}_FOUND is ${func_name_cap}_FOUND is ${${func_name_cap}_FOUND}")
        if(${${func_name_cap}_FOUND})
          mymessage(3 STATUS "GENERIC - No need to build ${func_name_cap} - already found")
        else()
	  mymessage(2 STATUS "GENERIC - Could not find ${func_name_cap} - building ${func_name} now")
	  cmake_language(CALL ${build_function})
        endif()
      endif()
    else()
      mymessage(3 STATUS "No need to build ${func_name_cap}")
    endif()
  endfunction()

## ----------------------------------------------------------------------------------------

  function(setup_build_arguments packagename_lc packagename_uc)

    set (func_name ${packagename_lc})
    set (func_name_cap ${packagename_uc})

    mymessage(2 STATUS "Now setup build arguments for ${packagename_lc}")

    # set ${func_name}_DESTDIR to have install directory by default
    set(${packagename_lc}_DESTDIR ${CMAKE_INSTALL_PREFIX})
    set(${packagename_lc}_DESTDIR ${CMAKE_INSTALL_PREFIX} PARENT_SCOPE)

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
	set (${packagename_lc}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${packagename_lc})
	set (${packagename_lc}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${packagename_lc} PARENT_SCOPE)
    endif()

    mymessage(3 STATUS "Values - global1 ${GLOBAL1} global2 - Set ${packagename_lc}_DESTDIR - value has been set to - ${${packagename_lc}_DESTDIR}")

#    message(STATUS "JSL2 - Before setting messages value of REQUIRE_OPENMP is ${REQUIRE_OPENMP} ")
    set (${packagename_lc}_OPENMP "")
    set (${packagename_lc}_OPENMP "" PARENT_SCOPE)
  
    setopenmp(${packagename_uc} ${packagename_lc})
    setopenmp(${packagename_uc} ${packagename_lc} PARENT_SCOPE)

  endfunction()

## ----------------------------------------------------------------------------------------

  function(now_really_build_lapack)

    set (func_name lapack)
    set (func_name_cap LAPACK)

    mymessage(3 STATUS "Now in function now_really_build_${func_name}")

    setup_build_arguments(${func_name} ${func_name_cap})

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

    mymessage(3 STATUS "Value of ${func_name}_DESTDIR is ${${func_name}_DESTDIR}")

    if (OWN_FIND_ALL_PACKAGE)
      file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
    endif()

    ExternalProject_Add(${func_name}
	SOURCE_DIR
          "${GLOBAL1}/${func_name}"

	CMAKE_ARGS
	  -DCMAKE_INSTALL_PREFIX:PATH=${${func_name}_DESTDIR}
	  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
	  # need this otherwise end up with ${func_name} and blas in /lib64!
          -DBUILD_INDEX=OFF
          -DBUILD_INDEX64_EXT_API=OFF
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
          ${${func_name}_OPENMP}
	  -DBUILD_DEPRECATED=YES
	  -DCBLAS=OFF
	  -DLAPACKE=ON
	  -DLAPACKE_WITH_TMG=ON
	  # jsl - this from david - but I am adding library name!
	  -DCMAKE_INSTALL_LIBDIR=${${func_name}_DESTDIR}/lib
          # Scott suggests these should go to the include directory
          # -DCMAKE_Fortran_MODULE_DIRECTORY=${${func_name}_DESTDIR}/lib/fortran/modules/${func_name}
          -DCMAKE_Fortran_MODULE_DIRECTORY=${${func_name}_DESTDIR}/include
          # CMAKE_CACHE_ARGS
	  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

        BUILD_ALWAYS true
	BUILD_COMMAND make
	INSTALL_COMMAND make install
	)

    mymessage(3 STATUS "Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

    install(
        DIRECTORY
        COMPONENT ${func_name}
    	DESTINATION "${${func_name}_DESTDIR}"
    	USE_SOURCE_PERMISSIONS
    )

    mymessage(3 STATUS "Finished setting up the build needed for ${func_name}")

  endfunction()

## ----------------------------------------------------------------------------------------

  function(now_really_build_plplot)

    set (func_name plplot)
    set (func_name_cap PLPLOT)

    mymessage(3 STATUS "Now in function now_really_build_${func_name}")

    setup_build_arguments(${func_name} ${func_name_cap})

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

    mymessage(3 STATUS "Value of ${func_name}_DESTDIR is ${${func_name}_DESTDIR}")

    if (OWN_FINDPACKAGE)
      file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
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
        #Scott suggests these should go to the include directory
        # -DFORTRAN_MOD_DIR=${${func_name}_DESTDIR}/lib/fortran/modules
        -DFORTRAN_MOD_DIR=${${func_name}_DESTDIR}/include
        ${${func_name}_OPENMP}
        # CMAKE_CACHE_ARGS
        -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
        # CMAKE_ARGS
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

    mymessage(3 STATUS "Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

    install(
      DIRECTORY
      COMPONENT ${func_name}
      DESTINATION "${${func_name}_DESTDIR}"
      USE_SOURCE_PERMISSIONS
    )

    mymessage(3 STATUS "Finished setting up the build needed for ${func_name}")

  endfunction()

## ----------------------------------------------------------------------------------------

  function(now_really_build_fftw)

    set (func_name fftw)
    set (func_name_cap FFTW)

    mymessage(3 STATUS "Now in function now_really_build_${func_name}")

    set (${func_name}_OPENMP "")

    setup_build_arguments(${func_name} ${func_name_cap})

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

    mymessage(3 STATUS "Value of ${func_name}_DESTDIR is ${${func_name}_DESTDIR}")

    if (OWN_FINDPACKAGE)
      file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
    endif()

    set(${func_name}_build_type "")

    if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
      set(${func_name}_build_type "--enable-debug")
    endif()

#    message(STATUS "3. VALUE OF ${func_name}_OPENMP is ${${func_name}_OPENMP}")

    ExternalProject_Add(${func_name}

      SOURCE_DIR "${GLOBAL1}/${func_name}"

      CONFIGURE_COMMAND
        "${GLOBAL1}/${func_name}/configure"
        "--prefix=${${func_name}_DESTDIR}"
        # need this otherwise end up with lapack and blas ${func_name}3 in /lib64 and not a shared object!!
	"--enable-shared"
        #Scott says don't specify where include files ago
        # "--includedir=${${func_name}_DESTDIR}/include/${func_name}"
	"${${func_name}_build_type}"

      CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${${func_name}_DESTDIR}
        # -DCMAKE_INSTALL_INCLUDEDIR=${${func_name}_DESTDIR}/include/${func_name}
	-DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DENABLE_fortran:BOOL=ON
        ${${func_name}_OPENMP}
        # CMAKE_CACHE_ARGS
	-DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
	-DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
        #CMAKE_ARGS
	-DCMAKE_VERBOSE_MAKEFILE=true
    
      BUILD_ALWAYS true
      BUILD_COMMAND make
      INSTALL_COMMAND make install
    )

    mymessage(3 STATUS "Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

    install(
        DIRECTORY
        COMPONENT ${func_name}
    	DESTINATION "${${func_name}_DESTDIR}"
    	USE_SOURCE_PERMISSIONS
    )
    mymessage(3 STATUS "Finished setting up the build needed for ${func_name}")

  endfunction()

## ----------------------------------------------------------------------------------------

  function(now_really_build_openmpi)

    set(func_name "openmpi")
    set(func_name "OPENMPI")

    message(STATUS "Now really building ${func_name}")

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

    set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
      set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
    endif()

    if (OWN_FINDPACKAGE)
      file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name}.cmake  DESTINATION ${${func_name}_DESTDIR})
    endif()

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      mymessage (3 STATUS "Set ${func_name}_DESTDIR - value has been set to - ${${func_name}_DESTDIR}")
    endif()

    mymessage(2 STATUS "autoreconf dir is ${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
    set(${func_name}_autoreconfdir "${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")

    if(EXISTS ${GLOBAL1}/${func_name}/configure.ac)
      mymessage (5 STATUS "Directory ${GLOBAL1}/${func_name} does exist!")
    else()
      mymessage (5 STATUS "Directory ${GLOBAL1}/${func_name} does not exist")
    endif()

    execute_process(
      WORKING_DIRECTORY "${GLOBAL1}/${func_name}"
      COMMAND "autogen.pl"
      "--force"
      RESULT_VARIABLE status
    )

    execute_process(
      WORKING_DIRECTORY "${GLOBAL1}/${func_name}"
      COMMAND "autoreconf"
      "--install"
      RESULT_VARIABLE status
    )

    message(STATUS "finished with autoreconf dir in ${GLOBAL1}/${func_name} - status is ${status}")

    set (${func_name}_build_type "")
    if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
      set(${func_name}_build_type "--enable-debug")
    endif()

#    mymessage(1 STATUS "JSL2 - Before setting messages value of REQUIRE_OPENMP is ${REQUIRE_OPENMP} ")
    set (${func_name}_OPENMP "")
    setopenmp(${func_name_cap} ${func_name})

    ExternalProject_Add(${func_name}

      SOURCE_DIR "${GLOBAL1}/${func_name}"
      CONFIGURE_COMMAND
        "${GLOBAL1}/${func_name}/configure"
        "--prefix=${${func_name}_DESTDIR}"
        "--enable-shared=${BUILD_SHARED_LIBS}"
        "${${func_name}_build_type}"
        ${${func_name}_OPENMP}

      CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${${func_name}_DESTDIR}
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DENABLE_fortran:BOOL=ON
        # CMAKE_CACHE_ARGS
        -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
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

    message(STATUS "Finished setting up the build needed for ${func_name}")

  endfunction()

## ----------------------------------------------------------------------------------------

  function(now_really_build_fgsl)

    set(pre_func_name "gsl")
    set(pre_func_name_cap "GSL")
    set(func_name "fgsl")
    set(func_name_cap "FGSL")

    mymessage(3 STATUS "Now in function now_really_build_${func_name}")

    setup_build_arguments(${func_name} ${func_name_cap})

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

    mymessage(3 STATUS "Value of ${func_name}_DESTDIR is ${${func_name}_DESTDIR}")

    set(${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})
    set(${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX} PARENT_SCOPE)
    set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})
    set(${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX} PARENT_SCOPE)

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
      set (${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/gsl)
      set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name})
      set (${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/gsl PARENT_SCOPE)
      set (${func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${func_name} PARENT_SCOPE)
    endif()

    mymessage(3 STATUS "Set ${pre_func_name}_DESTDIR - value has been set to - ${${pre_func_name}_DESTDIR}")
    mymessage(3 STATUS "Set ${func_name}_DESTDIR - value has been set to - ${${func_name}_DESTDIR}")

    set(NEED_TO_BUILD_GSL 0)
    #  set ${func_name}_DESTDIR to have install directory by default
    set(${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX})
    set(${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX} PARENT_SCOPE)

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
      set (${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${pre_func_name})
      set (${pre_func_name}_DESTDIR ${CMAKE_INSTALL_PREFIX}/${pre_func_name} PARENT_SCOPE)
    endif()

    if (OWN_FIND_ALL_PACKAGE)
      file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${pre_func_name_cap}.cmake  DESTINATION ${${pre_func_name}_DESTDIR})
    endif()

    find_package(${pre_func_name_cap} QUIET)
#    mymessage(4 STATUS "JUST A TEST! - ${pre_func_name_cap} - HINTS - To LOOK IN ${CMAKE_MODULE_PATH} ${CMAKE_PREFIX_PATH}")
    if(${pre_func_name_cap}_VERSION)

      set(STR1 ${${pre_func_name_cap}_VERSION})
      set(STR2 "2.6")

      if("${STR1}" VERSION_LESS "${STR2}")

        mymessage(5 STATUS "Installed version is less than 2.6 - build GSL")
        set(NEED_TO_BUILD_${pre_func_name_cap} 1)
 
      else()

        mymessage(2 STATUS "Installed version is equal to or greater than 2.6 - no need to build ${pre_func_name}")
        if (${CMAKE_INSTALL_ANYWAY})
          mymessage(2 STATUS "Installing ${pre_func_name} anyway - that is, we found the right version, but laying down code to build anyway")
  	  set(NEED_TO_BUILD_${pre_func_name_cap} 1)
        endif()	
      endif()
    else()

      mymessage(3 STATUS "No ${pre_func_name} version found - probably not installed - build ${pre_func_name}")
      set(NEED_TO_BUILD_${pre_func_name_cap} 1)

    endif()

    if (${NEED_TO_BUILD_${pre_func_name_cap}} EQUAL 1)

      set(${pre_func_name}_build_type "")

      if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
        set(${pre_func_name}_build_type "CFLAGS=-g -O0")
#      set(gsl_build_type "-d")
      endif()

      set (${pre_func_name}_OPENMP "")
      setopenmp(${pre_func_name_cap} ${pre_func_name})

      ExternalProject_Add(${pre_func_name}

        SOURCE_DIR "${GLOBAL1}/${pre_func_name}"

        CONFIGURE_COMMAND

          "${GLOBAL1}/${pre_func_name}/configure"
	  "--prefix=${${pre_func_name}_DESTDIR}"
          "--enable-shared"
          "--disable-static"
  	  "--disable-tests"
	  "${${pre_func_name}_build_type}"
          "${${pre_func_name}_OPENMP}"

        CMAKE_ARGS
	  -DCMAKE_INSTALL_PREFIX:PATH=${${pre_func_name}_DESTDIR}
          -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
	  # CMAKE_CACHE_ARGS
	  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
          -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

        BUILD_ALWAYS true
        BUILD_COMMAND make
        INSTALL_COMMAND make install
      )

      mymessage(3 STATUS "Set ${pre_func_name}_DESTDIR - value After ExternalProject_Add is now - ${${pre_func_name}_DESTDIR}")

      install(
        DIRECTORY
        COMPONENT ${pre_func_name}
        DESTINATION "${${pre_func_name}_DESTDIR}"
        USE_SOURCE_PERMISSIONS
      )

  
      add_custom_command(TARGET ${pre_func_name} POST_BUILD
      COMMENT "Copying ${pre_func_name} include files now after the build is complete"
      COMMAND ${CMAKE_COMMAND} -E copy
      "${CMAKE_INSTALL_PREFIX}/include/${pre_func_name}/*"
      "${CMAKE_INSTALL_PREFIX}/include"
      #      COMMENT "MyComment"
      )

      mymessage(3 STATUS "Finished the NEED TO BUILD section for ${pre_func_name}")

    else()

      add_custom_target(${pre_func_name} "true")
      mymessage(4 STATUS "No reason to build ${pre_func_name}")

    endif()

    mymessage(3 STATUS "Finished setting up the build needed for ${pre_func_name}")

    if(EXISTS ENV{PKG_CONFIG_PATH})
      mymessage(3 STATUS "pkg_config_path does exist")
      set(${func_name}_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/${pre_func_name}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
    else()
      mymessage(3 STATUS "pkg_config_path does not exist")
      set(${func_name}_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/${pre_func_name}/lib/pkgconfig")
    endif()

    mymessage(2 STATUS "Starting setup of ${func_name}")

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
#    set(${func_name}_pc_flags "PKG_CONFIG_PATH=/nfs/acc/libs/Linux_x86_64_intel/packages_2025_0208_d/production/lib")

    mymessage(4 STATUS "Defining ExternalProject_Add for ${func_name}")

#    mymessage(4 STATUS "set ${func_name}_srcdir to ${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")

#    set(${func_name}_srcdir "${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
	
    mymessage(4 STATUS "Execute process autoreconf now!")

    mymessage(2 STATUS "autoreconf dir is ${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
    set(${func_name}_autoreconfdir "${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")

    if(EXISTS ${GLOBAL1}/${func_name}/configure.ac)
      mymessage(5 STATUS "Directory ${GLOBAL1}/${func_name} does exist!")
    else()
      mymessage(4 STATUS "Directory ${GLOBAL1}/${func_name} does not exist")
    endif()
    
  # NOTE - JSL - I do not know how to set this to build into the build directory - modifies - that is, puts files into - the external package area.

    execute_process(
      WORKING_DIRECTORY "${GLOBAL1}/${func_name}"
      COMMAND "autoreconf" "--install"
      RESULT_VARIABLE status
    )

    mymessage(3 STATUS "finished with autoreconf dir in ${GLOBAL1}/${func_name} - status is ${status}")

    mymessage(3 STATUS "PKG_CONFIG_PATH: $ENV{PKG_CONFIG_PATH} ${${func_name}_pc_flags}") 

    set(${func_name}_build_type "")

    if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
        set(${func_name}_build_type "CFLAGS=-g -O0")
  #    set(fgsl_build_type "--debug")
    endif()

    set (${func_name}_OPENMP "")
    setopenmp(${func_name_cap} ${func_name})

#    set(gsl_LIBS "/nfs/acc/libs/Linux_x86_64_intel/packages_2025_0208_d/production/lib")
##   set(ENV{gsl_LIBS} "/nfs/acc/libs/Linux_x86_64_intel/packages_2025_0208_d/production")
#    set(gsl_CFLAGS "-I/nfs/acc/libs/Linux_x86_64_intel/packages_2025_0208_d/production/include")

    
    ExternalProject_Add(${func_name}
      SOURCE_DIR "${GLOBAL1}/${func_name}"
      CONFIGURE_COMMAND
        "${GLOBAL1}/${func_name}/configure"
	"--prefix=${${func_name}_DESTDIR}"
	#	"--prefix=/nfs/acc/libs/Linux_x86_64_intel/packages_2025_0208_d/production"
	"gsl_LIBS=${gsl_LIBS}"
	"gsl_CFLAGS=${gsl_CFLAGS}"
        "--disable-static"
        "${${func_name}_fcflags}"
        "${${func_name}_pc_flags}"
        "${${func_name}_build_type}"
        "${${func_name}_OPENMP}"

      CMAKE_ARGS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        #    CMAKE_CACHE_ARGS
        -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

      BUILD_ALWAYS true
      BUILD_COMMAND make -j 1
      INSTALL_COMMAND make install
    )

    mymessage(3 STATUS "Value of the environment variable gsl_libs is $ENV{gsl_LIBS} - $ENV{gsl_CFLAGS}")

    mymessage(3 STATUS "Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

    if (${NEED_TO_BUILD_GSL} EQUAL 1)
      mymessage(3 STATUS "If we had to build our own ${pre_func_name} - Set up dependency for ${func_name} - it depends on ${pre_func_name}!")
      add_dependencies(${func_name} ${pre_func_name})
    endif()

    install(
      DIRECTORY
      COMPONENT ${func_name}
      DESTINATION "${${func_name}_DESTDIR}"
      USE_SOURCE_PERMISSIONS
    )
  
    add_custom_command(TARGET ${func_name} POST_BUILD
      COMMENT "Copying ${func_name} include files now after the build is complete"
      COMMAND ${CMAKE_COMMAND} -E copy
      "${CMAKE_INSTALL_PREFIX}/include/${func_name}/*"
      "${CMAKE_INSTALL_PREFIX}/include"
    )
    mymessage(3 STATUS "Finished setting up the build needed for ${func_name}")
  endfunction()

## ----------------------------------------------------------------------------------------

  function(findFileCopy func_name func_name_cap)
    if(${func_name} STREQUAL "lapack")
      mymessage(2 STATUS "Doing copy of Find...cmake file for lapack")
      if (OWN_FIND_ALL_PACKAGE)
        file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
      endif()
    elseif (${func_name} STREQUAL "plplot")
      mymessage(2 STATUS "Doing copy of Find...cmake file for plplot")
      if (OWN_FINDPACKAGE)
        file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
      endif()
    elseif (${func_name} STREQUAL "fftw")
      mymessage(2 STATUS "Doing copy of Find...cmake file for fftw")
      if (OWN_FINDPACKAGE)
        file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
      endif()
    elseif (${func_name} STREQUAL "fgsl")
      mymessage(2 STATUS "Doing copy of Find...cmake file for fgsl")
  #   I don't believe this is necessary
  #    if (OWN_FINDPACKAGE)
  #      file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/FindGSL.cmake  DESTINATION ${gsl_DESTDIR})
  #   endif()
      if (OWN_FINDPACKAGE)
        file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake  DESTINATION ${${func_name}_DESTDIR})
      endif()
    elseif (${func_name} STREQUAL "lapack95")
      mymessage(2 STATUS "Doing copy of Find...cmake file for lapack95")
      if (OWN_FINDPACKAGE)
        file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
      endif()
    elseif (${func_name} STREQUAL "xraylib")
      mymessage(2 STATUS "Doing copy of Find...cmake file for xraylib")
      if (OWN_FINDPACKAGE)
        file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake  DESTINATION ${${func_name}_DESTDIR})
     endif()
    elseif (${func_name} STREQUAL "openmpi")
      mymessage(2 STATUS "Doing copy of Find...cmake file for openmpi")
      if (OWN_FINDPACKAGE)
        file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake  DESTINATION ${${func_name}_DESTDIR})
     endif()
    elseif (${func_name} STREQUAL "hdf5")
      mymessage(2 STATUS "Doing copy of Find...cmake file for hdf5")
      if (OWN_FIND_ALL_PACKAGE)
        file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
      endif()
    endif()
  endfunction()

  ## ----------------------------------------------------------------------------------------
  
  function(now_really_build_lapack95)
  
    set(func_name "lapack95")
    set(func_name_cap "LAPACK95")

    mymessage(3 STATUS "Now in function now_really_build_${func_name}")
  
    setup_build_arguments(${func_name} ${func_name_cap})
  
    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)
  
    mymessage(1 STATUS "For ${func_name} - will place  ${CMAKE_ROLLOUT_CMAKE_FILES}/${func_name_cap}_CMakeLists.txt file into ... ${GLOBAL1}/${func_name} and then rename it to ${GLOBAL1}/${func_name_cap}_CMakeLists.txt")
  
    mymessage(1 STATUS "Values: rename -  ${CMAKE_ROLLOUT_CMAKE_FILES}/${func_name_cap}_CMakeLists.txt   -  ${GLOBAL1}/${func_name}/CMakeLists.txt")

    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/${func_name_cap}_CMakeLists.txt DESTINATION ${GLOBAL1}/${func_name})
    file(RENAME ${GLOBAL1}/${func_name}/${func_name_cap}_CMakeLists.txt ${GLOBAL1}/${func_name}/CMakeLists.txt)
  
    if (OWN_FINDPACKAGE)
      file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake DESTINATION ${${func_name}_DESTDIR})
    endif()
  
    #  find_package(LAPACK HINTS ${CMAKE_PREFIX_PATH})
    find_package(LAPACK QUIET)
    if (NOT LAPACK_FOUND)
      mymessage(2 STATUS "BUILDING ${func_name} - LAPACK library not found")
    else()
      mymessage(2 STATUS "BUILDING ${func_name} - FOUND LAPACK library")
    endif()
      
#    set (${func_name}_OPENMP "")
#    setopenmp(${func_name_cap} ${func_name})
  
    ExternalProject_Add(${func_name}
      SOURCE_DIR "${GLOBAL1}/${func_name}"
  
      CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${${func_name}_DESTDIR}
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_Fortran_COMPILER:STRING=gfortran
        -DACC_CMAKE_VERSION=3.13.4
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        ${${func_name}_OPENMP}
        # CMAKE_CACHE_ARGS
        -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
  
      BUILD_ALWAYS true
      BUILD_COMMAND make
      INSTALL_COMMAND make install
    )

    mymessage(3 STATUS "Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")
	
    install(
      DIRECTORY
      COMPONENT ${func_name}
      DESTINATION "${${func_name}_DESTDIR}"
      USE_SOURCE_PERMISSIONS
    )
  
    mymessage(3 STATUS "Finished setting up the build needed for ${func_name}")
  
  endfunction()

  ## ----------------------------------------------------------------------------------------
  
  function(now_really_build_xraylib)
  
    set(func_name "xraylib")
    set(func_name_cap "XRAYLIB")

    mymessage(3 STATUS "Now in function now_really_build_${func_name}")
  
    setup_build_arguments(${func_name} ${func_name_cap})
 
    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)  
 
    if (OWN_FINDPACKAGE)
      file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Find${func_name_cap}.cmake  DESTINATION ${${func_name}_DESTDIR})
    endif()
  
#    message(STATUS "set ${func_name}_srcdir to ${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix - value of ${func_name}_destdir is ${${func_name}_DESTDIR}")
  
#    set(${func_name}_srcdir "${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
  	
  #  message(STATUS "Execute process autoreconf now!")
  
  #  message(STATUS " Another test")
  
    mymessage(2 STATUS "autoreconf dir is ${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
    set(${func_name}_autoreconfdir "${CMAKE_CURRENT_BINARY_DIR}/${func_name}-prefix")
  
    if(EXISTS ${GLOBAL1}/${func_name}/configure.ac)
      mymessage(4 STATUS "Directory ${GLOBAL1}/${func_name} does exist!")
    else()
      mymessage(1 STATUS "Directory ${GLOBAL1}/${func_name} does not exist")
    endif()
  
    execute_process(
      WORKING_DIRECTORY "${GLOBAL1}/${func_name}"
      COMMAND "autoreconf" "--install"
      RESULT_VARIABLE status
    )
  
  #  message (STATUS "Result of autoreconf is ${status}")
  
    mymessage(3 STATUS "finished with autoreconf dir in ${GLOBAL1}/${func_name} - status is ${status}")
  
    set (${func_name}_build_type "")
    if(${CMAKE_BUILD_TYPE} STREQUAL "Debug")
      set(${func_name}_build_type "--enable-debug")
    endif()
  
#    message(STATUS "JSL2 - Before setting messages value of REQUIRE_OPENMP is ${REQUIRE_OPENMP} ")

#    set (${func_name}_OPENMP "")
#    setopenmp(${func_name_cap} ${func_name})
  
    ExternalProject_Add(${func_name}
  
      SOURCE_DIR "${GLOBAL1}/${func_name}"
  
      CONFIGURE_COMMAND
        "${GLOBAL1}/${func_name}/configure"
        "--prefix=${${func_name}_DESTDIR}"
  #      "--includedir=${CMAKE_INSTALL_PREFIX}/jsl1"
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
        "${${func_name}_OPENMP}"
  
      CMAKE_ARGS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        # CMAKE_CACHE_ARGS
        -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
  
      BUILD_ALWAYS true
      BUILD_COMMAND make
      INSTALL_COMMAND make install
    )

    mymessage (3 STATUS "Set ${func_name}_DESTDIR - value After ExternalProject_Add is now - ${${func_name}_DESTDIR}")

    # do I need to delete the original files in the ${func_name} directory? - for now, leaving them!
    add_custom_command(TARGET ${func_name} POST_BUILD
  #     message(STATUS "Copying xraylib include files now after the build is complete")
      COMMENT "Copying ${func_name} include files now after the build is complete"
  #      COMMAND echo hello
      COMMAND ${CMAKE_COMMAND} -E copy
      "${CMAKE_INSTALL_PREFIX}/include/${func_name}/*"
      "${CMAKE_INSTALL_PREFIX}/include"
  #      COMMENT "MyComment"
    )

    mymessage(3 STATUS "Finished setting up the build needed for ${func_name}")

  endfunction()

  ## ----------------------------------------------------------------------------------------
  
  function(should_build_package package should_build)
  
    mymessage(2 STATUS "Checking build for package ${package}")
    mymessage(2 STATUS "status of build_all is ${BUILD_ALL}")
  #	set (fgsl "FGSL")
    set (package_name_to_use "not set")
    package_map(${package} package_name_to_use)
#    message(STATUS "3. VALUE OF package_name_to_use after calling package_map is now ${package_name_to_use}")
    mymessage(3 STATUS "VALUE OF BUILD_${package_name_to_use} is ${BUILD_${package_name_to_use}}")
    message(3 STATUS "VALUE OF BUILD_ALL is ${BUILD_ALL}")
  
    if (${BUILD_ALL} STREQUAL "ON")
      mymessage(2 STATUS "Build all is ON!")
      set(${should_build} "YES" PARENT_SCOPE)
  		
   else()
      mymessage(1 STATUS - "BUILD_ALL IS NOT ON - package value is ${BUILD_${package_name_to_use}}")
      if (${BUILD_${package_name_to_use}} STREQUAL "ON")
        mymessage(1 STATUS "Build for BUILD_${package_name_to_use} is ON!")
        set(${should_build} "YES" PARENT_SCOPE)
  #			set(${BUILD_AT_LEAST_ONE} 1 PARENT_SCOPE)
        mymessage(2 STATUS "Setting value of BUILD_AT_LEAST_ONE to be 1!")
        set_property(GLOBAL PROPERTY BUILD_AT_LEAST_ONE 1)
      else()		
        set(${should_build} "NO" PARENT_SCOPE)
      endif()
    endif()
  #	message(STATUS "Value of should_build in GlobalVariables.cmake file should_build function is ${should_build}")
  endfunction()

  ## ----------------------------------------------------------------------------------------
  
  function(package_map package mapped_name)
  
    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      mymessage (5 STATUS "In a function called package_map")
    endif()
  
    set (local_mapped_name "NOT SET")
  
    if (${package} STREQUAL "fgsl")
      set(${mapped_name} "FGSL" PARENT_SCOPE)
      set (local_mapped_name "FGSL")
    elseif(${package} STREQUAL "h5cc")
      set(${mapped_name} "HDF5" PARENT_SCOPE)
      set (local_mapped_name "HDF5")
    elseif(${package} STREQUAL "lapack")
      set(${mapped_name} "LAPACK" PARENT_SCOPE)
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
      set(${mapped_name} "MPI" PARENT_SCOPE)
      set (local_mapped_name "MPI")
    elseif(${package} STREQUAL "xraylib")
      set(${mapped_name} "XRAYLIB" PARENT_SCOPE)
      set (local_mapped_name "XRAYLIB")
    else()
      message(FATAL_ERROR "(package_map) Package name mapping not found - aborting - ${package}")
    endif()
    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      mymessage(3 STATUS "(package_map) Value of package - mapped name is ${package} - ${local_mapped_name}")
    endif()
  endfunction()

  ## ----------------------------------------------------------------------------------------
  
  function(set_build_flags)
  # this function makes a determination if individual packages will be built, or if all packages will be built
  # any package to be built will have its BUILD_PACKAGE_NAME variable set to ON after this function is called
  
    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
      mymessage(5 STATUS "In set_build_flags function()")
    endif()
  
    setup_openmp()
  
    # now that we have a global value for REQUIRE_OPENMP, we need to set it globally for outer (PARENT_SCOPE) scope
    set(TMP_OPENMP ${REQUIRE_OPENMP})
    set(REQUIRE_OPENMP ${TMP_OPENMP} PARENT_SCOPE)
  
    if (BUILD_ALL OR (NOT (BUILD_HDF5 OR BUILD_LAPACK OR BUILD_PLPLOT OR BUILD_FFTW OR BUILD_FGSL OR BUILD_LAPACK95 OR BUILD_XRAYLIB)))
      if (BUILD_ALL)
  #      if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
        mymessage(3 STATUS "BUILD_ALL is true, setting BUILD ON for all packages")
  #      endif()
      else()
  #if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
        mymessage(4 STATUS "BUILD_ALL was not set, but no packages were set to build - user must want to build all packages")
  #endif()
      endif()
      set(BUILD_ALL ON PARENT_SCOPE)
      set(BUILD_HDF5 ON PARENT_SCOPE)
      set(BUILD_LAPACK ON)
      set(BUILD_LAPACK ON PARENT_SCOPE)
      set(BUILD_PLPLOT ON PARENT_SCOPE)
      set(BUILD_FFTW ON PARENT_SCOPE)
      set(BUILD_FGSL ON PARENT_SCOPE)
      set(BUILD_LAPACK95 ON PARENT_SCOPE)
      set(BUILD_XRAYLIB ON PARENT_SCOPE)
  # in the all build case, we do not build OPENMPI - must be a user specific request of OPENMPI
  #    set(BUILD_OPENMPI ON PARENT_SCOPE)
    endif()
#   Need one more check here - in case BUILD_LAPACK was not yet included
#   For now, due to a bug in RH9, if we are building on the redhat platform - OS9, we include a build of LAPACK
#   whether the user asks for it or not.

#    mymessage(2 STATUS "Value of BUILD_LAPACK IS ${BUILD_LAPACK}")

    if ( NOT ${BUILD_LAPACK})
      test_lapack_build_if_rh9()
    else()
      mymessage(2 STATUS "Building everything, not testing LAPACK")
    endif()

    mymessage(2 STATUS "Package(s) to be built:")
    foreach (PACKAGE HDF5 LAPACK PLPLOT FFTW FGSL LAPACK95 XRAYLIB) 
      if ( BUILD_${PACKAGE} )
        mymessage(2 STATUS "\tBuilding package ${PACKAGE}")
        requires_openmp(${PACKAGE})
      endif()
    endforeach()
  #  message(STATUS "Value of Check for fftw_devel is ${CHECK_FFTW_DEVEL} - and REQUIRE_OPENMP is ${REQUIRE_OPENMP}")
  #  set(REQUIRE_OPENMP ${REQUIRE_OPENMP} PARENT_SCOPE})
  endfunction()
  
  ## ----------------------------------------------------------------------------------------

  function(test_lapack_build_if_rh9)

  if (${BUILD_LAPACK})
    mymessage(2 STATUS "Building lapack already, no reason to test anything else")

  else()
    mymessage(2 STATUS "Not building lapack yet, let's check if we need to force the build")

    if (EXISTS "${RH9_RELEASE_FILE}")
      mymessage(5 STATUS "${RH9_RELEASE_FILE} exists")

      # now check to see if it is RH9
#      file(STRINGS "${RH9_RELEASE_FILE}" file_lines)
      set(MATCHED_OS FALSE)
      set(MATCHED_VERSION FALSE)
#      foreach(line IN LISTS file_lines)
#        if(line MATCHES "ID_LIKE")
#          if(line MATCHES "rhel")
#            message("Found a line matching the pattern 'ID_LIKE and rhel': ${line}")
#	    set(MATCHED_OS TRUE)
#          endif()
#        elseif(line MATCHES "VERSION_ID")
	  
	
#          message("Found a line matching the pattern 'VERSION_ID': ${line}")
               
#        endif()
#      endforeach()
      # this from google AI _ amazing!

      file(STRINGS "${RH9_RELEASE_FILE}" os_release_content)
      foreach(line ${os_release_content})
        string(REGEX REPLACE "^[ ]+" "" line "${line}")
        string(REGEX MATCH "^[^=]+" key "${line}")
        string(REPLACE "${key}=" "" value "${line}")
        set(${key} "${value}")
      endforeach()
      # Print the extracted values
      if (DEFINED ID_LIKE AND DEFINED VERSION_ID)
	mymessage(4 STATUS "OS ID_LIKE: ${ID_LIKE}")
        mymessage(4 STATUS "OS Version ID: ${VERSION_ID}")

        if(${ID_LIKE} MATCHES "rhel")
#         message("Found that ID_LIKE contains rhel")
          set(MATCHED_OS TRUE)
        endif()
        set(MIN_VERSION_BAD "9.0")
        set(MAX_VERSION_GOOD "10.0")
        message(4 STATUS "${VERSION_ID} >= ${MIN_VERSION_BAD}")
	

        # this logic is not intuitive - it seems that the signs for each test are "reversed"
        # but it works on my testing this way - don't understand
        if("${MIN_VERSION_BAD}" VERSION_GREATER "${VERSION_ID}" AND "${VERSION_ID}" VERSION_LESS_EQUAL "${MAX_VERSION_GOOD}")
          set(MATCHED_VERSION TRUE)
	  mymessage(5 STATUS "THIS IS A BAD VERSION - ${MIN_VERSION_BAD} -  ${VERSION_ID} - ${MAX_VERSION_GOOD}")
        endif()
      endif()
      
      if (${MATCHED_OS} AND ${MATCHED_VERSION})
        mymessage(1 STATUS "Our check of the os_release file matched our buggy RH9 version - need to build LAPACK")
        set(BUILD_LAPACK ON PARENT_SCOPE)
        set(BUILD_LAPACK ON)
      else()
 	mymessage(4 STATUS "Value of MATCHED_OS for building lapack is ${MATCHED_OS}")
 	mymessage(4 STATUS "Value of MATCHED_VERSION for building lapack is ${MATCHED_VERSION}")
        mymessage(1 STATUS "Initial testing - did not match the OS and/or version - not forcing build of LAPACK")
      endif()
    else()
      # it does not exist - we are in the clear - do not have to force the build
    endif()

  endif()

  endfunction()
  
  ## ----------------------------------------------------------------------------------------
  
  function(setup_openmp)
    if (${BUILD_OPENMP})
      mymessage(2 STATUS "User has requested to build with openmp")
  
      find_package(OpenMP QUIET)
      if (OpenMP_FOUND)
        mymessage(3 STATUS "User has requested to build with openmp - openmp found - value is ${OpenMP_FOUND}")
        set(HAVE_OPENMP True)
        set(HAVE_OPENMP True PARENT_SCOPE)
        set(REQUIRE_OPENMP True)
        set(REQUIRE_OPENMP True PARENT_SCOPE)
      else()
        mymessage(3 STATUS "User has requested to build with openmp - but openmp was not found")
      endif()
    else()
      mymessage(3 STATUS "No need to build with openmp - either passive - not set - or explicit - set to not build")
    endif()
  endfunction()
  
  ## ----------------------------------------------------------------------------------------
  
  function (requires_openmp package_name)
  
    mymessage(3 STATUS "Checking for mp requirement for ${package_name} - REQUIRE_OPENMP is now ${REQUIRE_OPENMP}")
  
    if (NOT ${REQUIRE_OPENMP} STREQUAL "True")
      #do nothing
    else()
      set (NEED_OPENMP False)
      if (${package_name} STREQUAL "junk")
        message(STATUS "Testing mp for junk")
  # not quite sure if need to handle openmpi case
  #   elseif (${package_name} STREQUAL "OPENMPI")
  #      message(STATUS "Testing mp for junk")
      elseif(${package_name} STREQUAL "FFTW")
        set(NEED_OPENMP True)
      elseif(${package_name} STREQUAL "FGSL")
        set(NEED_OPENMP True)
      elseif(${package_name} STREQUAL "HDF5")
        set(NEED_OPENMP True)
      elseif(${package_name} STREQUAL "GSL")
        set(NEED_OPENMP True)
      elseif(${package_name} STREQUAL "LAPACK")
        set(NEED_OPENMP True)
      elseif(${package_name} STREQUAL "XRAYLIB")
        set(NEED_OPENMP True)
      elseif(${package_name} STREQUAL "LAPACK")
        set(NEED_OPENMP True)
      else()
        message(STATUS "During check for mp - never processed this package - No indication that ${package_name} requires openmp")
      endif()
  
      if (${NEED_OPENMP} STREQUAL True AND NOT ${HAVE_OPENMP} STREQUAL True)
        message(STATUS "ABORTING CMAKE SETUP - USER REQUESTED TO BUILD WITH OPENMP")
        message(STATUS "Package ${package_name} REQUIRES OPENMP - BUT - OPENMP WAS NOT FOUND ON THIS SYSTEM")
        message(FATAL_ERROR "PLEASE CONTACT YOUR SYSTEM ADMINISTRATOR TO RESOLVE OPENMP ISSUE")
      endif()
    endif()
  
  endfunction()

  ## ----------------------------------------------------------------------------------------
  
  function (setopenmp package_name func_name)
  
    mymessage(3 STATUS "setting up openmp value for ${func_name}_OPENMP")
  
  # initialize to blank value
    set(${func_name}_OPENMP "" PARENT_SCOPE)
    set(strValue "")
  
    if (${package_name} STREQUAL "junk")
  
      message(STATUS "Testing openmp for junk - how did this happen")
      set(${func_name}_OPENMP ${strValue} PARENT_SCOPE)
  
  ## not quite sure if need to handle openmpi case
  ##   elseif (${package_name} STREQUAL "OPENMPI")
  ##      message(STATUS "Testing mp for junk")
  
    elseif(${package_name} STREQUAL "FFTW")
  
      set(strValue "-DENABLE_OPENMP=${REQUIRE_OPENMP}")
  #      message(STATUS "JSL - Value is ${strValue}")
      set(${func_name}_OPENMP ${strValue} PARENT_SCOPE)
  
    elseif(${package_name} STREQUAL "FGSL")
      set(strValue "--disable-openmp")
      set(${func_name}_OPENMP ${strValue} PARENT_SCOPE)
  
    elseif(${package_name} STREQUAL "HDF5")
      mymessage(3 STATUS "Not sure what OPENMP options exist for HDF5!")
  #      set(strValue "-DENABLE_OPENMP=${REQUIRE_OPENMP}")
  #      set(${func_name}_OPENMP ${strValue} PARENT_SCOPE)
  
    elseif(${package_name} STREQUAL "GSL")
      mymessage(3 STATUS "Not sure what OPENMP options exist for GSL!")
  #      set(strValue "-DENABLE_OPENMP=${REQUIRE_OPENMP}")
  #      set(${func_name}_OPENMP ${strValue} PARENT_SCOPE)
  
    elseif(${package_name} STREQUAL "LAPACK")
  # not sure if this is right - maybe should set FFLAGS to be -fopenmp?
      set(strValue "-D_OPENMP=${REQUIRE_OPENMP}")
      set(${func_name}_OPENMP ${strValue} PARENT_SCOPE)
  
    elseif(${package_name} STREQUAL "XRAYLIB")
      if (${REQUIRE_OPENMP} STREQUAL False)
        set(strValue "")
      else()
        set(strValue "")
      endif()
      set(${func_name}_OPENMP ${strValue} PARENT_SCOPE)
  
    elseif(${package_name} STREQUAL "LAPACK")
      set(strValue "-DENABLE_OPENMP=${REQUIRE_OPENMP}")
      set(${func_name}_OPENMP ${strValue} PARENT_SCOPE)
  
    elseif(${package_name} STREQUAL "PLPLOT")
#      set(strValue "-DENABLE_OPENMP=${REQUIRE_OPENMP}")
#      set(${func_name}_OPENMP ${strValue} PARENT_SCOPE)
  
    elseif(${package_name} STREQUAL "LAPACK95")
#      set(strValue "-DENABLE_OPENMP=${REQUIRE_OPENMP}")
#      set(${func_name}_OPENMP ${strValue} PARENT_SCOPE)
  
    else()
      mymessage(1 STATUS "No value set for handling ${package_name} for openmp")
  
    endif()
  
    mymessage(3 STATUS "OPENMP SETTING - ${func_name} package using a value of ${strValue}")
  
  endfunction()
