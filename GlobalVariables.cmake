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
	ensure_directory_exists("" ${GLOBAL1} "yes")
	install_the_external_package(${GLOBAL1} ${package_name})
endfunction()

#define a function
function(install_the_external_package path package_name)

	message(STATUS "Now in 'install_the_external...' - A function with argument ${package_name}")
# do we know the name of the directory for this package_name 
# is it different than the package name itself?
	ensure_directory_exists(${path} ${package_name} "no")
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
	ensure_directory_exists(${path} ${package_name} "no")
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
#		message("Yes it is empty!")
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
	message(STATUS "HERE NOW ${path}")
	if ("${dirname}" STREQUAL "hdf5")
		build_hdf5()
		message (STATUS "is ${dirname} hdf5")
	else()
		message (STATUS "is ${dirname} not hdf5")
		if ("${dirname}" STREQUAL "lapack")
			build_lapack()
		elseif ("${dirname}" STREQUAL "plplot")			
			build_plplot()
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
#			MESSAGE (STATUS "For LAPACK95 - will place CMakeLists.txt file into ${path}/${dirname}")
#			file(COPY ${THE_PARENT_PATH}/external_project/LAPACK95_CMakeLists.txt DESTINATION ${path}/${dirname})

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

	option(BUILD_HDF5 "Build HDF5, if needed" ON)
#option(BUILD_LAPACK95 "Build LAPACK95" ON)
#option(BUILD_lapack "Build PLplot" ON)
#option(BUILD_XRAYLIB "Build xraylib" ON)
enable_language(Fortran)
include(ExternalProject)
if(BUILD_HDF5)
  message(STATUS "User wants to build HDF5")
  find_package(HDF5 COMPONENTS Fortran)
#  find_package(HDF5 COMPONENTS)
  if(HDF5_Fortran_FOUND)
#  if(HDF5_FOUND)

    message(STATUS "HDF5_Fortran was found - testing it")
    message(STATUS "HDF5 testing the fortran binary")
    set(test_hdf5_fn "${CMAKE_CURRENT_BINARY_DIR}/test-hdf5.f90")
    file(WRITE "${test_hdf5_fn}" "\
      program hdf5_test\n\
      use hdf5\n\
      integer err\n\
      call h5open_f(err)\n\
      call h5close_f(err)\n\
      end program hdf5_test\n")
    message(STATUS "compiling the test_hdf5")
    try_compile(test_hdf5
      "${CMAKE_CURRENT_BINARY_DIR}/test-hdf5"
      SOURCES "${test_hdf5_fn}"
      LINK_LIBRARIES ${HDF5_Fortran_LIBRARIES}
      CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${HDF5_Fortran_INCLUDE_DIRS}")
    file(REMOVE "${test_hdf5_fn}")
    message(STATUS "Do we have test_hdf5")
    if (NOT test_hdf5)
      message(STATUS "We do not have a valid test_hdf5")
      now_really_build_hdf5()
#      set(hdf5_version "1.14.3")
#      execute_process(COMMAND "tar" "xf" "${CMAKE_CURRENT_SOURCE_DIR}/hdf5-${hdf5_version}.tar.bz2")
#      ExternalProject_Add(hdf5
#	SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/hdf5-${hdf5_version}"
#	CONFIGURE_COMMAND
#	"${CMAKE_CURRENT_BINARY_DIR}/hdf5-${hdf5_version}/configure"
#	"--prefix=${CMAKE_INSTALL_PREFIX}"
#	"--enable-fortran"
#	"--enable-cxx"
#	"--without-zlib"
#	"--enable-shared"
#	"--disable-static"
#	"--disable-tests"
#	BUILD_COMMAND make
#	INSTALL_COMMAND make install)
    else()
      message(STATUS "We have a valid version of hdf5 - Add the hdf5 target - 1")
#      add_custom_target(hdf5 COMMAND "true")
#      add_custom_target(hdf52build COMMAND "true")
    endif()
  else()
    message(STATUS "We do not have a valid version of the hdf5 - Add the hdf5 target - 2")
    #maybe this is where we do the hdf5 build?
    now_really_build_hdf5()
    # had to comment this out - I do not understand why
#    add_custom_target(hdf5 COMMAND "true")
#    add_custom_target(hdf52build COMMAND "true")
  endif()
endif()
	
	
endfunction()

function(now_really_build_hdf5)
	message(STATUS "Now really building hdf5")
#	#      set(hdf5_version "1.14.3")
#      execute_process(COMMAND "tar" "xf" "${CMAKE_CURRENT_SOURCE_DIR}/hdf5-${hdf5_version}.tar.bz2")
    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)
#    get_property(BUILD_SHARED_LIBS GLOBAL PROPERTY BMAD_BUILD_SHARED_LIBS)

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
	message(STATUS "Have reached here (hdf5) first")
    	message(STATUS "Value of External bmad directory is ${ATEST1}")
    	message(STATUS "Value of External bmad directory is ${EXTERNAL_BMAD_SOURCE_DIRECTORY}")
    	message(STATUS "Value of GLOBAL1 is ${GLOBAL1}")
    	message(STATUS "Value of GLOBAL2 is ${GLOBAL2}")
    	message(STATUS "Value of cmake install prefix is ${CMAKE_INSTALL_PREFIX}")
     endif()
#    if (DEFINED CACHE{CMAKE_C_COMPILER})
#        message("CMAKE_C_COMPILER is cache")
#    else()
#        message("CMAKE_C_COMPILER is not cache")
#    endif()



#    set(hdf5BuildTo ${CMAKE_INSTALL_PREFIX})
 
