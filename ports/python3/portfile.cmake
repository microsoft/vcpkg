if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic AND VCPKG_CRT_LINKAGE STREQUAL static)
    message(STATUS "Warning: Dynamic library with static CRT is not supported. Building static library.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(PYTHON_VERSION_MAJOR  3)
set(PYTHON_VERSION_MINOR  9)
set(PYTHON_VERSION_PATCH  0)
set(PYTHON_VERSION        ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}.${PYTHON_VERSION_PATCH})

if(VCPKG_TARGET_IS_WINDOWS)
	if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
		list(APPEND PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-static-library.patch)
	endif()
	if (VCPKG_CRT_LINKAGE STREQUAL static)
		list(APPEND PATCHES ${CMAKE_CURRENT_LIST_DIR}/0002-static-crt.patch)
	endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH TEMP_SOURCE_PATH
    REPO python/cpython
    REF v${PYTHON_VERSION}
    SHA512 39d304cae181674c4872c63768c0e5aeace2c92eb6d5ea550428d65c8571bc60922b3a3d484b51c46b466aadb7e27500559cafec13a489b48613bbb3fe6a5a5d
    HEAD_REF master
    PATCHES ${PATCHES}
)

if("enable-shared" IN_LIST FEATURES)
	set(_ENABLED_SHARED --enable-shared)
    if(VCPKG_TARGET_IS_LINUX)
        message(WARNING"Feature enable-shared requires libffi-devel from the system package manager, please install it on Ubuntu system via sudo apt-get install libffi-dev.")
    endif()
else()
	unset(_ENABLED_SHARED)
endif()

