message (STATUS "This file was included")

#set_property(GLOBAL PROPERTY INTERNAL_MAD_DIRECTORY /Users/jlaster/.bmad_external)



#set_property(GLOBAL PROPERTY BASE_BMAD_EXTERNAL_DIRECTORY test)


##jsl - set_property(GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY $ENV{HOME}/.bmad_external)

#set(CMAKE_INSTALL_PREFIX ${THE_PARENT_PATH}/${CMAKE_INSTALL_EXTERNAL_PREFIX})

#set_property(GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY ${CMAKE_INSTALL_EXTERNAL_PREFIX})
set_property(GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY ${CMAKE_INSTALL_PREFIX})

message (STATUS "returning 1")
message (STATUS "returning 2")


# the last part goes away in the fullness of time (that is, we will use bmad_source_external and not bmad-external-deps)

#set_property(GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY $ENV{HOME}/bmad_source_external/bmad-external-deps)
#set_property(GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY ${THE_PARENT_PATH}/bmad_source_external/bmad-external-deps)
set_property(GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY ${THE_PARENT_PATH}/external_project/bmad-external-deps)

#/Users/jlaster/bmad_test_external
#add_custom_command(TARGET ${target_name} PRE_BUILD COMMAND ${CMAKE_COMMAND} -E make_directory ${directory})


#message (STATUS "Value of global variable is '${GLOBAL}'")

#define a function
function(install_package package_name)
	message(STATUS "A function with argument ${package_name}")
	get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
	ensure_directory_exists("" ${GLOBAL1} "yes")
	install_the_external_package(${GLOBAL1} ${package_name})
endfunction()

#define a function
function(install_the_external_package path package_name)

	message(STATUS "Now in 'install_the_external...' - A function with argument ${package_name}")
#	get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
# do we know the name of the directory for this package_name 
# is it different than the package name itself?
	ensure_directory_exists(${path} ${package_name} "no")
	get_property(GLOBAL2 GLOBAL PROPERTY EXTERNAL_BMAD_SOURCE_DIRECTORY)
# does it have anything in it?
# if no, copy the tarfile to this location and untar it
	message(STATUS "Going to look for ${GLOBAL2}/${package_name}.tar.gz")
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
		message (STATUS "directory found")
	else()
		if ("${shouldcreate}" STREQUAL "yes")
			message (STATUS "'${dirname}' directory not found - creating")
			#should this be done at 1 install time, 2 build system generation time, or at 3 build time?
			# the only one that worked for me was number 2 - and it was created after my first cmake .
	#	1
	#		install(DIRECTORY DESTINATION ${path}${dirname})
	#	2
	# create the directory
	
			file(MAKE_DIRECTORY ${P_WITH_D_MAYBE})
		
	# a last check to make sure we created it - otherwise, fail out of everything
	
			if (EXISTS "${P_WITH_D_MAYBE}")
		# "${_fullpath}/CMakeLists.txt")
				message (STATUS "directory was successfully created - directory found")
			else()
				message (FATAL_ERROR "directory still not found - I tried my best - aborting - ")
			endif()
	#	3
	#		${CMAKE_COMMAND} -E make_directory ${dirname}


		else()

			message (STATUS "was just curious - not creating ${dirname}")


		endif()


		
	endif()
endfunction()

function(build_package path dirname)

	message(STATUS "building ${path} ${dirname}")
#	COMMAND ${CMAKE_COMMAND} -E tar xvzf {path}/${dirname}.tar.gz
	file(ARCHIVE_EXTRACT INPUT ${path}/${dirname}.tar.gz DESTINATION ${path})
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
#/Users/jlaster/modern-cmake-master1/bmad_world/.bmad_external/lapack95/lapack95/
			MESSAGE (STATUS "For LAPACK95 - will place CMakeLists.txt file into ${path}/${dirname}")
#			file(COPY /Users/jlaster/BmadFiles/LAPACK95_CMakeLists.txt DESTINATION ${CMAKE_BINARY_DIR}/bin RENAME CMakeLists.txt)
#			file(COPY /Users/jlaster/BmadFiles/LAPACK95_CMakeLists.txt DESTINATION ${path}/${dirname})