#    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
#	set (hdf5BuildTo ${CMAKE_INSTALL_PREFIX}/hdf5)
#    endif()


    # set hdf5_DESTDIR to have install directory by default
    set(hdf5_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
	set (hdf5_DESTDIR ${CMAKE_INSTALL_PREFIX}/hdf5)
    endif()


    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
        message(STATUS "Getting ready to set hdf5_DESTDIR to ${hdf5_DESTDIR")
    endif()

#    set(hdf5_DESTDIR ${CMAKE_INSTALL_PREFIX}/hdf5)
# don't set this here - set it later
#     set(hdf5_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
        message ("Set hdf5_DESTDIR - value is now - ${hdf5_DESTDIR}")
    endif()

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
    	message ("Set hdf5_DESTDIR - value before ExternalProject_Add is now - ${hdf5_DESTDIR}")
    endif()

    ExternalProject_Add(hdf5
	SOURCE_DIR "${GLOBAL1}/hdf5"

	# ORIGINAL LINE (this alone made no difference?)
#	INSTALL_DIR "${CMAKE_INSTALL_PREFIX}"

#TRYING 
#	  INSTALL_DIR "${hdf5_DESTDIR}"

#JSL COMMENTING - DON'T THINK THIS WORKED
#	CMAKE_ARGS
#	  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}


#	  SOURCE_DIR "${EXTERNAL_BMAD_DIRECTORY}/hdf5"
#	  SOURCE_DIR "${BMAD_EXTERNAL_PACKAGES}/hdf5"
#          -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
	CMAKE_CACHE_ARGS
          -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

	#ORIGINAL LINE
#            -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
#TRYING THESE LAST TRIES DID THE TRICK (NOT SURE WHICH ONE - OR BOTH)
#            -DCMAKE_INSTALL_PREFIX:PATH="${hdf5_DESTDIR}"

# 	CONFIGURE_COMMAND "${GLOBAL1}/hdf5/hdf5/configure"
# 	CONFIGURE_COMMAND "${GLOBAL1}/hdf5/configure"
 	CONFIGURE_COMMAND
	  "${GLOBAL1}/hdf5/configure"
# --prefix=${CMAKE_INSTALL_PREFIX}"
# 	CONFIGURE_COMMAND "${CMAKE_CURRENT_BINARY_DIR}/hdf5/configure --prefix=${CMAKE_INSTALL_PREFIX}"

#ORIGINAL LINE
#	"--prefix=${CMAKE_INSTALL_PREFIX}"
#TRYING THESE LAST TRIES DID THE TRICK (NOT SURE WHICH ONE - OR BOTH) - THIS IS IT - THIS IS THE ONE!
	  "--prefix=${hdf5_DESTDIR}"


#NOTE - IF THERE IS A NEED FOR .a instead of .so, would need to build in an if/endif() and have separate ExternalProject_Add - or at least separate variables

	  "--enable-fortran"
	  "--enable-cxx"
	  "--without-zlib"
	  "--enable-shared"
# THIS SWITCH DECIDES of .a or .so
	  "--disable-static"
	  "--disable-tests"
# THIS IS STILL CONFUSING - WHY IS BUILD_COMMAND OF JUST make - DOING A make install?
# I THINK I READ SOMEWHERE THAT ExternalProject_Add ALWAYS DOES A make install - DOES THIS MAKE SENSE?
        BUILD_ALWAYS true
	BUILD_COMMAND make
	INSTALL_COMMAND make install
    )

    message ("Set hdf5_DESTDIR - value After ExternalProject_Add is now - ${hdf5_DESTDIR}")


    install(
        DIRECTORY
        COMPONENT hdf5
#    	DIRECTORY ${hdf5_DESTDIR}}
    	DESTINATION "${hdf5_DESTDIR}"
#    	DESTINATION "."
##        install(DIRECTORY DESTINATION ${hdf5_DESTDIR})
    	USE_SOURCE_PERMISSIONS
#	file(MAKE_DIRECTORY ${hdf5_DESTDIR})
#        file(INSTALL DESTINATION "${hdf5_DESTDIR}" TYPE DIRECTORY USE_SOURCE_PERMISSIONS)
    )

    message(STATUS "Finished setting up the build needed for hdf5")

endfunction()



#function(now_really_build_hdf5)
function(build_lapack)
	message(STATUS "Now really building lapack")
	now_really_build_lapack()
endfunction()

function(now_really_build_lapack)
#	#      set(hdf5_version "1.14.3")
#      execute_process(COMMAND "tar" "xf" "${CMAKE_CURRENT_SOURCE_DIR}/hdf5-${hdf5_version}.tar.bz2")

    message(STATUS "Now really building lapack")

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)
#    get_property(BUILD_SHARED_LIBS GLOBAL PROPERTY BMAD_BUILD_SHARED_LIBS)

#    get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)

#    set(lapack_DESTDIR ${CMAKE_INSTALL_PREFIX}/lapack)

#THIS ENDED UP IN THE WRONG PLACE - /Users/jlaster/modern-cmake-master8/bmad-external-packages/lapack
#    set(lapack_DESTDIR ${GLOBAL1}/lapack)
#TRY THIS INSTEAD

    # set lapack_DESTDIR to have install directory by default
    set(lapack_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
	set (lapack_DESTDIR ${CMAKE_INSTALL_PREFIX}/lapack)
    endif()


#    set(lapack_DESTDIR ${CMAKE_INSTALL_PREFIX}/lapack)

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
        message ("Set lapack_DESTDIR - value has been set to - ${lapack_DESTDIR}")
    endif()


    ExternalProject_Add(lapack
#    ExternalProject_Add(hdf52build
#		CMAKE_FLAGS "-DBUILD_SHARED_LIBS=ON"
	SOURCE_DIR "${GLOBAL1}/lapack"

	CMAKE_ARGS
	  -DCMAKE_INSTALL_PREFIX:PATH=${lapack_DESTDIR}
	  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}

#	CMAKE_INSTALL_PREFIX:PATH=/Users/jlaster/bmad_external
# 		CONFIGURE_COMMAND "${GLOBAL1}/hdf5/hdf5/configure"

        CMAKE_CACHE_ARGS
#      	  -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE
#	     -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/absl
	  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#jsl         -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
#jsl         -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
#         -DCMAKE_INSTALL_PREFIX:PATH=/Users/jlaster/.bmad_external
#          -DCMAKE_INSTALL_PREFIX:PATH=${GLOBAL1}      
#          -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
          
#        -DCMAKE_INSTALL_PREFIX:PATH=/Users/jlaster/bmad_external
#	"--prefix=${CMAKE_INSTALL_PREFIX}"
#	"--enable-fortran"
#	"--enable-cxx"
#	"--without-zlib"
#	"--enable-shared"
#	"--disable-static"
#	"--disable-tests"

        BUILD_ALWAYS true
	BUILD_COMMAND make
	INSTALL_COMMAND make install
	)

    message ("Set lapack_DESTDIR - value After ExternalProject_Add is now - ${lapack_DESTDIR}")

    install(
        DIRECTORY
        COMPONENT lapack
#    	DIRECTORY ${hdf5_DESTDIR}}
    	DESTINATION "${lapack_DESTDIR}"
#    	DESTINATION "."
##        install(DIRECTORY DESTINATION ${hdf5_DESTDIR})
    	USE_SOURCE_PERMISSIONS
#	file(MAKE_DIRECTORY ${hdf5_DESTDIR})
#        file(INSTALL DESTINATION "${hdf5_DESTDIR}" TYPE DIRECTORY USE_SOURCE_PERMISSIONS)
    )    

    message(STATUS "Finished setting up the build needed for lapack")

