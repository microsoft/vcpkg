cmake_minimum_required(VERSION 3.9)
project(boost NONE)

# The following variables are used in user-config.jam file
set(USER_CONFIG_TOOLSET "")
set(USER_CONFIG_TOOLSET_VERSION "")
set(USER_CONFIG_TOOLSET_INVOCATION_COMMAND "")
set(USER_CONFIG_TOOLSET_OPTIONS "")
set(USER_CONFIG_EXTRA_LINES "")
set(USER_CONFIG_REQUIREMENTS "")

set(B2_OPTIONS)

include("${VCPKG_CMAKE_VARS_FILE}")

# Add build type specific options
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    list(APPEND B2_OPTIONS runtime-link=shared)
else()
    list(APPEND B2_OPTIONS runtime-link=static)
endif()

if(BUILD_SHARED_LIBS)
    list(APPEND B2_OPTIONS link=shared)
else()
    list(APPEND B2_OPTIONS link=static)
endif()

if(VCPKG_DETECTED_CMAKE_SIZEOF_VOID_P EQUAL "8")
    list(APPEND B2_OPTIONS address-model=64)
else()
    list(APPEND B2_OPTIONS address-model=32)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "s390x")
    list(APPEND B2_OPTIONS architecture=s390x)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    list(APPEND B2_OPTIONS architecture=arm)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "ppc64le")
    list(APPEND B2_OPTIONS architecture=power)
elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "loongarch")
    list(APPEND B2_OPTIONS architecture=loongarch)
elseif("arm64" IN_LIST VCPKG_TARGET_ARCHITECTURE AND "x86_64" IN_LIST VCPKG_TARGET_ARCHITECTURE)
    list(APPEND B2_OPTIONS architecture=arm+x86)
else()
    list(APPEND B2_OPTIONS architecture=x86)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND WIN32)
    list(APPEND B2_OPTIONS "asmflags=/safeseh")
endif()

if(VCPKG_DETECTED_MSVC)
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        set(USER_CONFIG_TOOLSET clang-win)
    else()
        set(USER_CONFIG_TOOLSET msvc)
    endif()
    if(VCPKG_DETECTED_MSVC_VERSION LESS "1900")
        math(EXPR USER_CONFIG_TOOLSET_VERSION "${VCPKG_DETECTED_MSVC_VERSION} / 10 - 60")
    else()
        math(EXPR USER_CONFIG_TOOLSET_VERSION "${VCPKG_DETECTED_MSVC_VERSION} / 10 - 50")
    endif()
