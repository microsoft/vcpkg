get_filename_component(BOOST_BUILD_INSTALLED_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
get_filename_component(BOOST_BUILD_INSTALLED_DIR "${BOOST_BUILD_INSTALLED_DIR}" DIRECTORY)

function(boost_modular_build)
    cmake_parse_arguments(_bm "" "SOURCE_PATH;BOOST_CMAKE_FRAGMENT" "" ${ARGN})

    if(NOT DEFINED _bm_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH is a required argument to boost_modular_build.")
    endif()

    # Next CMake variables may be overridden in the file specified in ${_bm_BOOST_CMAKE_FRAGMENT}
    set(B2_OPTIONS)
    set(B2_OPTIONS_DBG)
    set(B2_OPTIONS_REL)
    set(B2_REQUIREMENTS) # this variable is used in the Jamroot.jam

    if(DEFINED _bm_BOOST_CMAKE_FRAGMENT)
        message(STATUS "Including ${_bm_BOOST_CMAKE_FRAGMENT}")
        include(${_bm_BOOST_CMAKE_FRAGMENT})
    endif()

    set(BOOST_BUILD_PATH "${BOOST_BUILD_INSTALLED_DIR}/tools/boost-build")

    if(EXISTS "${BOOST_BUILD_PATH}/b2.exe")
        set(B2_EXE "${BOOST_BUILD_PATH}/b2.exe")
    elseif(EXISTS "${BOOST_BUILD_PATH}/b2")
        set(B2_EXE "${BOOST_BUILD_PATH}/b2")
    else()
        message(FATAL_ERROR "Could not find b2 in ${BOOST_BUILD_PATH}")
    endif()

    if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        list(APPEND B2_OPTIONS windows-api=store)
    endif()

    set(_bm_DIR ${BOOST_BUILD_INSTALLED_DIR}/share/boost-build)

    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(BOOST_LIB_PREFIX)
	if(VCPKG_PLATFORM_TOOLSET MATCHES "v14.")
	    set(BOOST_LIB_RELEASE_SUFFIX -vc140-mt.lib)
	    set(BOOST_LIB_DEBUG_SUFFIX -vc140-mt-gd.lib)
	elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v120")
	    set(BOOST_LIB_RELEASE_SUFFIX -vc120-mt.lib)
	    set(BOOST_LIB_DEBUG_SUFFIX -vc120-mt-gd.lib)
	endif()
    else()
        set(BOOST_LIB_PREFIX lib)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            set(BOOST_LIB_RELEASE_SUFFIX .a)
            set(BOOST_LIB_DEBUG_SUFFIX .a)
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            set(BOOST_LIB_RELEASE_SUFFIX .dylib)
            set(BOOST_LIB_DEBUG_SUFFIX .dylib)
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MinGW")
            set(BOOST_LIB_RELEASE_SUFFIX .dll.a)
            set(BOOST_LIB_DEBUG_SUFFIX .dll.a)
        else()
            set(BOOST_LIB_RELEASE_SUFFIX .so)
            set(BOOST_LIB_DEBUG_SUFFIX .so)
        endif()
    endif()

    if(EXISTS "${_bm_SOURCE_PATH}/build/Jamfile.v2")
        file(READ ${_bm_SOURCE_PATH}/build/Jamfile.v2 _contents)
        string(REGEX REPLACE
            "\.\./\.\./([^/ ]+)/build//(boost_[^/ ]+)"
            "/boost/\\1//\\2"
            _contents
            "${_contents}"
        )
        string(REGEX REPLACE " /boost//([^/ ]+)" " /boost/\\1//boost_\\1" _contents "${_contents}")
        file(WRITE ${_bm_SOURCE_PATH}/build/Jamfile.v2 "${_contents}")
    endif()

    function(unix_build BOOST_LIB_SUFFIX BUILD_TYPE BUILD_LIB_PATH)
        message(STATUS "Building ${BUILD_TYPE}...")
        set(BOOST_LIB_SUFFIX ${BOOST_LIB_SUFFIX})
        set(VARIANT ${BUILD_TYPE})
        set(BUILD_LIB_PATH ${BUILD_LIB_PATH})
        configure_file(${_bm_DIR}/Jamroot.jam ${_bm_SOURCE_PATH}/Jamroot.jam @ONLY)

        set(configure_option)
        if(DEFINED _bm_BOOST_CMAKE_FRAGMENT)
            list(APPEND configure_option "-DBOOST_CMAKE_FRAGMENT=${_bm_BOOST_CMAKE_FRAGMENT}")
        endif()

        vcpkg_configure_cmake(
            SOURCE_PATH ${BOOST_BUILD_INSTALLED_DIR}/share/boost-build
            PREFER_NINJA
            OPTIONS
                "-DPORT=${PORT}"
                "-DFEATURES=${FEATURES}"
                "-DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}"
                "-DB2_EXE=${B2_EXE}"
                "-DSOURCE_PATH=${_bm_SOURCE_PATH}"
                "-DBOOST_BUILD_PATH=${BOOST_BUILD_PATH}"
                ${configure_option}
        )
        vcpkg_install_cmake()
    endfunction()

    if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(build_flag 0)
        if(NOT DEFINED VCPKG_BUILD_TYPE)
            set(build_flag 1)
            set(VCPKG_BUILD_TYPE "release")
        endif()

        if(VCPKG_BUILD_TYPE STREQUAL "release")
            unix_build(${BOOST_LIB_RELEASE_SUFFIX} "release" "lib/")
        endif()

        if(build_flag)
            set(VCPKG_BUILD_TYPE "debug")
        endif()

        if(VCPKG_BUILD_TYPE STREQUAL "debug")
            unix_build(${BOOST_LIB_DEBUG_SUFFIX} "debug" "debug/lib/")
        endif()

        if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/lib)
            message(FATAL_ERROR "No libraries were produced. This indicates a failure while building the boost library.")
        endif()

        configure_file(${BOOST_BUILD_INSTALLED_DIR}/share/boost-build/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage COPYONLY)
        return()
    endif()

    #####################
    # Cleanup previous builds
    ######################
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        # It is possible for a file in this folder to be locked due to antivirus or vctip
        execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 1)
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
            message(FATAL_ERROR "Unable to remove directory: ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel\n  Files are likely in use.")
        endif()
    endif()

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        # It is possible for a file in this folder to be locked due to antivirus or vctip
        execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 1)
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
            message(FATAL_ERROR "Unable to remove directory: ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg\n  Files are likely in use.")
        endif()
    endif()

    if(EXISTS ${CURRENT_PACKAGES_DIR}/debug)
        message(FATAL_ERROR "Error: directory exists: ${CURRENT_PACKAGES_DIR}/debug\n  The previous package was not fully cleared. This is an internal error.")
    endif()
    file(MAKE_DIRECTORY
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    )

    include(ProcessorCount)
    ProcessorCount(NUMBER_OF_PROCESSORS)
    if(NOT NUMBER_OF_PROCESSORS)
        set(NUMBER_OF_PROCESSORS 1)
    endif()

    ######################
    # Generate configuration
    ######################
    list(APPEND B2_OPTIONS
        -j${NUMBER_OF_PROCESSORS}
        --debug-configuration
        --debug-building
        --debug-generators
        --disable-icu
        --ignore-site-config
        --hash
        -q
        "-sZLIB_INCLUDE=${CURRENT_INSTALLED_DIR}/include"
        "-sBZIP2_INCLUDE=${CURRENT_INSTALLED_DIR}/include"
        "-sLZMA_INCLUDE=${CURRENT_INSTALLED_DIR}/include"
        "-sZSTD_INCLUDE=${CURRENT_INSTALLED_DIR}/include"
        threading=multi
    )
    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        list(APPEND B2_OPTIONS threadapi=win32)
    else()
        list(APPEND B2_OPTIONS threadapi=pthread)
    endif()
    list(APPEND B2_OPTIONS_DBG
         -sZLIB_BINARY=zlibd
         "-sZLIB_LIBPATH=${CURRENT_INSTALLED_DIR}/debug/lib"
         -sBZIP2_BINARY=bz2d
         "-sBZIP2_LIBPATH=${CURRENT_INSTALLED_DIR}/debug/lib"
         -sLZMA_BINARY=lzmad
         "-sLZMA_LIBPATH=${CURRENT_INSTALLED_DIR}/debug/lib"
         -sZSTD_BINARY=zstdd
         "-sZSTD_LIBPATH=${CURRENT_INSTALLED_DIR}/debug/lib"
    )

    list(APPEND B2_OPTIONS_REL
         -sZLIB_BINARY=zlib
         "-sZLIB_LIBPATH=${CURRENT_INSTALLED_DIR}/lib"
         -sBZIP2_BINARY=bz2
         "-sBZIP2_LIBPATH=${CURRENT_INSTALLED_DIR}/lib"
         -sLZMA_BINARY=lzma
         "-sLZMA_LIBPATH=${CURRENT_INSTALLED_DIR}/lib"
         -sZSTD_BINARY=zstd
         "-sZSTD_LIBPATH=${CURRENT_INSTALLED_DIR}/lib"
    )

    # Properly handle compiler and linker flags passed by VCPKG
    if(VCPKG_CXX_FLAGS)
        list(APPEND B2_OPTIONS "cxxflags=${VCPKG_CXX_FLAGS}")
    endif()

    if(VCPKG_CXX_FLAGS_RELEASE)
        list(APPEND B2_OPTIONS_REL "cxxflags=${VCPKG_CXX_FLAGS_RELEASE}")
    endif()

    if(VCPKG_CXX_FLAGS_DEBUG)
        list(APPEND B2_OPTIONS_DBG "cxxflags=${VCPKG_CXX_FLAGS_DEBUG}")
    endif()

    if(VCPKG_C_FLAGS)
        list(APPEND B2_OPTIONS "cflags=${VCPKG_C_FLAGS}")
    endif()

    if(VCPKG_C_FLAGS_RELEASE)
        list(APPEND B2_OPTIONS_REL "cflags=${VCPKG_C_FLAGS_RELEASE}")
    endif()

    if(VCPKG_C_FLAGS_DEBUG)
        list(APPEND B2_OPTIONS_DBG "cflags=${VCPKG_C_FLAGS_DEBUG}")
    endif()

    if(VCPKG_LINKER_FLAGS)
        list(APPEND B2_OPTIONS "linkflags=${VCPKG_LINKER_FLAGS}")
    endif()

    if(VCPKG_LINKER_FLAGS_RELEASE)
        list(APPEND B2_OPTIONS_REL "linkflags=${VCPKG_LINKER_FLAGS_RELEASE}")
    endif()

    if(VCPKG_LINKER_FLAGS_DEBUG)
        list(APPEND B2_OPTIONS_DBG "linkflags=${VCPKG_LINKER_FLAGS_DEBUG}")
    endif()

    # Add build type specific options
    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        list(APPEND B2_OPTIONS runtime-link=shared)
    else()
        list(APPEND B2_OPTIONS runtime-link=static)
    endif()

    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND B2_OPTIONS link=shared)
    else()
        list(APPEND B2_OPTIONS link=static)
    endif()

    if(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        list(APPEND B2_OPTIONS address-model=64 architecture=x86)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        list(APPEND B2_OPTIONS address-model=32 architecture=arm)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        list(APPEND B2_OPTIONS address-model=64 architecture=arm)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "s390x")
        list(APPEND B2_OPTIONS address-model=64 architecture=s390x)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "ppc64le")
        list(APPEND B2_OPTIONS address-model=64 architecture=power)
    else()
        list(APPEND B2_OPTIONS address-model=32 architecture=x86)

        if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
            list(APPEND B2_OPTIONS "asmflags=/safeseh")
        endif()

    endif()

    file(TO_CMAKE_PATH "${_bm_DIR}/nothing.bat" NOTHING_BAT)
    set(TOOLSET_OPTIONS "<cxxflags>/EHsc <compileflags>-Zm800 <compileflags>-nologo")
    if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        if(NOT VCPKG_PLATFORM_TOOLSET MATCHES "v140")
            find_path(PATH_TO_CL cl.exe)
            find_path(PLATFORM_WINMD_DIR platform.winmd PATHS "${PATH_TO_CL}/../../../lib/x86/store/references" NO_DEFAULT_PATH)
            if(PLATFORM_WINMD_DIR MATCHES "NOTFOUND")
                message(FATAL_ERROR "Could not find `platform.winmd` in VS. Do you have the Universal Windows Platform development workload installed?")
            endif()
        else()
            find_path(PLATFORM_WINMD_DIR platform.winmd PATHS "$ENV{VS140COMNTOOLS}/../../VC/LIB/store/references")
            if(PLATFORM_WINMD_DIR MATCHES "NOTFOUND")
                message(FATAL_ERROR "Could not find `platform.winmd` in VS2015.")
            endif()
        endif()
        file(TO_NATIVE_PATH "${PLATFORM_WINMD_DIR}" PLATFORM_WINMD_DIR)
        string(REPLACE "\\" "/" PLATFORM_WINMD_DIR ${PLATFORM_WINMD_DIR}) # escape backslashes

        set(TOOLSET_OPTIONS "${TOOLSET_OPTIONS} <cflags>-Zl <compileflags> /AI\"${PLATFORM_WINMD_DIR}\" <linkflags>WindowsApp.lib <cxxflags>/ZW <compileflags>-DVirtualAlloc=VirtualAllocFromApp <compileflags>-D_WIN32_WINNT=0x0A00")
    endif()

    set(MSVC_VERSION)
    if(VCPKG_PLATFORM_TOOLSET MATCHES "v142")
        list(APPEND _bm_OPTIONS toolset=msvc)
        set(MSVC_VERSION 14.2)
    elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
        list(APPEND _bm_OPTIONS toolset=msvc)
        set(MSVC_VERSION 14.1)
    elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v140")
        list(APPEND _bm_OPTIONS toolset=msvc)
        set(MSVC_VERSION 14.0)
    elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v120")
        list(APPEND _bm_OPTIONS toolset=msvc)
    elseif(VCPKG_PLATFORM_TOOLSET MATCHES "external")
        list(APPEND B2_OPTIONS toolset=gcc)
    else()
        message(FATAL_ERROR "Unsupported value for VCPKG_PLATFORM_TOOLSET: '${VCPKG_PLATFORM_TOOLSET}'")
    endif()

    configure_file(${_bm_DIR}/user-config.jam ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/user-config.jam @ONLY)
    configure_file(${_bm_DIR}/user-config.jam ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/user-config.jam @ONLY)

    ######################
    # Perform build + Package
    ######################
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Building ${TARGET_TRIPLET}-rel")
        set(BOOST_LIB_SUFFIX ${BOOST_LIB_RELEASE_SUFFIX})
        set(VARIANT "release")
        set(BUILD_LIB_PATH "lib/")
        configure_file(${_bm_DIR}/Jamroot.jam ${_bm_SOURCE_PATH}/Jamroot.jam @ONLY)
        set(ENV{BOOST_BUILD_PATH} "${BOOST_BUILD_PATH}")
        vcpkg_execute_required_process(
            COMMAND "${B2_EXE}"
                --stagedir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/stage
                --build-dir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
                --user-config=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/user-config.jam
                ${B2_OPTIONS}
                ${B2_OPTIONS_REL}
                variant=release
                debug-symbols=on
            WORKING_DIRECTORY ${_bm_SOURCE_PATH}/build
            LOGNAME build-${TARGET_TRIPLET}-rel
        )
        message(STATUS "Building ${TARGET_TRIPLET}-rel done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Building ${TARGET_TRIPLET}-dbg")
        set(BOOST_LIB_SUFFIX ${BOOST_LIB_DEBUG_SUFFIX})
        set(VARIANT debug)
        set(BUILD_LIB_PATH "debug/lib/")
        configure_file(${_bm_DIR}/Jamroot.jam ${_bm_SOURCE_PATH}/Jamroot.jam @ONLY)
        set(ENV{BOOST_BUILD_PATH} "${BOOST_BUILD_PATH}")
        vcpkg_execute_required_process(
            COMMAND "${B2_EXE}"
                --stagedir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/stage
                --build-dir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
                --user-config=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/user-config.jam
                ${B2_OPTIONS}
                ${B2_OPTIONS_DBG}
                variant=debug
            WORKING_DIRECTORY ${_bm_SOURCE_PATH}/build
            LOGNAME build-${TARGET_TRIPLET}-dbg
        )
        message(STATUS "Building ${TARGET_TRIPLET}-dbg done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        message(STATUS "Packaging ${TARGET_TRIPLET}-rel")
        file(GLOB REL_LIBS
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/boost/build/*/*.lib
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/boost/build/*/*.a
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/boost/build/*/*.so
        )
        file(COPY ${REL_LIBS}
            DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
        if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            file(GLOB REL_DLLS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/boost/build/*/*.dll)
            file(COPY ${REL_DLLS}
                DESTINATION ${CURRENT_PACKAGES_DIR}/bin
                FILES_MATCHING PATTERN "*.dll")
        endif()
        message(STATUS "Packaging ${TARGET_TRIPLET}-rel done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Packaging ${TARGET_TRIPLET}-dbg")
        file(GLOB DBG_LIBS
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/boost/build/*/*.lib
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/boost/build/*/*.a
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/boost/build/*/*.so
        )
        file(COPY ${DBG_LIBS}
            DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
        if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
            file(GLOB DBG_DLLS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/boost/build/*/*.dll)
            file(COPY ${DBG_DLLS}
                DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
                FILES_MATCHING PATTERN "*.dll")
        endif()
        message(STATUS "Packaging ${TARGET_TRIPLET}-dbg done")
    endif()

    file(GLOB INSTALLED_LIBS ${CURRENT_PACKAGES_DIR}/debug/lib/*.lib ${CURRENT_PACKAGES_DIR}/lib/*.lib)
    foreach(LIB ${INSTALLED_LIBS})
        get_filename_component(OLD_FILENAME ${LIB} NAME)
        get_filename_component(DIRECTORY_OF_LIB_FILE ${LIB} DIRECTORY)
        string(REPLACE "libboost_" "boost_" NEW_FILENAME ${OLD_FILENAME})
        string(REPLACE "-s-" "-" NEW_FILENAME ${NEW_FILENAME}) # For Release libs
        string(REPLACE "-vc141-" "-vc140-" NEW_FILENAME ${NEW_FILENAME}) # To merge VS2017 and VS2015 binaries
        string(REPLACE "-vc142-" "-vc140-" NEW_FILENAME ${NEW_FILENAME}) # To merge VS2019 and VS2015 binaries
        string(REPLACE "-sgd-" "-gd-" NEW_FILENAME ${NEW_FILENAME}) # For Debug libs
        string(REPLACE "-sgyd-" "-gyd-" NEW_FILENAME ${NEW_FILENAME}) # For Debug libs
        string(REPLACE "-x32-" "-" NEW_FILENAME ${NEW_FILENAME}) # To enable CMake 3.10 and earlier to locate the binaries
        string(REPLACE "-x64-" "-" NEW_FILENAME ${NEW_FILENAME}) # To enable CMake 3.10 and earlier to locate the binaries
        string(REPLACE "-a32-" "-" NEW_FILENAME ${NEW_FILENAME}) # To enable CMake 3.10 and earlier to locate the binaries
        string(REPLACE "-a64-" "-" NEW_FILENAME ${NEW_FILENAME}) # To enable CMake 3.10 and earlier to locate the binaries
        string(REPLACE "-1_76" "" NEW_FILENAME ${NEW_FILENAME}) # To enable CMake > 3.10 to locate the binaries
        if("${DIRECTORY_OF_LIB_FILE}/${NEW_FILENAME}" STREQUAL "${DIRECTORY_OF_LIB_FILE}/${OLD_FILENAME}")
            # nothing to do
        elseif(EXISTS ${DIRECTORY_OF_LIB_FILE}/${NEW_FILENAME})
            file(REMOVE ${DIRECTORY_OF_LIB_FILE}/${OLD_FILENAME})
        else()
            file(RENAME ${DIRECTORY_OF_LIB_FILE}/${OLD_FILENAME} ${DIRECTORY_OF_LIB_FILE}/${NEW_FILENAME})
        endif()
    endforeach()

    # boost-regex[icu] and boost-locale[icu] generate has_icu.lib
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/has_icu.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/has_icu.lib")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/has_icu.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/has_icu.lib")
    endif()

    vcpkg_copy_pdbs()
    configure_file(${BOOST_BUILD_INSTALLED_DIR}/share/boost-build/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage COPYONLY)
endfunction()