endfunction()


function(build lapack95_1)
#if(BUILD_LAPACK95)
  set(BLA_VENDOR "Generic")
  find_package(LAPACK)
  if (NOT LAPACK_FOUND)
    message(FATAL_ERROR "LAPACK library not found")
  endif()
  if (NOT LAPACK95_FOUND)
    execute_process(COMMAND "tar" "xf" "${CMAKE_CURRENT_SOURCE_DIR}/lapack95.tgz")
    execute_process(COMMAND "sh" "${CMAKE_CURRENT_SOURCE_DIR}/patch-lapack95.sh")
    set(lapack_deprecated "ggsvp" "tzrqf" "geqpf" "ggsvd" "gegv" "gegs" "gelsx")
    set(lapack95_srcdir "${CMAKE_BINARY_DIR}/LAPACK95/SRC")
    # Get the sources to be built from the LAPAC95 Makefile
    execute_process(COMMAND make -n -p
      WORKING_DIRECTORY ${lapack95_srcdir}
      OUTPUT_VARIABLE lapack95_make)
    string(REGEX MATCHALL "\n.OBJS = [^\n]+\n" lapack95_src ${lapack95_make})
    string(REGEX MATCHALL "la_[a-z0-9]+\\.o" lapack95_src ${lapack95_src})
    # Find liblapack*.{so,dylib}
    foreach(l ${LAPACK_LIBRARIES})
      string(FIND "${l}" "liblapack" lapack_lib_found)
      if(lapack_lib_found GREATER -1)
	set(lapack_lib "${l}")
      endif()
    endforeach()
    if(NOT DEFINED lapack_lib)
      message(FATAL_ERROR "LAPACK library not found in list")
    endif()
    # Extract defined symbols from liblapack
    if (lapack_lib MATCHES "\.so.*$")
      execute_process(COMMAND nm -D ${lapack_lib} OUTPUT_VARIABLE lapack_syms)
      string(REGEX MATCHALL " T [a-z0-9_]+_" lapack_syms "${lapack_syms}")
      string(REGEX REPLACE " T ([a-z0-9_]+)_" "\\1" lapack_syms "${lapack_syms}")
    elseif(lapack_lib MATCHES "\.dylib.*$")
      execute_process(COMMAND nm -g -U ${lapack_lib} OUTPUT_VARIABLE lapack_syms)
      string(REGEX MATCHALL " T [a-z0-9_]+_" lapack_syms "${lapack_syms}")
      string(REGEX REPLACE " T ([a-z0-9_]+)_" "\\1" lapack_syms "${lapack_syms}")
    elseif(lapack_lib MATCHES "\.tbd$")
      file(READ ${lapack_lib} lapack_syms)
      string(REGEX MATCHALL "_[a-z0-9_]+_" lapack_syms "${lapack_syms}")
      string(REGEX REPLACE "_([a-z0-9_]+)_" "\\1" lapack_syms "${lapack_syms}")
    else()
      message(FATAL_ERROR "LAPACK library not dynamic library?")
    endif()
    # Only keep lapack95 functions that have corresponding functions in liblapack
    set(lapack95_good "")
    foreach(f ${lapack95_src})
      string(REGEX REPLACE "la_(.*)\\.o" "\\1" f "${f}")
      set(is_deprecated OFF)
      foreach(d ${lapack_deprecated})
	if (f MATCHES "${d}1?$")
	  set(is_deprecated ON)
	endif()
      endforeach()
      if (NOT is_deprecated)
	list (FIND lapack_syms "${f}" in_lapack)
	if (in_lapack GREATER -1)
	  list(APPEND lapack95_good "${lapack95_srcdir}/la_${f}.f90")
	endif()
	# Some lapack95 routine names end in an extra "1" to handle different array ranks
	string(LENGTH "${f}" lf)
	math(EXPR lf "${lf}-1")
	string(SUBSTRING "${f}" ${lf} 1 fend)
	if (fend EQUAL 1)
	  string(SUBSTRING "${f}" 0 ${lf} f1)
	  list (FIND lapack_syms "${f1}" in_lapack)
	  if (in_lapack GREATER -1)
	    list(APPEND lapack95_good "${lapack95_srcdir}/la_${f}.f90")
	  endif()
	endif()
      endif()
    endforeach()
    string(REGEX MATCHALL "\nOBJAU = [^\n]+\n" lapack95_aux "${lapack95_make}")
    string(REGEX MATCHALL "la_[^.]+\\.o" lapack95_aux "${lapack95_aux}")
    string(REGEX REPLACE "(la_[^.]*)\\.o" "${lapack95_srcdir}/\\1.f90" lapack95_aux "${lapack95_aux}")
    add_library(lapack95 SHARED
      ${lapack95_srcdir}/f77_lapack_single_double_complex_dcomplex.f90
      ${lapack95_srcdir}/f95_lapack_single_double_complex_dcomplex.f90
      ${lapack95_srcdir}/la_auxmod.f90
      ${lapack95_good} ${lapack95_aux})
    set_property(TARGET lapack95
      PROPERTY Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lapack95-prefix/modules")
    set_property(TARGET lapack95
      PROPERTY LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lapack95-prefix/lib")
    set_target_properties(lapack95 PROPERTIES LINKER_LANGUAGE Fortran)
    target_link_libraries(lapack95 ${LAPACK_LIBRARIES})
    target_link_options(lapack95 PRIVATE ${LAPACK_LINKER_FLAGS})
    install(TARGETS lapack95)
    get_property(lapack95_module_dir TARGET lapack95 PROPERTY Fortran_MODULE_DIRECTORY)
    install(FILES
      ${lapack95_module_dir}/f77_lapack.mod
      ${lapack95_module_dir}/f95_lapack.mod
      ${lapack95_module_dir}/la_auxmod.mod
      ${lapack95_module_dir}/la_precision.mod
      DESTINATION lib/fortran/modules/lapack95)
  endif()
#endif()
endfunction()



function(build_plplot)
	message(STATUS "Now really building plplot")
	now_really_build_plplot()
endfunction()

function(now_really_build_plplot)

    message(STATUS "Have reached here - plplot")

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

    message(STATUS "Values - global1 ${GLOBAL1} global2 ${GLOBAL2} plplot_destdir ${plplot_DESTDIR}")

    # set plplot_DESTDIR to have install directory by default
    set(plplot_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
	set (plplot_DESTDIR ${CMAKE_INSTALL_PREFIX}/plplot)
    endif()


#    set(plplot_DESTDIR ${CMAKE_INSTALL_PREFIX}/plplot)

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
        message ("Set plplot_DESTDIR - value has been set to - ${plplot_DESTDIR}")
    endif()


#    set(plplot_version "5.15.0")
    ExternalProject_Add(plplot

#    SOURCE_DIR "${GLOBAL1}/plplot/plplot"
	SOURCE_DIR "${GLOBAL1}/plplot"

	CMAKE_ARGS
	  -DCMAKE_INSTALL_PREFIX:PATH=${plplot_DESTDIR}
	  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
	  -DDEFAULT_NO_DEVICES=ON
	  -DDEFAULT_NO_QT_DEVICES=ON
# This caused the plplot.mod file to not be built!
	  -DDEFAULT_NO_BINDINGS=ON
          -DENABLE_fortran:BOOL=ON



    	CMAKE_CACHE_ARGS
#	  -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
	  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#	  -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
#	  -DCMAKE_INSTALL_PREFIX:PATH=${GLOBAL1} 
#	  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX} 

	CMAKE_ARGS
#	  -DDEFAULT_NO_DEVICES=ON
	  -DPLD_pdfcairo=ON
	  -DPLD_pscairo=ON
	  -DPLD_pngcairo=ON
	  -DPLD_svgcairo=ON
	  -DPLD_xwin=ON
	  -DHAVE_SHAPELIB=OFF
	  -DCMAKE_VERBOSE_MAKEFILE=true
#      -DBUILD_SHARED_LIBS=ON
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

    message ("Set plplot_DESTDIR - value After ExternalProject_Add is now - ${plplot_DESTDIR}")

#    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/plplotConfig.cmake DESTINATION ${plplot_DESTDIR})
#    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/plplotConfig.cmake DESTINATION ${GLOBAL1})

    install(
        DIRECTORY
        COMPONENT plplot
    	DESTINATION "${plplot_DESTDIR}"
    	USE_SOURCE_PERMISSIONS
    )

    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Findplplotlib.cmake DESTINATION ${GLOBAL1}/plplotlib)


    message(STATUS "Finished setting up the build needed for plplot")

endfunction()

function(build_fgsl)
	message(STATUS "Now really building fgsl")
	now_really_build_fgsl()
endfunction()

function(now_really_build_fgsl)
#    get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)

    message(STATUS "Have reached here - fgsl")

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)

    message ("Value of global1 is ${GLOBAL1}")
    message ("Value of global2 is ${GLOBAL2}")
    message ("Value of CMAKE_CURRENT_BINARY_DIR is ${CMAKE_CURRENT_BINARY_DIR}")

#    set(fgsl_BUILDDIR ${CMAKE_CURRENT_BINARY_DIR}/fgsl-prefix)
#    set(gsl_BUILDDIR ${CMAKE_CURRENT_BINARY_DIR}/gsl-prefix)

    # set gsl_DESTDIR to have install directory by default
    set(gsl_DESTDIR ${CMAKE_INSTALL_PREFIX})
    set(fgsl_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
	set (gsl_DESTDIR ${CMAKE_INSTALL_PREFIX}/gsl)
	set (fgsl_DESTDIR ${CMAKE_INSTALL_PREFIX}/fgsl)
    endif()

#    set(fgsl_DESTDIR ${CMAKE_INSTALL_PREFIX}/fgsl)
#    set(gsl_DESTDIR ${CMAKE_INSTALL_PREFIX}/gsl)

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
        message ("Set gsl_DESTDIR - value has been set to - ${gsl_DESTDIR}")
        message ("Set fgsl_DESTDIR - value has been set to - ${fgsl_DESTDIR}")
    endif()

    set(NEED_TO_BUILD_GSL 0)

find_package(GSL)

if(GSL_VERSION)

	set(STR1 ${GSL_VERSION})
	set(STR2 "2.6")

	if("${STR1}" VERSION_LESS "${STR2}")
	
		message(STATUS "Installed version is less than 2.6 - build GSL")
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


#    set(GSL_VERSION "2.8")
#    message (STATUS "Value of GSL_VERSION IS ${GSL_VERSION}")

#   if ${GSL_VERSION} 

#    find_package(GSL)
#   set(BUILD_GSL OFF)
#    if (NOT GSL_FOUND)
#      set(BUILD_GSL ON)
 #     message(STATUS "Set Build_GSL status to On")
 #   endif()
#    message (STATUS "1. Value of GSL_VERSION IS ${GLOBAL_GSL_VERSION_1}")
#    string(REPLACE "." ";" gsl_ver_parts ${GLOBAL_GSL_VERSION_1})
#    message (STATUS "2. Value of GSL_VERSION IS ${GLOBAL_GSL_VERSION_1}")
#    list(GET gsl_ver_parts 0 gsl_maj)
#    list(GET gsl_ver_parts 1 gsl_min)
#    set(fgsl_version "1.6.0")
#	set(gsl_maj "2")
#	set(gsl_min "6")
#    if (gsl_maj EQUAL 2 AND gsl_min EQUAL 6)
#      set(fgsl_version "1.5.0")
#      message(STATUS "Need to use fgsl version of 1.5.0")
#    elseif (gsl_maj EQUAL 2 AND gsl_min EQUAL 5)
#      set(fgsl_version "1.4.0")
#      message(STATUS "Need to use fgsl version of 1.4.0")
#    elseif (gsl_maj LESS 2 OR gsl_min LESS 5)
#      message(STATUS "Need to build_gsl - set to ON")
#      set(BUILD_GSL ON)
#    endif()


#    if (BUILD_GSL1)
#	set(gsl_version "2.8")
#    execute_process(COMMAND "tar" "xf" "${CMAKE_CURRENT_SOURCE_DIR}/gsl-${gsl_version}.tar.gz")

if (${NEED_TO_BUILD_GSL} EQUAL 1)

    ExternalProject_Add(gsl

#      SOURCE_DIR "${GLOBAL1}/gsl/gsl"

	SOURCE_DIR "${GLOBAL1}/gsl"

#      SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/gsl-${gsl_version}"

	CONFIGURE_COMMAND

#    SOURCE_DIR "${GLOBAL1}/plplot/plplot"
#      "${GLOBAL1}/gsl/gsl/configure"
	  "${GLOBAL1}/gsl/configure"
#      "--prefix=${GLOBAL1}"
	  "--prefix=${gsl_DESTDIR}"
	  "--enable-shared"
	  "--disable-static"
	  "--disable-tests"

#	CMAKE_ARGS
	CMAKE_ARGS
	  -DCMAKE_INSTALL_PREFIX:PATH=${gsl_DESTDIR}
#used?	  -DDESTDIR:PATH=${GLOBAL1}
	  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}

	CMAKE_CACHE_ARGS
#       -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
	  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#	   -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
#	   -DCMAKE_INSTALL_PREFIX:PATH=${GLOBAL1}
##	   -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
#	   -DDESTDIR:PATH=${GLOBAL1}
##JSL - NOT SURE IF WE NEED THIS?
#	   -DDESTDIR:PATH=${GLOBAL1}
#      "--prefix=${CMAKE_INSTALL_PREFIX}"
#      "--enable-shared"
#      "--disable-static"

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

    message(STATUS "Finished setting up the build needed for gsl")
endif()

    if(EXISTS ENV{PKG_CONFIG_PATH})
      message ("pkg_config_path does exist")
      set(fgsl_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/gsl/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
    else()
      message ("pkg_config_path does not exist")
      set(fgsl_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/gsl/lib/pkgconfig")
    endif()
#  else()
#    add_custom_target(gsl "true")
#  endif()
  
   message ("Starting setup of fgsl")

## prepare the version of fgsl - 1.4, 1.5, or 1.6 - as specified by fgsl_version
##  ${GLOBAL2}/${package_name}/home/cfsd/laster/Projects/bmad_cmake1/modern-cmake-master/bmad_world/external_project/bmad-external-deps
#  file(COPY ${GLOBAL2}/${package_name}-${fgsl_version}.tar.gz DESTINATION  ${GLOBAL2}/${package_name})
##  file(RENAME ${path}/${dirname}/LAPACK95_CMakeLists.txt ${path}/${dirname}/CMakeLists.txt)

  
#  execute_process(COMMAND "tar" "xf" "${CMAKE_CURRENT_SOURCE_DIR}/fgsl-${fgsl_version}.tar.gz")
  if (CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    set(fgsl_fcflags "-ffree-line-length-none")
  endif()
  if ("${CMAKE_Fortran_FLAGS}" STREQUAL "" AND DEFINED fgsl_fcflags)
    set (fgsl_fcflags "FCFLAGS=${fgsl_fcflags}")
  elseif (NOT "${CMAKE_Fortran_FLAGS}" STREQUAL "" AND NOT DEFINED fgsl_fcflags)
    set (fgsl_fcflags "FCFLAGS=${CMAKE_Fortran_FLAGS}")
  elseif (NOT "${CMAKE_Fortran_FLAGS}" STREQUAL "" AND DEFINED fgsl_fcflags)
    set (fgsl_fcflags "FCFLAGS=${CMAKE_Fortran_FLAGS} ${fgsl_fcflags}")
  endif()


  
#  ExternalProject_Add(fgsl
#    SOURCE_DIR "${GLOBAL1}/fgsl/fgsl"
##    SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/fgsl-${fgsl_version}"
#    CONFIGURE_COMMAND
##    "${CMAKE_CURRENT_BINARY_DIR}/fgsl-${fgsl_version}/configure"
#	${GLOBAL1}/fgsl/fgsl/configure
##    "--prefix=${CMAKE_INSTALL_PREFIX}"
##    "--disable-static"
#    ${fgsl_fcflags}
#    ${fgsl_pc_flags}
#    BUILD_COMMAND make -j 1
##    INSTALL_COMMAND make install)
#endif()
      
##    set(plplot_version "5.15.0")

#    if(EXISTS ENV{PKG_CONFIG_PATH})
#      set(fgsl_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/gsl/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
#   else()
#      set(fgsl_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/gsl/lib/pkgconfig")
#    endif()

# why did I do this?
#  set(fgsl_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/buildhere/gsl-prefix/src/gsl-build:${CMAKE_INSTALL_PREFIX}/gsl/lib/pkgconfig:${GLOBAL1}:$ENV{PKG_CONFIG_PATH}")
#  set(fgsl_pc_flags "PKG_CONFIG_PATH=${CMAKE_CURRENT_BINARY_DIR}/buildhere/gsl-prefix/src/gsl-build:${CMAKE_INSTALL_PREFIX}/gsl/lib/pkgconfig:${GLOBAL1}:$ENV{PKG_CONFIG_PATH}")

  set(fgsl_pc_flags "PKG_CONFIG_PATH=${CMAKE_CURRENT_BINARY_DIR}/gsl-prefix/src/gsl-build:$ENV{PKG_CONFIG_PATH}")

  message(STATUS "Defining ExternalProject_Add for fgsl")


  message(STATUS "set fgsl_srcdir to ${CMAKE_CURRENT_BINARY_DIR}/fgsl-prefix")

  set(fgsl_srcdir "${CMAKE_CURRENT_BINARY_DIR}/fgsl-prefix")
	
  message(STATUS "Execute process autoreconf now!")


  message(STATUS " Another test")


  message(STATUS "autoreconf dir is ${CMAKE_CURRENT_BINARY_DIR}/fgsl-prefix")
  set(fgsl_autoreconfdir "${CMAKE_CURRENT_BINARY_DIR}/fgsl-prefix")

  if(EXISTS ${GLOBAL1}/fgsl/configure.ac)
  	message (STATUS "Directory ${GLOBAL1}/fgsl does exist!")
  else()
  	message (STATUS "Directory ${GLOBAL1}/fgsl does not exist")
  endif()
  
# NOTE - JSL - I do not know how to set this to build into the build directory - modifies - that is, puts files into - the external package area.

  execute_process(
    WORKING_DIRECTORY "${GLOBAL1}/fgsl"
#     WORKING_DIRECTORY "${fgsl_autoreconfdir}"
    COMMAND "autoreconf" "--install"
    RESULT_VARIABLE status
  )

  message(STATUS "finished with autoreconf dir in ${GLOBAL1}/fgsl - status is ${status}")

  message("PKG_CONFIG_PATH: $ENV{PKG_CONFIG_PATH} ${fgsl_pc_flags}") 

  ExternalProject_Add(fgsl
#	SOURCE_DIR "${GLOBAL1}/fgsl/fgsl"
	SOURCE_DIR "${GLOBAL1}/fgsl"
	CONFIGURE_COMMAND
#    SOURCE_DIR "${GLOBAL1}/plplot/plplot"
	  "${GLOBAL1}/fgsl/configure"
#      "${GLOBAL1}/fgsl/fgsl/configure"
#      "${GLOBAL1}/fgsl/fgsl/configure.ac"
	  "--prefix=${fgsl_DESTDIR}"
#	  "--prefix=${GLOBAL1}"
#      "--enable-shared"
	"--disable-static"
	${fgsl_fcflags}
	${fgsl_pc_flags}


	CMAKE_ARGS
#	  -DCMAKE_INSTALL_PREFIX:PATH=${fgsl_DESTDIR}
#	  -DDESTDIR:PATH=${GLOBAL1}
	  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}

	CMAKE_CACHE_ARGS
#	  -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
	  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#	  -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

#    CMAKE_ARGS
#	  -DCMAKE_INSTALL_PREFIX:PATH=${GLOBAL1} 
#	  -DDESTDIR:PATH=${GLOBAL1}

#     -DDEFAULT_NO_DEVICES:STRING=ON
#     -DPLD_pdfcairo:STRING=ON
#      -DPLD_pscairo:STRING=ON
#      -DPLD_pngcairo:STRING=ON
#      -DPLD_svgcairo:STRING=ON
#      -DPLD_xwin:STRING=ON
#      -DHAVE_SHAPELIB:STRING=OFF
#      -DCMAKE_VERBOSE_MAKEFILE:STRING=true
#      -DBUILD_SHARED_LIBS:STRING=ON
#      -DUSE_RPATH:STRING=ON
#      -DPLD_psc:STRING=OFF
#      -DPL_HAVE_QHULL:STRING=OFF
#      -DENABLE_tk:STRING=OFF
#      -DENABLE_tcl:STRING=OFF
#      -DENABLE_java:STRING=OFF
#      -DENABLE_python:STRING=OFF
#      -DENABLE_ada:STRING=OFF
#      -DENABLE_wxwidgets:STRING=OFF
#      -DENABLE_cxx:STRING=OFF
#      -DENABLE_octave:STRING=OFF
#      -DBUILD_TEST:STRING=OFF
    
      BUILD_ALWAYS true
      BUILD_COMMAND make -j 1
      INSTALL_COMMAND make install
    )

    message ("Set fgsl_DESTDIR - value After ExternalProject_Add is now - ${fgsl_DESTDIR}")

    if (${NEED_TO_BUILD_GSL} EQUAL 1)
        message(STATUS "If we had to build our own gsl - Set up dependency for fgsl - it depends on gsl!")
	add_dependencies(fgsl gsl)
    endif()

    install(
        DIRECTORY
        COMPONENT fgsl
    	DESTINATION "${fgsl_DESTDIR}"
    	USE_SOURCE_PERMISSIONS
    )

# lastly, install a Findfgsllib.cmake file - for allowing cmake to find the build of fgsl (module)

    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Findfgsllib.cmake DESTINATION ${GLOBAL1}/fgsl)

    message(STATUS "Finished setting up the build needed for fgsl")

endfunction()

function(build_lapack95)
	message(STATUS "Now really building lapack95")
	now_really_build_lapack95()
endfunction()

function(now_really_build_lapack95)

  message(STATUS "Have reached here - lapack95")

    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)


#    MESSAGE (STATUS "For LAPACK95 - will place CMakeLists.txt file into ${path}/${dirname}")
    MESSAGE (STATUS "For LAPACK95 - will place  ${CMAKE_ROLLOUT_CMAKE_FILES}/LAPACK95_CMakeLists.txt file into ...${GLOBAL1}/lapack95 and then rename it to ${GLOBAL1}/lapack95/CMakeLists.txt")

#	file(COPY ${THE_PARENT_PATH}/external_project/LAPACK95_CMakeLists.txt DESTINATION ${path}/${dirname})

#    file(COPY /Users/jlaster/BmadFiles/LAPACK95_CMakeLists.txt DESTINATION ${path}/${dirname})
    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/LAPACK95_CMakeLists.txt DESTINATION ${GLOBAL1}/lapack95)
#    file(COPY /Users/jlaster/BmadFiles/LAPACK95_CMakeLists.txt DESTINATION ${GLOBAL1}/lapack95)
    file(RENAME ${GLOBAL1}/lapack95/LAPACK95_CMakeLists.txt ${GLOBAL1}/lapack95/CMakeLists.txt)

    

#  Message(STATUS "Modify the CMakeLists.txt file - 1) change '$ENV' to '$' and 2) modify include line last line - to be commented out 'include' to '#include' ")

#jsl - are we doing this to test LAPACK95 goodness?
#   file(COPY /Users/jlaster/aTestFile
#        DESTINATION {GLOBAL1}/lapack95/lapack95)

#/Users/jlaster/modern-cmake-master1/bmad_world/external_project/.bmad_external/lapack95/lapack95/testFileName

#  set_property(TARGET lapack95)

#  add_custom_target(lapack95Inside
#      DEPENDS
#       "$CMAKE_CURRENT_BINARY_DIR/generated_file"
#   )
#   add_custom_command(
#      OUTPUT
#       "$CMAKE_CURRENT_BINARY_DIR/generated_file"
#      COMMAND
#       touch $CMAKE_CURRENT_BINARY_DIR/generated_file
#       sed -i '' 's/$ENV/$/g' ${GLOBAL1}/lapack95/lapack95/CMakeLists.txt
#   )
   #CONFIGURE_COMMAND "${GLOBAL1}/hdf5/hdf5/configure"
#  configure_file(
#    "${GLOBAL1}/lapack95/lapack95/CMakeLists.txt" 
#    "${GLOBAL1}/lapack95/lapack95/CMakeLists.txt.jsl"
#    COPYONLY
#  )

#  file(READ ${GLOBAL1}/lapack95/lapack95/CMakeLists.txt FILE_CONTENTS)
#  string(REPLACE "$ENV" "$" FILE_CONTET${GLOBAL1}/lapack95/lapack95/CMakeLists.txt FILE_CONTENTS)

  find_package(LAPACK)
  if (NOT LAPACK_FOUND)
    message(FATAL_ERROR "BUILDING LAPACK95 - LAPACK library not found")
  else()
    message(STATUS "BUILDING LAPACK95 - FOUND LAPACK library")
  endif()

#  set(ENV{ACC_CMAKE_VERSION} "3.13.2")
  
  # modify the CMakeLists.txt file for now
  # Add a custom command to modify the file
#  add_custom_command(
#    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/config.txt
#    COMMAND sed -i "s/PLACEHOLDER/${MY_VARIABLE}/g" ${CMAKE_CURRENT_SOURCE_DIR}/config.txt
#    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/config.txt
#  )
    
#   add_library(lapack95 SHARED
#      ${lapack95_srcdir}/f77_lapack_single_double_complex_dcomplex.f90
#      ${lapack95_srcdir}/f95_lapack_single_double_complex_dcomplex.f90
#      ${lapack95_srcdir}/la_auxmod.f90
#      ${lapack95_good} ${lapack95_aux})
#    set_property(TARGET lapack95
#      PROPERTY Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lapack95-prefix/modules")
#    set_property(TARGET lapack95
#      PROPERTY LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lapack95-prefix/lib")
#    set_target_properties(lapack95 PROPERTIES LINKER_LANGUAGE Fortran)
#    target_link_libraries(lapack95 ${LAPACK_LIBRARIES})
#    target_link_options(lapack95 PRIVATE ${LAPACK_LINKER_FLAGS})
#    install(TARGETS lapack95)
#    get_property(lapack95_module_dir TARGET lapack95 PROPERTY Fortran_MODULE_DIRECTORY)
#    install(FILES
#      ${lapack95_module_dir}/f95_lapack.mod
#      ${lapack95_module_dir}/la_auxmod.mod
#      ${lapack95_module_dir}/la_precision.mod
#      DESTINATION lib/fortran/modules/lapack95)
#  endif()
    
    # set lapack_DESTDIR to have install directory by default
    set(lapack95_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
	set (lapack_DESTDIR ${CMAKE_INSTALL_PREFIX}/lapack95)
    endif()

    if(DEFINED CACHE{CMAKE_PRINT_DEBUG})
        message(STATUS "Getting ready to set lapack95_DESTDIR to ${CMAKE_INSTALL_PREFIX}/lapack95")
    endif()

#    set(lapack95_DESTDIR ${CMAKE_INSTALL_PREFIX}/lapack95)
    
#    set(plplot_version "5.15.0")
  ExternalProject_Add(lapack95
	SOURCE_DIR "${GLOBAL1}/lapack95"
#    SOURCE_DIR "${GLOBAL1}/lapack95/lapack95"


	CMAKE_ARGS
	  -DCMAKE_INSTALL_PREFIX:PATH=${lapack95_DESTDIR}
	  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
	  -DCMAKE_Fortran_COMPILER:STRING=gfortran
	  -DACC_CMAKE_VERSION=3.13.4

    CMAKE_CACHE_ARGS
#      -DACC_CMAKE_VERSION:STRING=3.13.4

#jsljsljsl
#      -DACC_BUILD_SYSTEM:STRING=/Users/jlaster/bmad/bmad-ecosystem/util
#      -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
      -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#	  -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
#	  -DCMAKE_INSTALL_PREFIX:PATH=${GLOBAL1} 
#      -DDEFAULT_NO_DEVICES:STRING=ON
#    CMAKE_ARGS
#      -DACC_CMAKE_VERSION:STRING=3.13.7
#	  -DCMAKE_SYSTEM_NAME:STRING=Darwin
#	  -DCMAKE_Fortran_COMPILER:STRING=gfortran
#    BUILD_COMMAND make CMAKE_ENV="ACC_CMAKE_VERSION=ENV{ACC_CMAKE_VERSION}")

        BUILD_ALWAYS true
	BUILD_COMMAND make
	INSTALL_COMMAND make install
#	BUILD_COMMAND make
	)
	
    message(STATUS "Finished setting up the build needed for lapack95")

    install(
        DIRECTORY
        COMPONENT lapack95
#    	DIRECTORY ${hdf5_DESTDIR}}
    	DESTINATION "${lapack95_DESTDIR}"
#    	DESTINATION "."
##        install(DIRECTORY DESTINATION ${hdf5_DESTDIR})
    	USE_SOURCE_PERMISSIONS
#	file(MAKE_DIRECTORY ${hdf5_DESTDIR})
#        file(INSTALL DESTINATION "${hdf5_DESTDIR}" TYPE DIRECTORY USE_SOURCE_PERMISSIONS)
    )

endfunction()


function(build_xraylib)
	message(STATUS "Now really building xraylib")
	now_really_build_xraylib()
endfunction()

function(now_really_build_xraylib)
    
  message(STATUS "Now building xraylib")


    get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
    get_property(GLOBAL1 GLOBAL PROPERTY BMAD_EXTERNAL_PACKAGES)


    # set xraylib_DESTDIR to have install directory by default
    set(xraylib_DESTDIR ${CMAKE_INSTALL_PREFIX})

    if(${INSTALL_IN_SEPARATE_DIRS} EQUAL 1)
	set (xraylib_DESTDIR ${CMAKE_INSTALL_PREFIX}/xraylib)
    endif()

  message(STATUS "set xraylib_srcdir to ${CMAKE_CURRENT_BINARY_DIR}/xraylib-prefix - value of xraylib_destdir is ${xraylib_DESTDIR}")

  set(xraylib_srcdir "${CMAKE_CURRENT_BINARY_DIR}/xraylib-prefix")
	
  message(STATUS "Execute process autoreconf now!")


  message(STATUS " Another test")




  message(STATUS "autoreconf dir is ${CMAKE_CURRENT_BINARY_DIR}/xraylib-prefix")
  set(xraylib_autoreconfdir "${CMAKE_CURRENT_BINARY_DIR}/xraylib-prefix")

  if(EXISTS ${GLOBAL1}/xraylib/configure.ac)
  	message (STATUS "Directory ${GLOBAL1}/xraylib does exist!")
  else()
  	message (STATUS "Directory ${GLOBAL1}/xraylib does not exist")
  endif()

#  message(STATUS "autoreconf dir is ${GLOBAL1}/xraylib/xraylib")
#  set(xraylib_autoreconfdir "${GLOBAL1}/xraylib/xraylib")
#
#  if(EXISTS ${GLOBAL1}/xraylib/xraylib/configure.ac1)
#  	message (STATUS "Directory ${GLOBAL1}/xraylib/xraylib does exist!")
#  else()
#  	message (STATUS "Directory ${GLOBAL1}/xraylib/xraylib does not exist")
#  endif()
  
  execute_process(
    WORKING_DIRECTORY "${GLOBAL1}/xraylib"
    COMMAND "autoreconf" "--install"
    RESULT_VARIABLE status
  )

#  message (STATUS "Result of autoreconf is ${status}")

  message(STATUS "finished with autoreconf dir in ${GLOBAL1}/xraylib - status is ${status}")

  ExternalProject_Add(xraylib
    SOURCE_DIR "${GLOBAL1}/xraylib"
    CONFIGURE_COMMAND
#    "${xraylib_srcdir}/configure"
      "${GLOBAL1}/xraylib/configure"
    "--prefix=${xraylib_DESTDIR}"
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

	CMAKE_ARGS
#	  -DCMAKE_INSTALL_PREFIX:PATH=${fgsl_DESTDIR}
#	  -DDESTDIR:PATH=${GLOBAL1}
	  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}

	CMAKE_CACHE_ARGS
#	  -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
	  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#	  -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}

    BUILD_ALWAYS true
    BUILD_COMMAND make
    INSTALL_COMMAND make install
    )

    install(
        DIRECTORY
        COMPONENT xraylib
    	DESTINATION "${xraylib_DESTDIR}"
    	USE_SOURCE_PERMISSIONS
    )

# lastly, install a Findxraylib.cmake file - for allowing cmake to find the build of xraylib (module)

    file(COPY ${CMAKE_ROLLOUT_CMAKE_FILES}/Findxraylib.cmake DESTINATION ${GLOBAL1}/xraylib)



    message(STATUS "Finished setting up the build needed for xraylib")

endfunction()


function(should_build_package package should_build)

	message(STATUS "Checking build for package ${package}")
	message(STATUS "status of build_all is ${BUILD_ALL}")
#	set (fgsl "FGSL")
	set (package_name_to_use "not set")
	package_map(${package} package_name_to_use)
	message(STATUS "3. VALUE OF package_name_to_use after calling package_map is now ${package_name_to_use}")
	message(STATUS "VALUE OF BUILD_${package} is ${BUILD_${package_name_to_use}}")
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

	message(STATUS "1. (package_map) called with ${package} : ${mapped_name}")
	message(STATUS "(package_map) Checking build for package ${package}")
#	message(STATUS "(package_map) status of build_all is ${BUILD_ALL}")
#	set (fgsl "FGSL")
#	message(STATUS "(package_map) VALUE OF BUILD_${package} is ${BUILD_${package}}")

	if (${package} STREQUAL "fgsl")
 		set(${mapped_name} "FGSL" PARENT_SCOPE)
	elseif(${package} STREQUAL "h5cc")
 		set(${mapped_name} "HDF5" PARENT_SCOPE)
	elseif(${package} STREQUAL "lapack")
		message(STATUS "(package_map) FOUND A MATCH for ${package}")
 		set(${mapped_name} "LAPACK" PARENT_SCOPE)
		message(STATUS "2. now mapped_name in this function is ${mapped_name}")
	elseif(${package} STREQUAL "lapack95")
 		set(${mapped_name} "LAPACK95" PARENT_SCOPE)
	elseif(${package} STREQUAL "plplot")
 		set(${mapped_name} "PLPLOT" PARENT_SCOPE)
	elseif(${package} STREQUAL "xraylib")
 		set(${mapped_name} "XRAYLIB" PARENT_SCOPE)
	else()
		message(FATAL_ERROR "(package_map) Package name mapping not found - aborting - ${package}")
	endif()
	message(STATUS "(package_map) Value of package - mapped name is ${package} - ${mapped_name}")
endfunction()
