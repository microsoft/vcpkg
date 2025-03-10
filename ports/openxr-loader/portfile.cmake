vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK-Source
    REF "release-${VERSION}"
    SHA512 9d7548e6d992cde412e331fc6253960d37897cc4b55cafdc07f7d0a14a70d5ec8534b33f3bb537c797306035cb80aa1b3abf2656ed9d4a6e43e375f5f6e1e2a4
    HEAD_REF master
    PATCHES
        fix-openxr-sdk-jsoncpp.patch
        msvc-crt.diff
)

vcpkg_from_github(
    OUT_SOURCE_PATH HPP_SOURCE_PATH
    REPO KhronosGroup/OpenXR-hpp
    REF af6f069aa1e003041311090237bb41471c776ff6
    SHA512 986d214a7f725c9b8000a61d8614ecaa0495173a1683a5e1bec636be22f6617551ae43e3e0fd2b0cba6e427f6ed6014daa56deed8497b32cb1236cd35ed8788c
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
        "-DPython3_EXECUTABLE=${PYTHON3}"
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
