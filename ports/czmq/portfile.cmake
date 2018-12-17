include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/czmq
    REF d89e7e21086f7c8c93fe54a3bdce8c1c2804920d
    SHA512 fe986482c2d9e0983595df604d3a0f6788c1329b3413b0e3be5df4aff83585bab1df5865ea8c91a1c1f8ebf923752b4f4ec6729dc712e104e3f87f6513300fd0
    HEAD_REF master
    PATCHES
        fix-cmake.patch
        find-libzmq.patch
        find-libcurl.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

if("draft" IN_LIST FEATURES)
    set(ENABLE_DRAFTS ON)
else()
    set(ENABLE_DRAFTS OFF)
endif()

if("tool" IN_LIST FEATURES)
    set(BUILD_TOOLS ON)
else()
    set(BUILD_TOOLS OFF)
endif()

set(_ADDITIONAL_LIB_FLAGS "")
foreach(_feature "curl" "uuid" "lz4")
    string(TOUPPER "${_feature}" _FEATURE)
    
    if(_feature IN_LIST FEATURES)
        list(APPEND _ADDITIONAL_LIB_FLAGS "-DBUILD_WITH_${_FEATURE}=ON")
    else()
        list(APPEND _ADDITIONAL_LIB_FLAGS "-DBUILD_WITH_${_FEATURE}=OFF")
    endif()
endforeach()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCZMQ_BUILD_SHARED=${BUILD_SHARED}
        -DCZMQ_BUILD_STATIC=${BUILD_STATIC}
        -DENABLE_DRAFTS=${ENABLE_DRAFTS}
        -DBUILD_TESTING=OFF
        -DBUILD_TOOLS=${BUILD_TOOLS}
        ${_ADDITIONAL_LIB_FLAGS}
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/cmake/${PORT})
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/${PORT})
endif()

if(CMAKE_HOST_WIN32)
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

if (BUILD_TOOLS)
    file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/zmakecert${EXECUTABLE_SUFFIX}
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

file(READ ${CURRENT_PACKAGES_DIR}/share/${PORT}/czmqConfig.cmake _contents)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    string(CONCAT _contents
        "${_contents}\n"
        "add_library(czmq INTERFACE IMPORTED)\n"
        "set_target_properties(czmq PROPERTIES INTERFACE_LINK_LIBRARIES czmq-static)\n")

    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    string(CONCAT _contents
        "${_contents}\n"
        "add_library(czmq-static INTERFACE IMPORTED)\n"
        "set_target_properties(czmq-static PROPERTIES INTERFACE_LINK_LIBRARIES czmq)\n")

    file(REMOVE
        ${CURRENT_PACKAGES_DIR}/debug/bin/zmakecert${EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/zmakecert${EXECUTABLE_SUFFIX})
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/czmqConfig.cmake "${_contents}")

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
