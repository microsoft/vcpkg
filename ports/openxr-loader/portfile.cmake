vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK-Source
    REF "release-${VERSION}"
    SHA512 c2cfab927e6ff8a5a7b90360c99192ae9cd598614965fbd4816361b19c5bf25e5524f0e73ce56774e32903addbce8a8dbcb9520203f845421d33cb33f832977b
    HEAD_REF master
    PATCHES
        fix-openxr-sdk-jsoncpp.patch
        msvc-crt.diff
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

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DYNAMIC_LOADER)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_API_LAYERS=OFF
        -DBUILD_CONFORMANCE_TESTS=OFF
        -DBUILD_TESTS=OFF
        -DCMAKE_INSTALL_INCLUDEDIR=include
        -DDYNAMIC_LOADER=${DYNAMIC_LOADER}
        "-DPYTHON_EXECUTABLE=${PYTHON3}"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# "openxr-loader" matches "<name>*" for "OpenXR", so use the default.
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/openxr)
endif()

# Generate the OpenXR C++ bindings
set(ENV{OPENXR_REPO} "${SOURCE_PATH}")
vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${HPP_SOURCE_PATH}/scripts/hpp_genxr.py" -quiet  -registry "${SOURCE_PATH}/specification/registry/xr.xml" -o "${CURRENT_PACKAGES_DIR}/include/openxr"
    WORKING_DIRECTORY "${HPP_SOURCE_PATH}"
    LOGNAME "openxr-hpp"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
