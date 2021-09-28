cmake_minimum_required(VERSION 3.9)
project(boost CXX)

set(B2_OPTIONS)

if(MSVC)
    if(MSVC_VERSION LESS 1900)
        math(EXPR BOOST_MSVC_VERSION "${MSVC_VERSION} / 10 - 60")
    else()
        math(EXPR BOOST_MSVC_VERSION "${MSVC_VERSION} / 10 - 50")
    endif()
else()
    set(VCPKG_PLATFORM_TOOLSET external)
endif()

#### Handle ICU
if(WIN32)
    list(APPEND B2_OPTIONS "--disable-icu")
else()
    find_path(ICU_PATH include/unicode/utf.h)
    list(APPEND B2_OPTIONS "-sICU_PATH=\"${ICU_PATH}\"")
endif()

# Add build type specific options
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    list(APPEND B2_OPTIONS runtime-link=shared)
    set(LIB_RUNTIME_LINK "shared")
else()
    list(APPEND B2_OPTIONS runtime-link=static)
    set(LIB_RUNTIME_LINK "static")
endif()

if(BUILD_SHARED_LIBS)
    list(APPEND B2_OPTIONS link=shared)
else()
    list(APPEND B2_OPTIONS link=static)
endif()

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    list(APPEND B2_OPTIONS address-model=64)
else()
    list(APPEND B2_OPTIONS address-model=32)
endif()

if(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "s390x")
    list(APPEND B2_OPTIONS architecture=s390x)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    list(APPEND B2_OPTIONS architecture=arm)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "ppc64le")
    list(APPEND B2_OPTIONS architecture=power)
else()
    list(APPEND B2_OPTIONS architecture=x86)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND WIN32)
    list(APPEND B2_OPTIONS "asmflags=/safeseh")
endif()

file(TO_CMAKE_PATH "${CMAKE_CURRENT_LIST_DIR}/nothing.bat" NOTHING_BAT)

if(MSVC)
    set(B2_TOOLSET msvc)
    list(APPEND B2_OPTIONS target-os=windows)
elseif(APPLE)
    set(B2_TOOLSET clang)
    list(APPEND B2_OPTIONS target-os=darwin)
elseif(WIN32)
    set(B2_TOOLSET gcc)
    list(APPEND B2_OPTIONS target-os=windows)
elseif(ANDROID)
    set(B2_TOOLSET gcc)
    list(APPEND B2_OPTIONS target-os=android)
else()
    set(B2_TOOLSET gcc)
    list(APPEND B2_OPTIONS target-os=linux)
endif()

if(WIN32)
    list(APPEND B2_OPTIONS threadapi=win32)
else()
    list(APPEND B2_OPTIONS threadapi=pthread)
endif()

