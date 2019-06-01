include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/czmq
    REF 6d9c89705a2af1aae6f6d93789ec865cea629829
    SHA512 26881bbc63ddab2cb4ac1b03e476e900f7d41977b37c95a29f33538da23e4237c7b009aefa64332512605d8e0859661b94135d67a24596a0e8d7881651cb6e72
    HEAD_REF master
    PATCHES
        fix-cmake.patch
        fix-dependencies.patch
)

foreach(_cmake_module
    Findlibcurl.cmake
    Findlibmicrohttpd.cmake
    Findlibzmq.cmake
    Findlz4.cmake
    Finduuid.cmake
)
    configure_file(
        ${CMAKE_CURRENT_LIST_DIR}/${_cmake_module}
        ${SOURCE_PATH}/${_cmake_module}
        COPYONLY
    )
endforeach()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

if("draft" IN_LIST FEATURES)
    set(ENABLE_DRAFTS ON)
else()
    set(ENABLE_DRAFTS OFF)
endif()

if("httpd" IN_LIST FEATURES)
    set(CZMQ_WITH_LIBMICROHTTPD ON)
else()
    set(CZMQ_WITH_LIBMICROHTTPD OFF)
endif()

if("tool" IN_LIST FEATURES)
    set(BUILD_TOOLS ON)
else()
    set(BUILD_TOOLS OFF)
endif()

if("uuid" IN_LIST FEATURES AND
   VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(CZMQ_WITH_UUID ON)
else()
    set(CZMQ_WITH_UUID OFF)
endif()

set(_ADDITIONAL_LIB_FLAGS "")
foreach(_feature "curl" "lz4")
    string(TOUPPER "${_feature}" _FEATURE)
    
    if(_feature IN_LIST FEATURES)
        list(APPEND _ADDITIONAL_LIB_FLAGS "-DCZMQ_WITH_${_FEATURE}=ON")
    else()
        list(APPEND _ADDITIONAL_LIB_FLAGS "-DCZMQ_WITH_${_FEATURE}=OFF")
    endif()
endforeach()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DBUILD_TOOLS=OFF
    OPTIONS_RELEASE
        -DBUILD_TOOLS=${BUILD_TOOLS}
    OPTIONS
        -DCZMQ_BUILD_SHARED=${BUILD_SHARED}
        -DCZMQ_BUILD_STATIC=${BUILD_STATIC}
        -DENABLE_DRAFTS=${ENABLE_DRAFTS}
        -DBUILD_TESTING=OFF
        -DCZMQ_WITH_LIBMICROHTTPD=${CZMQ_WITH_LIBMICROHTTPD}
        -DCZMQ_WITH_UUID=${CZMQ_WITH_UUID}
        ${_ADDITIONAL_LIB_FLAGS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/cmake/${PORT})
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/${PORT})
endif()

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

if(CMAKE_HOST_WIN32)
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

if (BUILD_TOOLS)
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/zmakecert${EXECUTABLE_SUFFIX}
        DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/czmq_library.h
        "if defined CZMQ_STATIC"
        "if 1 //if defined CZMQ_STATIC"
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(REMOVE
        ${CURRENT_PACKAGES_DIR}/debug/bin/zmakecert${EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/zmakecert${EXECUTABLE_SUFFIX})
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
