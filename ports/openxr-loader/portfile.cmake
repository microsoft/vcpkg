
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK
    REF "release-${VERSION}"
    SHA512 6efc7596e707f95366dbcdbac9bd7d0c20735a2175b4edf56a9e8a112cf0ab8b664069fe942313164a37119032ddbf5671bc88ab5f276005dd36e4a4dabba1c7
    HEAD_REF master
    PATCHES
        fix-openxr-sdk-jsoncpp.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SDK_SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK-Source
    REF "release-${VERSION}"
    SHA512 04bdb0f16078209b5edd175a3396f70e1ceb8cfa382c65b8fda388e565480e3844daf68e0d987e72ed8c21d3148af0b41a2170911ec1660565887e0e5ae6d2bf
    HEAD_REF master
    PATCHES
        fix-openxr-sdk-jsoncpp.patch
        fix-jinja2.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH HPP_SOURCE_PATH
    REPO KhronosGroup/OpenXR-hpp
    REF 63db9919822f8af6f7bf7416ba6a015d4617202e
    SHA512 9e768f485d1631f8e74f35f028a64e2d64e33d362c53ae1c54427a10786e3befdd24089927319aa1a4b4c3e010247bd6cb3394bcee460c467c637ab6bc7bec90
    HEAD_REF master
    PATCHES
        python3_8_compatibility.patch
)

# Weird behavior inside the OpenXR loader.  On Windows they force shared libraries to use static crt, and
# vice-versa. Might be better in future iterations to patch the CMakeLists.txt for OpenXR
if (VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        set(DYNAMIC_LOADER OFF)
        set(VCPKG_CRT_LINKAGE dynamic)
    else()
        set(DYNAMIC_LOADER ON)
        set(VCPKG_CRT_LINKAGE static)
    endif()
endif()

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_API_LAYERS=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_CONFORMANCE_TESTS=OFF
        -DDYNAMIC_LOADER=${DYNAMIC_LOADER}
        -DPYTHON_EXECUTABLE="${PYTHON3}"
        -DBUILD_WITH_SYSTEM_JSONCPP=ON
)

vcpkg_cmake_install()

# Generate the OpenXR C++ bindings
set(ENV{OPENXR_REPO} "${SDK_SOURCE_PATH}")
vcpkg_execute_required_process(
    COMMAND ${PYTHON3} "${HPP_SOURCE_PATH}/scripts/hpp_genxr.py" -quiet  -registry "${SDK_SOURCE_PATH}/specification/registry/xr.xml" -o "${CURRENT_PACKAGES_DIR}/include/openxr"
    WORKING_DIRECTORY "${HPP_SOURCE_PATH}"
    LOGNAME "openxr-hpp"
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(PACKAGE_NAME OpenXR CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME OpenXR CONFIG_PATH lib/cmake/openxr)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
