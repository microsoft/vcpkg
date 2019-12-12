if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic AND VCPKG_CRT_LINKAGE STREQUAL static)
    message(STATUS "Warning: Dynamic library with static CRT is not supported. Building static library.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()


set(PYTHON_VERSION_MAJOR  3)
set(PYTHON_VERSION_MINOR  7)
set(PYTHON_VERSION_PATCH  3)
set(PYTHON_VERSION        ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}.${PYTHON_VERSION_PATCH})
set(PYTHON_SHA512		  "023960a2f570fe7178d3901df0c3c33346466906b6d55c73ef7947c19619dbab62efc42c7262a0539bc5e31543b1113eb7a088d4615ad7557a0707bdaca27940")


function (vcpkg_build_msbuild_type PROJECT_PATH PLATFORM BUILD_TYPE)
	set(VCPKG_BUILD_TYPE_backup ${VCPKG_BUILD_TYPE})
	set(VCPKG_BUILD_TYPE ${BUILD_TYPE})
	vcpkg_build_msbuild(
		PROJECT_PATH ${PROJECT_PATH}
		PLATFORM ${PLATFORM}
	)
	set(VCPKG_BUILD_TYPE ${VCPKG_BUILD_TYPE_backup})
endfunction()


if (VCPKG_TARGET_IS_WINDOWS)

	if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
		if (NOT VCPKG_CRT_LINKAGE STREQUAL static)
	    	message(FATAL_ERROR "CRT must be static! Patched build requires LIB AND CRT to be static.")
		endif()

		set(SOURCE_STATIC_PATCH_0001 "0001-Static-library.patch")
		set(SOURCE_STATIC_PATCH_0002 "0002-Static-CRT.patch")
		set(SOURCE_STATIC_PATCH_0003 "0003-Fix-header-for-static-linkage.patch")
		set(SOURCE_STATIC_PATCH_0004 "0004-Remove-linktime-global-optimization.patch")
	endif()
	
	if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
		set(BUILD_ARCH "Win32")
		set(OUT_DIR "win32")
	elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
		set(BUILD_ARCH "x64")
		set(OUT_DIR "amd64")
	else()
		message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
	endif()

	################
	# Release build
	################

	if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
		vcpkg_from_github(
		    OUT_SOURCE_PATH DL_SOURCE_PATH
		    REPO python/cpython
		    REF "v${PYTHON_VERSION}"
		    SHA512 "${PYTHON_SHA512}"
		    HEAD_REF master
		    PATCHES
				"${SOURCE_STATIC_PATCH_0001}"
				"${SOURCE_STATIC_PATCH_0002}"
				"${SOURCE_STATIC_PATCH_0003}"
				"${SOURCE_STATIC_PATCH_0004}"
		)

		set(SOURCE_PATH "${DL_SOURCE_PATH}-${TARGET_TRIPLET}-rel")
		file(REMOVE_RECURSE ${SOURCE_PATH})
		file(RENAME ${DL_SOURCE_PATH} ${SOURCE_PATH})

		message(STATUS "Building ${TARGET_TRIPLET}-rel")

		vcpkg_build_msbuild_type(
			${SOURCE_PATH}/PCBuild/pythoncore.vcxproj
			${BUILD_ARCH}
			"release"
		)

		file(GLOB HEADERS ${SOURCE_PATH}/Include/*.h)
		file(COPY ${HEADERS} ${SOURCE_PATH}/PC/pyconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR})
		file(COPY ${SOURCE_PATH}/Lib DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})
		file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

		if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
			file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
		endif()
	endif()

	################
	# Debug build
	################

	if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
		vcpkg_from_github(
		    OUT_SOURCE_PATH DL_SOURCE_PATH
		    REPO python/cpython
		    REF "v${PYTHON_VERSION}"
		    SHA512 "${PYTHON_SHA512}"
		    HEAD_REF master
		    PATCHES
				"${SOURCE_STATIC_PATCH_0001}"
				"${SOURCE_STATIC_PATCH_0002}"
				"${SOURCE_STATIC_PATCH_0003}"
				"${SOURCE_STATIC_PATCH_0004}"
		)

		set(SOURCE_PATH "${DL_SOURCE_PATH}-${TARGET_TRIPLET}-dbg")
		file(REMOVE_RECURSE ${SOURCE_PATH})
		file(RENAME ${DL_SOURCE_PATH} ${SOURCE_PATH})

		message(STATUS "Building ${TARGET_TRIPLET}-dbg")

		vcpkg_build_msbuild_type(
			${SOURCE_PATH}/PCBuild/pythoncore.vcxproj
			${BUILD_ARCH}
			"debug"
		)

		file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
	
		if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
			file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
		endif()

		vcpkg_copy_pdbs()
	endif()

else() # MACOS + Linux

	find_program(MAKE make)
	if (NOT MAKE)
		message(FATAL_ERROR "MAKE not found")
	endif()
	
	################
	# Release build
	################

	if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
		vcpkg_from_github(
		    OUT_SOURCE_PATH DL_SOURCE_PATH
		    REPO python/cpython
		    REF "v${PYTHON_VERSION}"
		    SHA512 "${PYTHON_SHA512}"
		    HEAD_REF master
		)

		set(SOURCE_PATH "${DL_SOURCE_PATH}-${TARGET_TRIPLET}-rel")
		file(REMOVE_RECURSE ${SOURCE_PATH})
		file(RENAME ${DL_SOURCE_PATH} ${SOURCE_PATH})

		message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
		set(OUT_PATH ${SOURCE_PATH}/../../make-build-${TARGET_TRIPLET}-rel)
		file(MAKE_DIRECTORY ${OUT_PATH})
		
		if(VCPKG_TARGET_IS_OSX)
			vcpkg_execute_build_process(
			  COMMAND "${SOURCE_PATH}/configure" --prefix=${OUT_PATH} --with-openssl=${CURRENT_INSTALLED_DIR} "CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include -framework CoreFoundation" "LDFLAGS=-L${CURRENT_INSTALLED_DIR}/lib" "LIBS=-liconv"
			  WORKING_DIRECTORY ${SOURCE_PATH}
			  LOGNAME config-${TARGET_TRIPLET}-rel
			)
		else()
			vcpkg_execute_build_process(
			  COMMAND "${SOURCE_PATH}/configure" --prefix=${OUT_PATH} --with-openssl=${CURRENT_INSTALLED_DIR} "CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include" "LDFLAGS=-L${CURRENT_INSTALLED_DIR}/lib"
			  WORKING_DIRECTORY ${SOURCE_PATH}
			  LOGNAME config-${TARGET_TRIPLET}-rel
			)
		endif()

		message(STATUS "Building ${TARGET_TRIPLET}-rel")

		vcpkg_execute_build_process(
		  COMMAND make -j ${VCPKG_CONCURRENCY}
		  NO_PARALLEL_COMMAND make
		  WORKING_DIRECTORY ${SOURCE_PATH}
		  LOGNAME make-build-${TARGET_TRIPLET}-rel
		)
		
		message(STATUS "Installing ${TARGET_TRIPLET}-rel")
		vcpkg_execute_build_process(
		  COMMAND make install
		  WORKING_DIRECTORY ${SOURCE_PATH}
		  LOGNAME make-install-${TARGET_TRIPLET}-rel
		)

		file(GLOB HEADERS ${OUT_PATH}/include/*)
		file(COPY ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
		file(GLOB LIBS ${OUT_PATH}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/*)
		file(COPY ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/Lib)
		file(GLOB LIBS ${OUT_PATH}/lib/pkgconfig/*)
		file(COPY ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})
		file(COPY ${OUT_PATH}/lib/libpython${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}m.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
		message(STATUS "Installing ${TARGET_TRIPLET}-rel done")
	endif()

	################
	# Debug build
	################

	if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
		vcpkg_from_github(
		    OUT_SOURCE_PATH DL_SOURCE_PATH
		    REPO python/cpython
		    REF "v${PYTHON_VERSION}"
		    SHA512 "${PYTHON_SHA512}"
		    HEAD_REF master
		)

		set(SOURCE_PATH "${DL_SOURCE_PATH}-${TARGET_TRIPLET}-dbg")
		file(REMOVE_RECURSE ${SOURCE_PATH})
		file(RENAME ${DL_SOURCE_PATH} ${SOURCE_PATH})

		message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
		set(OUT_PATH ${SOURCE_PATH}/../../make-build-${TARGET_TRIPLET}-dbg)
		file(MAKE_DIRECTORY ${OUT_PATH})

		if(VCPKG_TARGET_IS_OSX)
			vcpkg_execute_build_process(
			  COMMAND "${SOURCE_PATH}/configure" --prefix=${OUT_PATH} --with-openssl=${CURRENT_INSTALLED_DIR}/debug "CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include -framework CoreFoundation" "LDFLAGS=-L${CURRENT_INSTALLED_DIR}/debug/lib" "LIBS=-liconv"
			  WORKING_DIRECTORY ${SOURCE_PATH}
			  LOGNAME config-${TARGET_TRIPLET}-dbg
			)
		else()
			vcpkg_execute_build_process(
			  COMMAND "${SOURCE_PATH}/configure" --prefix=${OUT_PATH} --with-openssl=${CURRENT_INSTALLED_DIR}/debug "CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include" "LDFLAGS=-L${CURRENT_INSTALLED_DIR}/debug/lib"
			  WORKING_DIRECTORY ${SOURCE_PATH}
			  LOGNAME config-${TARGET_TRIPLET}-dbg
			)
		endif()

		message(STATUS "Building ${TARGET_TRIPLET}-dbg")
		vcpkg_execute_build_process(
		  COMMAND make -j ${VCPKG_CONCURRENCY}
		  NO_PARALLEL_COMMAND make
		  WORKING_DIRECTORY ${SOURCE_PATH}
		  LOGNAME make-build-${TARGET_TRIPLET}-dbg
		)
		
		message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
		vcpkg_execute_build_process(
		  COMMAND make install
		  WORKING_DIRECTORY ${SOURCE_PATH}
		  LOGNAME make-install-${TARGET_TRIPLET}-dbg
		)

		file(COPY ${OUT_PATH}/lib/libpython${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}m.a DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
		message(STATUS "Installing ${TARGET_TRIPLET}-dbg done")
	endif()

endif()
	
# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/LICENSE ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/copyright)

