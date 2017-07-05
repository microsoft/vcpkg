include(vcpkg_common_functions)
set(VERSION 1_64)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/boost_${VERSION}_0)

######################
# Acquire and arrange sources
######################
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://sourceforge.net/projects/boost/files/boost/1.64.0/boost_${VERSION}_0.tar.bz2"
    FILENAME "boost_${VERSION}_0.tar.bz2"
    SHA512 68477f148f61be617552ef48559c5c2cb90d42264cabd6d5e87215d0d5024b48fca27c4afcfc1f77e490c6220d44fb1abdf0a53703867a2e4132c2857f69fedf
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

# apply boost range hotfix
vcpkg_download_distfile(DIFF
    URLS "https://github.com/boostorg/range/commit/e7ebe14707130cda7b72e0ae5e93b17157fdb6a2.diff"
    FILENAME "boost-range-has_range_iterator-hotfix_e7ebe14707130cda7b72e0ae5e93b17157fdb6a2-2.diff"
    SHA512 88392fcf092d07ee2de66d937634688eef1d7491a4e2fb0fce064b4e631813a0814455a329f9eed8b968ff205883751d51a86edecc8e355790fc8a35d6742483
)

FILE(READ "${DIFF}" content)
STRING(REGEX REPLACE "include/" "" content "${content}")
set(DIFF2 ${CURRENT_BUILDTREES_DIR}/src/boost-range-has_range_iterator-hotfix_e7ebe14707130cda7b72e0ae5e93b17157fdb6a2.diff.fixed)
FILE(WRITE ${DIFF2} "${content}")
vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH} PATCHES ${DIFF2})

######################
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
    ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

######################
# Bootstrap b2
######################
if(NOT EXISTS ${SOURCE_PATH}/b2.exe)
    message(STATUS "Bootstrapping")
    vcpkg_execute_required_process(
        COMMAND "${SOURCE_PATH}/bootstrap.bat"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME bootstrap
    )
endif()
message(STATUS "Bootstrapping done")

######################
# Generate configuration
######################
set(B2_OPTIONS
    -sZLIB_INCLUDE="${CURRENT_INSTALLED_DIR}\\include"
    -sBZIP2_INCLUDE="${CURRENT_INSTALLED_DIR}\\include"
    -j$ENV{NUMBER_OF_PROCESSORS}
    --debug-configuration
    --hash
    -q

    --without-python
    threading=multi
)

if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
    list(APPEND B2_OPTIONS runtime-link=shared)
else()
    list(APPEND B2_OPTIONS runtime-link=static)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND B2_OPTIONS link=shared)
else()
    list(APPEND B2_OPTIONS link=static)
endif()

if(TRIPLET_SYSTEM_ARCH MATCHES "x64")
    list(APPEND B2_OPTIONS address-model=64)
endif()

