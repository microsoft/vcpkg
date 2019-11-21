if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic AND VCPKG_CRT_LINKAGE STREQUAL static)
    message(STATUS "Warning: Dynamic library with static CRT is not supported. Building static library.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(PYTHON_VERSION_MAJOR  3)
set(PYTHON_VERSION_MINOR  7)
set(PYTHON_VERSION_PATCH  3)
set(PYTHON_VERSION        ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}.${PYTHON_VERSION_PATCH})

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH TEMP_SOURCE_PATH
    REPO python/cpython
    REF v${PYTHON_VERSION}
    SHA512 023960a2f570fe7178d3901df0c3c33346466906b6d55c73ef7947c19619dbab62efc42c7262a0539bc5e31543b1113eb7a088d4615ad7557a0707bdaca27940
    HEAD_REF master
)

if (VCPKG_TARGET_IS_WINDOWS)
	set(SOURCE_PATH "${TEMP_SOURCE_PATH}-Lib-Win")
	file(REMOVE_RECURSE ${SOURCE_PATH})
	file(RENAME "${TEMP_SOURCE_PATH}" ${SOURCE_PATH})
	
	# We need per-triplet directories because we need to patch the project files differently based on the linkage
	# Because the patches patch the same file, they have to be applied in the correct order
	
	if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
		set(BUILD_ARCH "Win32")
		set(OUT_DIR "win32")
	elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
		set(BUILD_ARCH "x64")
		set(OUT_DIR "amd64")
	else()
		message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
	endif()

	vcpkg_build_msbuild(
		PROJECT_PATH ${SOURCE_PATH}/PCBuild/pythoncore.vcxproj
		PLATFORM ${BUILD_ARCH})

	file(GLOB HEADERS ${SOURCE_PATH}/Include/*.h)
	file(COPY ${HEADERS} ${SOURCE_PATH}/PC/pyconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR})
	file(COPY ${SOURCE_PATH}/Lib DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})
	file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

	if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
		file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
	endif()

	if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

		if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
			file(COPY ${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
		endif()

	endif()

	if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
		vcpkg_copy_pdbs()
	endif()
	# Handle copyright
	file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})
	file(RENAME ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/LICENSE ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/copyright)

elseif (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)

	if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
		set(SOURCE_PATH_DEBUG "${TEMP_SOURCE_PATH}-${TARGET_TRIPLET}-debug")
	endif()

	set(SOURCE_PATH_RELEASE "${TEMP_SOURCE_PATH}-${TARGET_TRIPLET}-release")
	file(REMOVE_RECURSE ${SOURCE_PATH_RELEASE})
	file(GLOB FILES ${TEMP_SOURCE_PATH}/*)
	file(COPY ${FILES} DESTINATION ${SOURCE_PATH_RELEASE})

	if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
		file(REMOVE_RECURSE ${SOURCE_PATH_DEBUG})
		file(RENAME "${TEMP_SOURCE_PATH}" ${SOURCE_PATH_DEBUG})
	endif()

	find_program(MAKE make)
	if (NOT MAKE)
		message(FATAL_ERROR "MAKE not found")
	endif()
	
	if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
		################
		# Release build
		################
		message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
		set(OUT_PATH_RELEASE ${SOURCE_PATH_RELEASE}/../../make-build-${TARGET_TRIPLET}-release)
		file(MAKE_DIRECTORY ${OUT_PATH_RELEASE})
		
		if(VCPKG_TARGET_IS_OSX)
			vcpkg_execute_build_process(
			  COMMAND "${SOURCE_PATH_RELEASE}/configure" --prefix=${OUT_PATH_RELEASE} --with-openssl=${CURRENT_INSTALLED_DIR} "CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include -framework CoreFoundation" "LDFLAGS=-L${CURRENT_INSTALLED_DIR}/lib" "LIBS=-liconv"
			  WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
			  LOGNAME config-${TARGET_TRIPLET}-rel
			)
		else()
			vcpkg_execute_build_process(
			  COMMAND "${SOURCE_PATH_RELEASE}/configure" --prefix=${OUT_PATH_RELEASE} --with-openssl=${CURRENT_INSTALLED_DIR} "CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include" "LDFLAGS=-L${CURRENT_INSTALLED_DIR}/lib"
			  WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
			  LOGNAME config-${TARGET_TRIPLET}-rel
			)
		endif()

		message(STATUS "Building ${TARGET_TRIPLET}-rel")

		vcpkg_execute_build_process(
		  COMMAND make -j ${VCPKG_CONCURRENCY}
		  NO_PARALLEL_COMMAND make
		  WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
		  LOGNAME make-build-${TARGET_TRIPLET}-release
		)
		
		message(STATUS "Installing ${TARGET_TRIPLET}-rel")
		vcpkg_execute_build_process(
		  COMMAND make install
		  WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
		  LOGNAME make-install-${TARGET_TRIPLET}-release
		)

		file(GLOB HEADERS ${OUT_PATH_RELEASE}/include/*)
		file(COPY ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
		file(GLOB LIBS ${OUT_PATH_RELEASE}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/*)
		file(COPY ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/Lib)
		file(GLOB LIBS ${OUT_PATH_RELEASE}/lib/pkgconfig/*)
		file(COPY ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})
		file(COPY ${OUT_PATH_RELEASE}/lib/libpython${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}m.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
		message(STATUS "Installing ${TARGET_TRIPLET}-rel done")

	endif()

	if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
		################
		# Debug build
		################
		message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
		set(OUT_PATH_DEBUG ${SOURCE_PATH_DEBUG}/../../make-build-${TARGET_TRIPLET}-debug)
		file(MAKE_DIRECTORY ${OUT_PATH_DEBUG})

		if(VCPKG_TARGET_IS_OSX)
			vcpkg_execute_build_process(
			  COMMAND "${SOURCE_PATH_DEBUG}/configure" --with-pydebug --prefix=${OUT_PATH_DEBUG} --with-openssl=${CURRENT_INSTALLED_DIR}/debug "CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include -framework CoreFoundation" "LDFLAGS=-L${CURRENT_INSTALLED_DIR}/debug/lib" "LIBS=-liconv"
			  WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
			  LOGNAME config-${TARGET_TRIPLET}-debug
			)
		else()
			vcpkg_execute_build_process(
			  COMMAND "${SOURCE_PATH_DEBUG}/configure" --with-pydebug --prefix=${OUT_PATH_DEBUG} --with-openssl=${CURRENT_INSTALLED_DIR}/debug "CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include" "LDFLAGS=-L${CURRENT_INSTALLED_DIR}/debug/lib"
			  WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
			  LOGNAME config-${TARGET_TRIPLET}-debug
			)
		endif()

		message(STATUS "Building ${TARGET_TRIPLET}-dbg")
		vcpkg_execute_build_process(
		  COMMAND make -j ${VCPKG_CONCURRENCY}
		  NO_PARALLEL_COMMAND make
		  WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
		  LOGNAME make-build-${TARGET_TRIPLET}-debug
		)
		
		message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
		vcpkg_execute_build_process(
		  COMMAND make install
		  WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
		  LOGNAME make-install-${TARGET_TRIPLET}-debug
		)

		file(COPY ${OUT_PATH_DEBUG}/lib/libpython${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}dm.a DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
		message(STATUS "Installing ${TARGET_TRIPLET}-dbg done")

	endif()
	# Handle copyright
	file(COPY ${SOURCE_PATH_RELEASE}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR})
	file(RENAME ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/LICENSE ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/copyright)

endif()