if (VCPKG_TARGET_IS_WINDOWS)
	if(DEFINED _ENABLED_SHARED)
		message(WARNING "enable-shared requested, by Windows build already produce a shared library by default")
	endif()
	set(SOURCE_PATH "${TEMP_SOURCE_PATH}-Lib-Win")
	file(REMOVE_RECURSE ${SOURCE_PATH})
	file(RENAME "${TEMP_SOURCE_PATH}" ${SOURCE_PATH})

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

	file(INSTALL
			"${SOURCE_PATH}/Include/"
			"${SOURCE_PATH}/PC/pyconfig.h"
		DESTINATION "${CURRENT_PACKAGES_DIR}/include/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}"
		FILES_MATCHING PATTERN *.h
	)
	file(INSTALL
			"${SOURCE_PATH}/Lib"
		DESTINATION
			"${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}"
	)
	file(INSTALL
			"${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.lib"
		DESTINATION
			"${CURRENT_PACKAGES_DIR}/lib"
	)

	if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
		file(INSTALL "${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
	endif()

	if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		file(INSTALL "${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}.dll" DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

		if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
			file(INSTALL "${SOURCE_PATH}/PCBuild/${OUT_DIR}/python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}_d.dll" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
		endif()
	endif()

	if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
		vcpkg_copy_pdbs()
	endif()
	# Handle copyright
	file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR} RENAME copyright)

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
				COMMAND
					"${SOURCE_PATH_RELEASE}/configure"
					${_ENABLED_SHARED}
					--prefix=${OUT_PATH_RELEASE}
					--with-openssl=${CURRENT_INSTALLED_DIR}
					"CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include -framework CoreFoundation" "LDFLAGS=-L${CURRENT_INSTALLED_DIR}/lib" "LIBS=-liconv"
				WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
				LOGNAME config-${TARGET_TRIPLET}-rel
			)
		else()
			vcpkg_execute_build_process(
				COMMAND
					"${SOURCE_PATH_RELEASE}/configure"
					${_ENABLED_SHARED}
					--prefix=${OUT_PATH_RELEASE}
					--with-openssl=${CURRENT_INSTALLED_DIR}
				"CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include" "LDFLAGS=-L${CURRENT_INSTALLED_DIR}/lib"
				WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
				LOGNAME config-${TARGET_TRIPLET}-rel
			)
		endif()

		message(STATUS "Building ${TARGET_TRIPLET}-rel")

		vcpkg_execute_build_process(
		  COMMAND make install -j ${VCPKG_CONCURRENCY}
		  NO_PARALLEL_COMMAND make install
		  WORKING_DIRECTORY ${SOURCE_PATH_RELEASE}
		  LOGNAME make-build-${TARGET_TRIPLET}-release
		)

		message(STATUS "Installing ${TARGET_TRIPLET}-rel headers...")
		file(INSTALL "${OUT_PATH_RELEASE}/include/"
			DESTINATION ${CURRENT_PACKAGES_DIR}/include
			FILES_MATCHING PATTERN *.h
		)

		message(STATUS "Installing ${TARGET_TRIPLET}-rel lib files...")
		file(GLOB PY_LIBS
			${OUT_PATH_RELEASE}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/*)
		file(INSTALL ${PY_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}/Lib
			PATTERN "*.pyc" EXCLUDE
			PATTERN "*__pycache__*" EXCLUDE
		)

		message(STATUS "Installing ${TARGET_TRIPLET}-rel share files...")
		file(GLOB PKGCFG ${OUT_PATH_RELEASE}/lib/pkgconfig/*)
		file(INSTALL ${PKGCFG} DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR}
			PATTERN "*.pyc" EXCLUDE
			PATTERN "*__pycache__*" EXCLUDE
		)

		message(STATUS "Installing ${TARGET_TRIPLET}-rel Python library files...")
		file(GLOB LIBS
			${OUT_PATH_RELEASE}/lib/libpython${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}.*)
        if (NOT LIBS)
            file(GLOB LIBS ${OUT_PATH_RELEASE}/lib64/*)
        endif()
		file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib
			PATTERN "*.pyc" EXCLUDE
			PATTERN "*__pycache__*" EXCLUDE
		)

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
				COMMAND
					"${SOURCE_PATH_DEBUG}/configure"
					--with-pydebug
					${_ENABLED_SHARED}
					--prefix=${OUT_PATH_DEBUG}
					--with-openssl=${CURRENT_INSTALLED_DIR}/debug
					"CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include -framework CoreFoundation" "LDFLAGS=-L${CURRENT_INSTALLED_DIR}/debug/lib" "LIBS=-liconv"
				WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
				LOGNAME config-${TARGET_TRIPLET}-debug
			)
		else()
			vcpkg_execute_build_process(
				COMMAND
					"${SOURCE_PATH_DEBUG}/configure"
					--with-pydebug
					${_ENABLED_SHARED}
					--prefix=${OUT_PATH_DEBUG}
					--with-openssl=${CURRENT_INSTALLED_DIR}/debug
					"CPPFLAGS=-I${CURRENT_INSTALLED_DIR}/include" "LDFLAGS=-L${CURRENT_INSTALLED_DIR}/debug/lib"
				WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
				LOGNAME config-${TARGET_TRIPLET}-debug
			)
		endif()

		message(STATUS "Building ${TARGET_TRIPLET}-dbg")
		vcpkg_execute_build_process(
		  COMMAND make install -j ${VCPKG_CONCURRENCY}
		  NO_PARALLEL_COMMAND make install
		  WORKING_DIRECTORY ${SOURCE_PATH_DEBUG}
		  LOGNAME make-build-${TARGET_TRIPLET}-debug
		)

		message(STATUS "Installing ${TARGET_TRIPLET}-dbg Python library files...")
		file(GLOB LIBS
			${OUT_PATH_DEBUG}/lib/libpython${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}d.*)
        if (NOT LIBS)
            file(GLOB LIBS
                ${OUT_PATH_DEBUG}/lib64/*)
        endif()
		file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
			PATTERN "*.pyc" EXCLUDE
			PATTERN "*__pycache__*" EXCLUDE
		)

		message(STATUS "Installing ${TARGET_TRIPLET}-dbg done")

	endif()
	# Handle copyright
	file(INSTALL ${SOURCE_PATH_RELEASE}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/python${PYTHON_VERSION_MAJOR} RENAME copyright)

endif()
