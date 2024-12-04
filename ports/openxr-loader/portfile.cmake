vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK
    REF "release-${VERSION}"
    SHA512 cfcabbd130f89d1d46899f3a9a34e9b5d9b21903b6d0fc48c62e233401cf200107a9fa8da926fc0036937a9ed647a2376bee58db925654c41acc7580f8f3a053
    HEAD_REF master
    PATCHES
        fix-openxr-sdk-jsoncpp.patch
        msvc-crt.diff
)
file(GLOB gl_headers "${SOURCE_PATH}/external/include/GL/*")
list(REMOVE_ITEM gl_headers "${SOURCE_PATH}/external/include/gl_format.h")
file(REMOVE ${gl_headers})

vcpkg_from_github(
    OUT_SOURCE_PATH SDK_SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK-Source
    REF "release-${VERSION}"
    SHA512 c2cfab927e6ff8a5a7b90360c99192ae9cd598614965fbd4816361b19c5bf25e5524f0e73ce56774e32903addbce8a8dbcb9520203f845421d33cb33f832977b
    HEAD_REF master
    PATCHES
        fix-openxr-sdk-jsoncpp.patch
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

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(PACKAGE_NAME openxr CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME openxr CONFIG_PATH lib/cmake/openxr)
endif()

# Generate the OpenXR C++ bindings
set(ENV{OPENXR_REPO} "${SDK_SOURCE_PATH}")
vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${HPP_SOURCE_PATH}/scripts/hpp_genxr.py" -quiet  -registry "${SDK_SOURCE_PATH}/specification/registry/xr.xml" -o "${CURRENT_PACKAGES_DIR}/include/openxr"
    WORKING_DIRECTORY "${HPP_SOURCE_PATH}"
    LOGNAME "openxr-hpp"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
