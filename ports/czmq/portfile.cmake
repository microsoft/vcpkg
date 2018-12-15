include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/czmq
    REF d89e7e21086f7c8c93fe54a3bdce8c1c2804920d
    SHA512 fe986482c2d9e0983595df604d3a0f6788c1329b3413b0e3be5df4aff83585bab1df5865ea8c91a1c1f8ebf923752b4f4ec6729dc712e104e3f87f6513300fd0
    HEAD_REF master
    PATCHES
        fix-module-path.patch
        find-libzmq.patch
        find-libcurl.patch
        find-libsodium.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

if("draft" IN_LIST FEATURES)
    set(ENABLE_DRAFTS ON)
else()
    set(ENABLE_DRAFTS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCZMQ_BUILD_SHARED=${BUILD_SHARED}
        -DCZMQ_BUILD_STATIC=${BUILD_STATIC}
        -DENABLE_DRAFTS=${ENABLE_DRAFTS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)

if(CMAKE_HOST_WIN32)
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/zmakecert${EXECUTABLE_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/czmq)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/czmq)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin)

    configure_file(${CMAKE_CURRENT_LIST_DIR}/usage-static
        ${CURRENT_PACKAGES_DIR}/share/czmq/usage COPYONLY)
else()
    file(REMOVE
        ${CURRENT_PACKAGES_DIR}/debug/bin/zmakecert${EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/zmakecert${EXECUTABLE_SUFFIX})

    configure_file(${CMAKE_CURRENT_LIST_DIR}/usage-dynamic
        ${CURRENT_PACKAGES_DIR}/share/czmq/usage COPYONLY)
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/czmq/copyright COPYONLY)

vcpkg_copy_pdbs()