if(VCPKG_CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
    list(APPEND B2_OPTIONS
        windows-api=store
        # --without-atomic
        # --without-chrono
        # --without-system
        # --without-date_time
        # --without-exception
        # --without-serialization
        # --without-fiber
        # --without-context
        # --without-graph_parallel
        # --without-signals
        # --without-coroutine2
        # --without-graph
        # --without-math
        # --without-random
        # --without-regex
        ################################
        --without-type_erasure # depends on thread
        --without-log # depends on filesystem
        --without-mpi # Needs "using mpi ;"
        --without-wave # depends on filesystem
        --without-coroutine # depends on thread
        --without-metaparse # depends on test
        --without-locale # libs\locale\src\encoding\wconv_codepage.ipp(114): error C3861: 'IsDBCSLeadByteEx': identifier not found
        --without-timer # libs\timer\src\cpu_timer.cpp(126): error C2039: 'GetProcessTimes': is not a member of '`global namespace''
        --without-program_options # libs\program_options\src\parsers.cpp(194): error C2065: 'environ': undeclared identifier

        --without-test
        --without-filesystem # libs\filesystem\src\operations.cpp(178): error C2039: 'GetEnvironmentVariableW': is not a member of '`global namespace''
        --without-thread
        --without-iostreams
        --without-container
    )
    if(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
        find_path(PATH_TO_CL cl.exe)
        find_path(PLATFORM_WINMD_DIR platform.winmd PATHS "${PATH_TO_CL}/../../../lib/x86/store/references" NO_DEFAULT_PATH)
        if(PLATFORM_WINMD_DIR MATCHES "NOTFOUND")
            message(FATAL_ERROR "Could not find `platform.winmd` in VS2017. Do you have the Universal Windows Platform development workload installed?")
        endif()
    else()
        find_path(PLATFORM_WINMD_DIR platform.winmd PATHS "$ENV{VS140COMNTOOLS}/../../VC/LIB/store/references")
        if(PLATFORM_WINMD_DIR MATCHES "NOTFOUND")
            message(FATAL_ERROR "Could not find `platform.winmd` in VS2015.")
        endif()
    endif()
    file(TO_NATIVE_PATH "${PLATFORM_WINMD_DIR}" PLATFORM_WINMD_DIR)
    string(REPLACE "\\" "\\\\" PLATFORM_WINMD_DIR ${PLATFORM_WINMD_DIR}) # escape backslashes
    configure_file(${CMAKE_CURRENT_LIST_DIR}/uwp/user-config.jam ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/user-config.jam ESCAPE_QUOTES @ONLY)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/uwp/user-config.jam ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/user-config.jam ESCAPE_QUOTES @ONLY)
else()
    configure_file(${CMAKE_CURRENT_LIST_DIR}/desktop/user-config.jam ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/user-config.jam @ONLY)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/desktop/user-config.jam ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/user-config.jam @ONLY)
endif()