# Properly handle compiler and linker flags passed by VCPKG
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CXXFLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
    set(CFLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}")
    if(BUILD_SHARED_LIBS)
        set(LDFLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
    else()
        set(LDFLAGS "${CMAKE_STATIC_LINKER_FLAGS} ${CMAKE_STATIC_LINKER_FLAGS_RELEASE}")
    endif()
elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CXXFLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
    set(CFLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG}")
    if(BUILD_SHARED_LIBS)
        set(LDFLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_DEBUG}")
    else()
        set(LDFLAGS "${CMAKE_STATIC_LINKER_FLAGS} ${CMAKE_STATIC_LINKER_FLAGS_DEBUG}")
    endif()
endif()

if(APPLE)
    if(CMAKE_OSX_DEPLOYMENT_TARGET)
        set(CXXFLAGS "-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET} ${CXXFLAGS}")
        set(CFLAGS "-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET} ${CFLAGS}")
        set(LDFLAGS "-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET} ${LDFLAGS}")
    endif()

    if(CMAKE_OSX_SYSROOT)
        set(CXXFLAGS "-isysroot ${CMAKE_OSX_SYSROOT} ${CXXFLAGS}")
        set(CFLAGS "-isysroot ${CMAKE_OSX_SYSROOT} ${CFLAGS}")
        set(LDFLAGS "-isysroot ${CMAKE_OSX_SYSROOT} ${LDFLAGS}")
    endif()

    # if specific architectures are set, configure them,
    # if not set, this will still default to current arch
    foreach(ARCH IN LISTS CMAKE_OSX_ARCHITECTURES)
        set(CXXFLAGS "-arch ${ARCH} ${CXXFLAGS}")
        set(CFLAGS "-arch ${ARCH} ${CFLAGS}")
        set(LDFLAGS "-arch ${ARCH} ${LDFLAGS}")
    endforeach()
endif()

string(STRIP "${CXXFLAGS}" CXXFLAGS)
string(STRIP "${CFLAGS}"   CFLAGS)
string(STRIP "${LDFLAGS}"  LDFLAGS)

if(NOT CXXFLAGS STREQUAL "")
    string(REPLACE " " " <cxxflags>" CXXFLAGS "<cxxflags>${CXXFLAGS}")
endif()
if(NOT CFLAGS STREQUAL "")
    string(REPLACE " " " <cflags>" CFLAGS "<cflags>${CFLAGS}")
endif()
if(NOT LDFLAGS STREQUAL "")
    string(REPLACE " " " <linkflags>" LDFLAGS "<linkflags>${LDFLAGS}")
endif()

if(CMAKE_CXX_COMPILER_TARGET AND CMAKE_CXX_COMPILE_OPTIONS_TARGET)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        string(APPEND CXXFLAGS " <compileflags>${CMAKE_CXX_COMPILE_OPTIONS_TARGET}${CMAKE_CXX_COMPILER_TARGET}")
        string(APPEND LDFLAGS " <linkflags>${CMAKE_CXX_COMPILE_OPTIONS_TARGET}${CMAKE_CXX_COMPILER_TARGET}")
    else()
        string(APPEND CXXFLAGS " <compileflags>${CMAKE_CXX_COMPILE_OPTIONS_TARGET} <compileflags>${CMAKE_CXX_COMPILER_TARGET}")
        string(APPEND LDFLAGS " <linkflags>${CMAKE_CXX_COMPILE_OPTIONS_TARGET} <linkflags>${CMAKE_CXX_COMPILER_TARGET}")
    endif()
endif()

if(CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        string(APPEND CXXFLAGS " <compileflags>${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
        string(APPEND LDFLAGS " <linkflags>${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
    else()
        string(APPEND CXXFLAGS " <compileflags>${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN} <compileflags>${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
        string(APPEND LDFLAGS " <linkflags>${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN} <linkflags>${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
    endif()
endif()

if(CMAKE_SYSROOT AND CMAKE_CXX_COMPILE_OPTIONS_SYSROOT)
    string(APPEND CXXFLAGS " <compileflags>${CMAKE_CXX_COMPILE_OPTIONS_SYSROOT}${CMAKE_SYSROOT}")
    string(APPEND LDFLAGS " <linkflags>${CMAKE_CXX_COMPILE_OPTIONS_SYSROOT}${CMAKE_SYSROOT}")
endif()
foreach(INCDIR IN LISTS CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES)
    string(APPEND CXXFLAGS " <compileflags>${CMAKE_INCLUDE_FLAG_C}${CMAKE_INCLUDE_FLAG_C_SEP}${INCDIR}")
endforeach()

if(APPLE)
  string(APPEND CXXFLAGS " <compileflags>-D_DARWIN_C_SOURCE <cxxflags>-std=c++11 <cxxflags>-stdlib=libc++")
  string(APPEND LDFLAGS " <linkflags>-stdlib=libc++")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    # cl in b2 appears to not receive `LIBPATH` for finding winmd files, so we transform them to `/AI` options.
    set(libpath_args "$ENV{LIBPATH}")
    # Apply: {x -> /AI"x"}
    list(TRANSFORM libpath_args PREPEND "/AI\"")
    list(TRANSFORM libpath_args APPEND "\"")
    # Apply: {\ -> \\}
    list(TRANSFORM libpath_args REPLACE "\\\\" "\\\\\\\\")
    # Apply: {" -> \"}
    list(TRANSFORM libpath_args REPLACE "\\\"" "\\\\\"")
    list(JOIN libpath_args " " libpath_arg)

    string(APPEND CXXFLAGS " <compileflags>\"${libpath_arg}\" <cxxflags>/ZW <compileflags>\"/D_WIN32_WINNT=0x0A00\"")
    string(APPEND CFLAGS " <cflags>-Zl")
    list(APPEND B2_OPTIONS windows-api=store)
    list(APPEND B2_OPTIONS linkflags=WindowsApp.lib)
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    list(APPEND B2_OPTIONS variant=release)
else()
    list(APPEND B2_OPTIONS variant=debug)
endif()

if(NOT WIN32)
    list(APPEND B2_OPTIONS "--layout=system")
endif()

# Include port specific CMake fragment
if(DEFINED BOOST_CMAKE_FRAGMENT)
    message(STATUS "Including ${BOOST_CMAKE_FRAGMENT}")
    include(${BOOST_CMAKE_FRAGMENT})
endif()

configure_file(${CMAKE_CURRENT_LIST_DIR}/user-config.jam ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam @ONLY)

include(ProcessorCount)
ProcessorCount(NUMBER_OF_PROCESSORS)
if(NOT NUMBER_OF_PROCESSORS)
    set(NUMBER_OF_PROCESSORS 1)
endif()

add_custom_target(boost ALL
    COMMAND "${B2_EXE}"
        toolset=${B2_TOOLSET}
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
        -d +2

        threading=multi

        stage
    WORKING_DIRECTORY ${SOURCE_PATH}/build
)

set(SUBDIR ${CMAKE_CURRENT_BINARY_DIR}/stage/lib)
install(
    CODE "
file(GLOB LIBS ${SUBDIR}/*.so.* ${SUBDIR}/*.so ${SUBDIR}/*.a ${SUBDIR}/*.dylib ${SUBDIR}/*.dylib.* ${SUBDIR}/*.lib)
if(LIBS)
    file(INSTALL \${LIBS} DESTINATION \"\${CMAKE_INSTALL_PREFIX}/lib\")
endif()
file(GLOB DLLS ${SUBDIR}/*.dll)
if(DLLS)
    file(INSTALL \${DLLS} DESTINATION \"\${CMAKE_INSTALL_PREFIX}/bin\")
endif()
"
)