#			file(COPY ${THE_PARENT_PATH}/bmad_world/external_project/LAPACK95_CMakeLists.txt DESTINATION ${path}/${dirname})
			file(COPY ${THE_PARENT_PATH}/external_project/LAPACK95_CMakeLists.txt DESTINATION ${path}/${dirname})

			file(RENAME ${path}/${dirname}/LAPACK95_CMakeLists.txt ${path}/${dirname}/CMakeLists.txt)
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
    message(STATUS, "compiling the test_hdf5")
    try_compile(test_hdf5
      "${CMAKE_CURRENT_BINARY_DIR}/test-hdf5"
      SOURCES "${test_hdf5_fn}"
      LINK_LIBRARIES ${HDF5_Fortran_LIBRARIES}
      CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${HDF5_Fortran_INCLUDE_DIRS}")
    file(REMOVE "${test_hdf5_fn}")
    message(STATUS "Do we have test_hdf5")
    if (NOT test_hdf5)
      message(STATUS "We do not have the test_hdf5")
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

#function(build_lapack)
function(now_really_build_hdf5)
	message(STATUS "Now really building hdf5")
#	#      set(hdf5_version "1.14.3")
#      execute_process(COMMAND "tar" "xf" "${CMAKE_CURRENT_SOURCE_DIR}/hdf5-${hdf5_version}.tar.bz2")
    get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
    message(STATUS "Have reached here (hdf5) first")

#    if (DEFINED CACHE{CMAKE_C_COMPILER})
#        message("CMAKE_C_COMPILER is cache")
#    else()
#        message("CMAKE_C_COMPILER is not cache")
#    endif()

    ExternalProject_Add(hdf5
#    ExternalProject_Add(hdf52build
	  SOURCE_DIR "${GLOBAL1}/hdf5"
	  CMAKE_CACHE_ARGS
#      	  -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE
#	     -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/absl
         -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#jsl         -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
         -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
#jsl         -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
#         -DCMAKE_INSTALL_PREFIX:PATH=/Users/jlaster/.bmad_external
          -DCMAKE_INSTALL_PREFIX:PATH=${GLOBAL1}
 	CONFIGURE_COMMAND "${GLOBAL1}/hdf5/hdf5/configure"
	"--prefix=${CMAKE_INSTALL_PREFIX}"
	"--enable-fortran"
	"--enable-cxx"
	"--without-zlib"
	"--enable-shared"
	"--disable-static"
	"--disable-tests"
	BUILD_COMMAND make
#	INSTALL_COMMAND make install
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
    get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
    
    message(STATUS "Have reached here")
    ExternalProject_Add(lapack
#    ExternalProject_Add(hdf52build
#		CMAKE_FLAGS "-DBUILD_SHARED_LIBS=ON"
		SOURCE_DIR "${GLOBAL1}/lapack/lapack"
# 		CONFIGURE_COMMAND "${GLOBAL1}/hdf5/hdf5/configure"

        CMAKE_CACHE_ARGS
#      	  -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE
#	     -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/absl
         -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#jsl         -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
         -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
#jsl         -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
#         -DCMAKE_INSTALL_PREFIX:PATH=/Users/jlaster/.bmad_external
          -DCMAKE_INSTALL_PREFIX:PATH=${GLOBAL1}      
          
#        -DCMAKE_INSTALL_PREFIX:PATH=/Users/jlaster/bmad_external
#	"--prefix=${CMAKE_INSTALL_PREFIX}"
#	"--enable-fortran"
#	"--enable-cxx"
#	"--without-zlib"
#	"--enable-shared"
#	"--disable-static"
#	"--disable-tests"
	BUILD_COMMAND make
#	INSTALL_COMMAND make install
	)
    
    
    
#    ExternalProject_Add(lapack
#    ExternalProject_Add(hdf52build
#	  SOURCE_DIR "${GLOBAL1}/lapack"
# 	CONFIGURE_COMMAND "${GLOBAL1}/hdf5/hdf5/configure"
#	"--prefix=${CMAKE_INSTALL_PREFIX}"
#	"--enable-fortran"
#	"--enable-cxx"
#	"--without-zlib"
#	"--enable-shared"
#	"--disable-static"
#	"--disable-tests"
#	BUILD_COMMAND make
#	INSTALL_COMMAND make install
#   )
#    message(STATUS "Finished setting up the build needed for lapack")



#	ExternalProject_Add(lapack
#		BUILD_COMMAND brew cask install lapack 
#	)

#    get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
#    ExternalProject_Add(lapack
#    ExternalProject_Add(hdf52build
#	  SOURCE_DIR "${GLOBAL1}/lapack"
# 	CONFIGURE_COMMAND "${GLOBAL1}/hdf5/hdf5/configure"
#	"--prefix=${CMAKE_INSTALL_PREFIX}"
#	"--enable-fortran"
#	"--enable-cxx"
#	"--without-zlib"
#	"--enable-shared"
#	"--disable-static"
#	"--disable-tests"
#	BUILD_COMMAND make
#	INSTALL_COMMAND make install
#    )
    message(STATUS "Finished setting up the build needed for lapack")

endfunction()

function(build lapack95)
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
    get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
    message(STATUS "Have reached here - plplot")
    
#    set(plplot_version "5.15.0")
  ExternalProject_Add(plplot
    SOURCE_DIR "${GLOBAL1}/plplot/plplot"
    CMAKE_CACHE_ARGS
#	  -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
	  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#	  -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
	  -DCMAKE_INSTALL_PREFIX:PATH=${GLOBAL1} 
      -DDEFAULT_NO_DEVICES:STRING=ON
      -DPLD_pdfcairo:STRING=ON
      -DPLD_pscairo:STRING=ON
      -DPLD_pngcairo:STRING=ON
      -DPLD_svgcairo:STRING=ON
      -DPLD_xwin:STRING=ON
      -DHAVE_SHAPELIB:STRING=OFF
      -DCMAKE_VERBOSE_MAKEFILE:STRING=true
      -DBUILD_SHARED_LIBS:STRING=ON
      -DUSE_RPATH:STRING=ON
      -DPLD_psc:STRING=OFF
      -DPL_HAVE_QHULL:STRING=OFF
      -DENABLE_tk:STRING=OFF
      -DENABLE_tcl:STRING=OFF
      -DENABLE_java:STRING=OFF
      -DENABLE_python:STRING=OFF
      -DENABLE_ada:STRING=OFF
      -DENABLE_wxwidgets:STRING=OFF
      -DENABLE_cxx:STRING=OFF
      -DENABLE_octave:STRING=OFF
      -DBUILD_TEST:STRING=OFF
    
    BUILD_COMMAND make
    )
	
    message(STATUS "Finished setting up the build needed for plplot")

endfunction()

function(build_fgsl)
	message(STATUS "Now really building fgsl")
	now_really_build_fgsl()
endfunction()

function(now_really_build_fgsl)
    get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
    message(STATUS "Have reached here - fgsl")
    
    find_package(GSL)
    set(BUILD_GSL OFF)
    if (NOT GSL_FOUND)
      set(BUILD_GSL ON)
      message(STATUS "Set Build_GSL status to On")
    endif()
    string(REPLACE "." ";" gsl_ver_parts ${GSL_VERSION})
    list(GET gsl_ver_parts 0 gsl_maj)
    list(GET gsl_ver_parts 1 gsl_min)
    set(fgsl_version "1.6.0")
	set(gsl_maj "2")
	set(gsl_min "6")
    if (gsl_maj EQUAL 2 AND gsl_min EQUAL 6)
      set(fgsl_version "1.5.0")
      message(STATUS "Need to use fgsl version of 1.5.0")
    elseif (gsl_maj EQUAL 2 AND gsl_min EQUAL 5)
      set(fgsl_version "1.4.0")
      message(STATUS "Need to use fgsl version of 1.4.0")
    elseif (gsl_maj LESS 2 OR gsl_min LESS 5)
      message(STATUS "Need to build_gsl - set to ON")
      set(BUILD_GSL ON)
    endif()


  if (BUILD_GSL)
    set(gsl_version "2.8")
#    execute_process(COMMAND "tar" "xf" "${CMAKE_CURRENT_SOURCE_DIR}/gsl-${gsl_version}.tar.gz")
    ExternalProject_Add(gsl
      SOURCE_DIR "${GLOBAL1}/gsl/gsl"
#      SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/gsl-${gsl_version}"
      CONFIGURE_COMMAND
#    SOURCE_DIR "${GLOBAL1}/plplot/plplot"
      "${GLOBAL1}/gsl/gsl/configure"
      "--prefix=${GLOBAL1}"
#      "--enable-shared"
#      "--disable-static"
      CMAKE_CACHE_ARGS
#       -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
       -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#	   -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
	   -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
	   -DCMAKE_INSTALL_PREFIX:PATH=${GLOBAL1}
	   -DDESTDIR:PATH=${GLOBAL1}
#      "--prefix=${CMAKE_INSTALL_PREFIX}"
#      "--enable-shared"
#      "--disable-static"
      BUILD_COMMAND make
#      INSTALL_COMMAND make install)
    )
    if(EXISTS ENV{PKG_CONFIG_PATH})
      set(fgsl_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
    else()
      set(fgsl_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/lib/pkgconfig")
    endif()
  else()
    add_custom_target(gsl "true")
  endif()
  
# prepare the version of fgsl - 1.4, 1.5, or 1.6 - as specified by fgsl_version
#  ${GLOBAL2}/${package_name}/home/cfsd/laster/Projects/bmad_cmake1/modern-cmake-master/bmad_world/external_project/bmad-external-deps
  file(COPY ${GLOBAL2}/${package_name}-${fgsl_version}.tar.gz DESTINATION  ${GLOBAL2}/${package_name})
#  file(RENAME ${path}/${dirname}/LAPACK95_CMakeLists.txt ${path}/${dirname}/CMakeLists.txt)

  
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

  set(fgsl_pc_flags "PKG_CONFIG_PATH=${CMAKE_INSTALL_PREFIX}/lib/pkgconfig:${GLOBAL1}:$ENV{PKG_CONFIG_PATH}")


  ExternalProject_Add(fgsl
    SOURCE_DIR "${GLOBAL1}/fgsl/fgsl"
    CONFIGURE_COMMAND
#    SOURCE_DIR "${GLOBAL1}/plplot/plplot"
      "${GLOBAL1}/fgsl/fgsl/configure"
#      "${GLOBAL1}/fgsl/fgsl/configure.ac"
      "--prefix=${GLOBAL1}"
#      "--enable-shared"
#      "--disable-static"
     ${fgsl_fcflags}
     ${fgsl_pc_flags}

    CMAKE_CACHE_ARGS
#	  -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
	  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#	  -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
	  -DCMAKE_INSTALL_PREFIX:PATH=${GLOBAL1} 
	  -DDESTDIR:PATH=${GLOBAL1}
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
    
    BUILD_COMMAND make
    )
	
    message(STATUS "Finished setting up the build needed for fgsl")

endfunction()

function(build_lapack95)
	message(STATUS "Now really building lapack95")
	now_really_build_lapack95()
endfunction()

function(now_really_build_lapack95)
    get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
    
  message(STATUS "Have reached here - lapack95")

  Message(STATUS "Modify the CMakeLists.txt file - 1) change '$ENV' to '$' and 2) modify include line last line - to be commented out 'include' to '#include' ")

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
    message(FATAL_ERROR "LAPACK library not found")
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
    
    
#    set(plplot_version "5.15.0")
  ExternalProject_Add(lapack95
    SOURCE_DIR "${GLOBAL1}/lapack95/lapack95"
    CMAKE_CACHE_ARGS
#      -DACC_CMAKE_VERSION:STRING=3.13.4
#jsljsljsl
#      -DACC_BUILD_SYSTEM:STRING=/Users/jlaster/bmad/bmad-ecosystem/util
#      -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
      -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#	  -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
	  -DCMAKE_INSTALL_PREFIX:PATH=${GLOBAL1} 
#      -DDEFAULT_NO_DEVICES:STRING=ON
    CMAKE_ARGS
#      -DACC_CMAKE_VERSION:STRING=3.13.7
#	  -DCMAKE_SYSTEM_NAME:STRING=Darwin
	  -DCMAKE_Fortran_COMPILER:STRING=gfortran
#    BUILD_COMMAND make CMAKE_ENV="ACC_CMAKE_VERSION=ENV{ACC_CMAKE_VERSION}")
	BUILD_COMMAND make
	)
	
    message(STATUS "Finished setting up the build needed for lapack95")

endfunction()


function(build_xraylib)
	message(STATUS "Now really building xraylib")
	now_really_build_xraylib()
endfunction()

function(now_really_build_xraylib)
    get_property(GLOBAL1 GLOBAL PROPERTY EXTERNAL_BMAD_DIRECTORY)
    
  message(STATUS "Have reached here - xraylib")



#  find_package(LAPACK)
#  if (NOT LAPACK_FOUND)
#    message(FATAL_ERROR "LAPACK library not found")
#  endif()

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
    
    
#    set(plplot_version "5.15.0")
  

  message(STATUS "set xraylib_srcdir to ${CMAKE_CURRENT_BINARY_DIR}/xraylib-prefix")

  set(xraylib_srcdir "${CMAKE_CURRENT_BINARY_DIR}/xraylib-prefix")
	
  message(STATUS "Execute process autoreconf now!")


  message(STATUS " Another test")

  message(STATUS "autoreconf dir is ${GLOBAL1}/xraylib/xraylib")
  set(xraylib_autoreconfdir "${GLOBAL1}/xraylib/xraylib")

  if(EXISTS ${GLOBAL1}/xraylib/xraylib/configure.ac1)
  	message (STATUS "Directory ${GLOBAL1}/xraylib/xraylib does exist!")
  else()
  	message (STATUS "Directory ${GLOBAL1}/xraylib/xraylib does not exist")
  endif()
  
  execute_process(
    WORKING_DIRECTORY "${GLOBAL1}/xraylib/xraylib"
    COMMAND "autoreconf" "--install"
    RESULT_VARIABLE status
  )

#  message (STATUS "Result of autoreconf is ${status}")


  ExternalProject_Add(xraylib
    SOURCE_DIR "${GLOBAL1}/xraylib/xraylib"
    CONFIGURE_COMMAND
#    "${xraylib_srcdir}/configure"
      "${GLOBAL1}/xraylib/xraylib/configure"
    "--prefix=${CMAKE_INSTALL_PREFIX}"
    "--disable-idl"
    "--disable-java"
    "--disable-lua"
    "--disable-perl"
    "--disable-python"
    "--disable-python-numpy"
    "--disable-libtool-lock"
    "--disable-ruby"
    "--disable-php"
    BUILD_COMMAND make
    INSTALL_COMMAND make install)

    message(STATUS "Finished setting up the build needed for xraylib")

endfunction()


function(now_really_build_xraylibjunk)

  ExternalProject_Add(xraylib
    SOURCE_DIR "${GLOBAL1}/xraylib/xraylib"
##    CMAKE_CACHE_ARGS
#      -DACC_CMAKE_VERSION:STRING=3.13.4
#jsljsljsl
#      -DACC_BUILD_SYSTEM:STRING=/Users/jlaster/bmad/bmad-ecosystem/util
#      -DCMAKE_C_COMPILER:STRING=/opt/homebrew/bin/gcc-13
      -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
#	  -DCMAKE_CXX_COMPILER:STRING=/opt/homebrew/bin/g++-13
	  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
	  -DCMAKE_INSTALL_PREFIX:PATH=${GLOBAL1} 
#      -DDEFAULT_NO_DEVICES:STRING=ON
##    CMAKE_ARGS
#      -DACC_CMAKE_VERSION:STRING=3.13.7
#j	  -DCMAKE_SYSTEM_NAME:STRING=Darwin
#j	  -DCMAKE_FORTRAN_COMPILER:STRING=Fortran
#    BUILD_COMMAND make CMAKE_ENV="ACC_CMAKE_VERSION=ENV{ACC_CMAKE_VERSION}")
	BUILD_COMMAND make
	)
	
    message(STATUS "Finished setting up the build needed for xraylib")

endfunction()
