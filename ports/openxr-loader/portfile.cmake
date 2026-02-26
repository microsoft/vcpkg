vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK-Source
    REF "release-${VERSION}"
    SHA512 be99658ff3d27bd8674dceb8b5d50bfbbfaf2f3667a8c38d6afb0cdb2701881c945a4c423ce68e4591cc468a9a499803ffb05a9a610f52a1c47fca97d73e13d8
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

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        vulkan  VCPKG_LOCK_FIND_PACKAGE_Vulkan
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DYNAMIC_LOADER)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_API_LAYERS=OFF
        -DBUILD_CONFORMANCE_TESTS=OFF
        -DBUILD_TESTS=OFF
        -DCMAKE_INSTALL_INCLUDEDIR=include
        -DDYNAMIC_LOADER=${DYNAMIC_LOADER}
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