if(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
    list(APPEND B2_OPTIONS toolset=msvc-14.1)
elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v140")
    list(APPEND B2_OPTIONS toolset=msvc-14.0)
else()
    message(FATAL_ERROR "Unsupported value for VCPKG_PLATFORM_TOOLSET: '${VCPKG_PLATFORM_TOOLSET}'")
endif()

# Add build type specific options
set(B2_OPTIONS_DBG
    ${B2_OPTIONS}
    -sZLIB_BINARY=zlibd
    -sZLIB_LIBPATH="${CURRENT_INSTALLED_DIR}\\debug\\lib"
    -sBZIP2_BINARY=bz2d
    -sBZIP2_LIBPATH="${CURRENT_INSTALLED_DIR}\\debug\\lib"
)

set(B2_OPTIONS_REL
    ${B2_OPTIONS}
    -sZLIB_BINARY=zlib
    -sZLIB_LIBPATH="${CURRENT_INSTALLED_DIR}\\lib"
    -sBZIP2_BINARY=bz2
    -sBZIP2_LIBPATH="${CURRENT_INSTALLED_DIR}\\lib"
)

######################
# Perform build + Package
######################
message(STATUS "Building ${TARGET_TRIPLET}-rel")
set(ENV{BOOST_BUILD_PATH} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
vcpkg_execute_required_process_repeat(
    COUNT 2
    COMMAND "${SOURCE_PATH}/b2.exe"
        --stagedir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/stage
        --build-dir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        ${B2_OPTIONS_REL}
        variant=release
        debug-symbols=on
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-rel
)
message(STATUS "Building ${TARGET_TRIPLET}-rel done")
message(STATUS "Building ${TARGET_TRIPLET}-dbg")
set(ENV{BOOST_BUILD_PATH} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
vcpkg_execute_required_process_repeat(
    COUNT 2
    COMMAND "${SOURCE_PATH}/b2.exe"
        --stagedir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/stage
        --build-dir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        ${B2_OPTIONS_DBG}
        variant=debug
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-dbg
)
message(STATUS "Building ${TARGET_TRIPLET}-dbg done")

message(STATUS "Packaging headers")
file(
    COPY ${SOURCE_PATH}/boost
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Disable Boost auto-link.
file(APPEND ${CURRENT_PACKAGES_DIR}/include/boost/config/user.hpp
	"\n#define BOOST_ALL_NO_LIB\n"
)
file(APPEND ${CURRENT_PACKAGES_DIR}/include/boost/config/user.hpp
    "\n#undef BOOST_ALL_DYN_LINK\n"
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(APPEND ${CURRENT_PACKAGES_DIR}/include/boost/config/user.hpp
        "\n#define BOOST_ALL_DYN_LINK\n"
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/boost RENAME copyright)
message(STATUS "Packaging headers done")

function(boost_rename_libs LIBS)
    foreach(LIB ${${LIBS}})
        get_filename_component(OLD_FILENAME ${LIB} NAME)
        get_filename_component(DIRECTORY_OF_LIB_FILE ${LIB} DIRECTORY)
        string(REPLACE "-vc141-" "-vc140-" NEW_FILENAME ${OLD_FILENAME}) # To merge VS2017 and VS2015 binaries
        if ("${DIRECTORY_OF_LIB_FILE}/${NEW_FILENAME}" STREQUAL "${DIRECTORY_OF_LIB_FILE}/${OLD_FILENAME}")
            # nothing to do
        elseif (EXISTS ${DIRECTORY_OF_LIB_FILE}/${NEW_FILENAME})
            file(REMOVE ${DIRECTORY_OF_LIB_FILE}/${OLD_FILENAME})
        else()
            file(RENAME ${DIRECTORY_OF_LIB_FILE}/${OLD_FILENAME} ${DIRECTORY_OF_LIB_FILE}/${NEW_FILENAME})
        endif()
    endforeach()
endfunction()

function (boost_move_manual_link LIBS)
    foreach(LIB ${${LIBS}})
        get_filename_component(MANUAL_LINK_LIB_FILENAME ${LIB} NAME)
        get_filename_component(DIRECTORY_OF_LIB_FILE ${LIB} DIRECTORY)
        file(MAKE_DIRECTORY ${DIRECTORY_OF_LIB_FILE}/manual-link)
        file(RENAME ${DIRECTORY_OF_LIB_FILE}/${MANUAL_LINK_LIB_FILENAME} ${DIRECTORY_OF_LIB_FILE}/manual-link/${MANUAL_LINK_LIB_FILENAME})
    endforeach()
endfunction()

message(STATUS "Packaging ${TARGET_TRIPLET}-rel")
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/stage/lib/
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    FILES_MATCHING PATTERN "*.lib")
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/stage/lib/
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
        FILES_MATCHING PATTERN "*.dll")
endif()
file(GLOB RELEASE_LIBS ${CURRENT_PACKAGES_DIR}/lib/*.lib)
boost_rename_libs(RELEASE_LIBS)
file(GLOB RELEASE_MANUAL_LINK_LIBS ${CURRENT_PACKAGES_DIR}/lib/libboost*.lib)
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    boost_move_manual_link(RELEASE_MANUAL_LINK_LIBS)
endif()
message(STATUS "Packaging ${TARGET_TRIPLET}-rel done")

message(STATUS "Packaging ${TARGET_TRIPLET}-dbg")
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/stage/lib/
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    FILES_MATCHING PATTERN "*.lib")
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/stage/lib/
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
        FILES_MATCHING PATTERN "*.dll")
endif()
file(GLOB DEBUG_LIBS ${CURRENT_PACKAGES_DIR}/debug/lib/*.lib)
boost_rename_libs(DEBUG_LIBS)
file(GLOB DEBUG_MANUAL_LINK_LIBS ${CURRENT_PACKAGES_DIR}/debug/lib/libboost*.lib)
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    boost_move_manual_link(DEBUG_MANUAL_LINK_LIBS)
endif()
message(STATUS "Packaging ${TARGET_TRIPLET}-dbg done")

vcpkg_copy_pdbs()