elseif(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(USER_CONFIG_TOOLSET clang)
else()
    set(USER_CONFIG_TOOLSET gcc)
endif()

if(WIN32)
    list(APPEND B2_OPTIONS target-os=windows)
elseif(APPLE)
    if(IOS)
        list(APPEND B2_OPTIONS target-os=iphone)
    else()
        list(APPEND B2_OPTIONS target-os=darwin)
    endif()
elseif(ANDROID)
    list(APPEND B2_OPTIONS target-os=android)
else()
    list(APPEND B2_OPTIONS target-os=linux)
endif()

# Properly handle compiler and linker flags passed by VCPKG
string(TOUPPER "${CMAKE_BUILD_TYPE}" UPPER_BUILD_TYPE)

set(CXXFLAGS "${VCPKG_COMBINED_CXX_FLAGS_${UPPER_BUILD_TYPE}}")
set(CFLAGS "${VCPKG_COMBINED_C_FLAGS_${UPPER_BUILD_TYPE}}")
set(LDFLAGS "${VCPKG_COMBINED_SHARED_LINKER_FLAGS_${UPPER_BUILD_TYPE}}")
set(ARFLAGS "${VCPKG_COMBINED_STATIC_LINKER_FLAGS_${UPPER_BUILD_TYPE}}")

if(APPLE)
    string(APPEND COMPILEFLAGS " -D_DARWIN_C_SOURCE")
    if(NOT CXXFLAGS MATCHES " -std=")
        # If the user hasn't provided their own standard flag, use at least c++11
        string(APPEND CXXFLAGS " -std=c++11")
    endif()
endif()

if(VCPKG_DETECTED_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    # cl in b2 appears to not receive `LIBPATH` for finding winmd files, so we transform them to `/AI` options.
    set(libpath_args "$ENV{LIBPATH}")
    # Apply: {x -> /AI"x"}
    list(TRANSFORM libpath_args PREPEND "/AI\"")
    list(TRANSFORM libpath_args APPEND "\"")
    list(JOIN libpath_args " " libpath_arg)
    string(APPEND COMPILEFLAGS " ${libpath_arg} /D_WIN32_WINNT=0x0A00")
    list(APPEND B2_OPTIONS windows-api=store)
    list(APPEND B2_OPTIONS linkflags=WindowsApp.lib)
endif()

set(USER_CONFIG_TOOLSET_INVOCATION_COMMAND "\"${VCPKG_DETECTED_CMAKE_CXX_COMPILER}\"")

string(APPEND CXXFLAGS "${COMPILEFLAGS}")
string(APPEND CFLAGS "${COMPILEFLAGS}")

foreach(var CXXFLAGS CFLAGS LDFLAGS ARFLAGS)
    string(REPLACE [[\]] [[\\]] ${var} "${${var}}")
    string(REPLACE [["]] [[\"]] ${var} "${${var}}")
    string(REGEX REPLACE "[ \t\r\n]+" " " ${var} "${${var}}")
    string(STRIP "${${var}}" ${var})
endforeach()

if(USER_CONFIG_TOOLSET STREQUAL "msvc")
    file(TO_CMAKE_PATH "${CMAKE_CURRENT_LIST_DIR}/nothing.bat" NOTHING_BAT)
    string(APPEND USER_CONFIG_TOOLSET_OPTIONS
        "    <setup>\"${NOTHING_BAT}\"\n"
    )
    if(NOT ARFLAGS STREQUAL "")
        # Only apply these flags for MSVC
        string(APPEND USER_CONFIG_REQUIREMENTS "<archiveflags>\"${ARFLAGS}\"\n    ")
    endif()
else()
    string(APPEND USER_CONFIG_TOOLSET_OPTIONS
        "    <ranlib>\"${VCPKG_DETECTED_CMAKE_RANLIB}\"\n"
        "    <archiver>\"${VCPKG_DETECTED_CMAKE_AR}\"\n"
    )
endif()

if(NOT CXXFLAGS STREQUAL "")
    string(APPEND USER_CONFIG_TOOLSET_OPTIONS "    <cxxflags>\"${CXXFLAGS}\"\n")
endif()
if(NOT CFLAGS STREQUAL "")
    string(APPEND USER_CONFIG_TOOLSET_OPTIONS "    <cflags>\"${CFLAGS}\"\n    <asmflags>\"${CFLAGS}\"\n")
endif()
if(NOT LDFLAGS STREQUAL "")
    string(APPEND USER_CONFIG_REQUIREMENTS "<linkflags>\"${LDFLAGS}\"\n    ")
    string(APPEND USER_CONFIG_TOOLSET_OPTIONS "    <linkflags>\"${LDFLAGS}\"\n")
endif()

if(WIN32 AND NOT USER_CONFIG_TOOLSET STREQUAL "msvc")
    # MINGW here causes b2 to not run cygpath
    string(APPEND USER_CONFIG_TOOLSET_OPTIONS
        "    <flavor>mingw\n"
    )
endif()

if(WIN32)
    list(APPEND B2_OPTIONS threadapi=win32)
else()
    list(APPEND B2_OPTIONS threadapi=pthread)
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    list(APPEND B2_OPTIONS variant=release)
else()
    list(APPEND B2_OPTIONS variant=debug)
endif()

if(NOT WIN32)
    list(APPEND B2_OPTIONS "--layout=system")
endif()

include(ProcessorCount)
ProcessorCount(NUMBER_OF_PROCESSORS)
if(NOT NUMBER_OF_PROCESSORS)
    set(NUMBER_OF_PROCESSORS 1)
endif()

# Handle ICU
if(WIN32)
    list(APPEND B2_OPTIONS "--disable-icu")
else()
    find_path(ICU_PATH include/unicode/utf.h)
    list(APPEND B2_OPTIONS "-sICU_PATH=\"${ICU_PATH}\"")
endif()

# Handle Python
set(python_versions "")

if(WITH_PYTHON2)
    # Find Python2 in the current installed directory
    file(GLOB python2_include_dir "${CURRENT_INSTALLED_DIR}/include/python2.*")
    string(REGEX REPLACE ".*python([0-9\.]+).*" "\\1" python2_version "${python2_include_dir}")
    string(APPEND USER_CONFIG_EXTRA_LINES
        "using python : ${python2_version} : : \"${python2_include_dir}\" : \"${CURRENT_INSTALLED_DIR}/lib\" ;\n"
        "using python : ${python2_version} : : \"${python2_include_dir}\" : \"${CURRENT_INSTALLED_DIR}/debug/lib\" : <python-debugging>on ;\n"
    )
    list(APPEND python_versions "${python2_version}")
endif()

if(WITH_PYTHON3)
    # Find Python3 in the current installed directory
    file(GLOB python3_include_dir "${CURRENT_INSTALLED_DIR}/include/python3.*")
    string(REGEX REPLACE ".*python([0-9\.]+).*" "\\1" python3_version "${python3_include_dir}")
    string(APPEND USER_CONFIG_EXTRA_LINES
        "using python : ${python3_version} : : \"${python3_include_dir}\" : \"${CURRENT_INSTALLED_DIR}/lib\" ;\n"
        "using python : ${python3_version} : : \"${python3_include_dir}\" : \"${CURRENT_INSTALLED_DIR}/debug/lib\" : <python-debugging>on ;\n"
    )
    list(APPEND python_versions "${python3_version}")
endif()

if(NOT python_versions STREQUAL "")
    list(JOIN python_versions "," python_versions)
    list(APPEND B2_OPTIONS "python=${python_versions}")

    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        list(APPEND B2_OPTIONS "python-debugging=on")
    endif()
endif()

if("${PORT}" STREQUAL "boost-mpi" OR "${PORT}" STREQUAL "boost-graph-parallel")
    string(APPEND USER_CONFIG_EXTRA_LINES
        "using mpi : : <library-path>\"${CURRENT_INSTALLED_DIR}/lib\"\n"
        "   <include>\"${CURRENT_INSTALLED_DIR}/include\"\n"
    )
    if(WIN32)
        string(APPEND USER_CONFIG_EXTRA_LINES
            "   <find-shared-library>msmpi ;\n"
        )
    else()
        string(APPEND USER_CONFIG_EXTRA_LINES
            "   <find-shared-library>openmpi ;\n"
        )
    endif()
endif()

# Include port specific CMake fragment
if(DEFINED BOOST_CMAKE_FRAGMENT)
    message(STATUS "Including ${BOOST_CMAKE_FRAGMENT}")
    include(${BOOST_CMAKE_FRAGMENT})
endif()

configure_file(${CMAKE_CURRENT_LIST_DIR}/user-config.jam.in ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam @ONLY)

add_custom_target(boost ALL
    COMMAND "${B2_EXE}"
        toolset=${USER_CONFIG_TOOLSET}
        --user-config=${CMAKE_CURRENT_BINARY_DIR}/user-config.jam
        --stagedir=${CMAKE_CURRENT_BINARY_DIR}/stage
        --build-dir=${CMAKE_CURRENT_BINARY_DIR}
        ${B2_OPTIONS}
        --with-atomic
        --with-random
        --with-date_time
        --with-filesystem
        --with-system
        --with-thread
        --with-chrono
        -j${NUMBER_OF_PROCESSORS}
        -sBOOST_ROOT=${BOOST_BUILD_PATH}
        -sBOOST_BUILD_PATH=${BOOST_BUILD_PATH}
        --debug-configuration
        --debug-building
        --debug-generators
        --ignore-site-config
        --hash
        -q
        debug-symbols=on
        # Enable debugging level 2.
        -d +2

        threading=multi

        stage
    WORKING_DIRECTORY ${SOURCE_PATH}/build
)

set(SUBDIR ${CMAKE_CURRENT_BINARY_DIR}/stage/lib)
install(
    CODE "
file(GLOB LIBS \"${SUBDIR}/*.so.*\" \"${SUBDIR}/*.so\" \"${SUBDIR}/*.a\" \"${SUBDIR}/*.dylib\" \"${SUBDIR}/*.dylib.*\" \"${SUBDIR}/*.lib\")
if(LIBS)
    file(INSTALL \${LIBS} DESTINATION \"\${CMAKE_INSTALL_PREFIX}/lib\")
endif()
file(GLOB DLLS \"${SUBDIR}/*.dll\" \"${SUBDIR}/*.pyd\")
if(DLLS)
    file(INSTALL \${DLLS} DESTINATION \"\${CMAKE_INSTALL_PREFIX}/bin\")
endif()
"
)
