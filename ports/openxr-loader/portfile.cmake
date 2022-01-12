
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK
    REF release-1.0.20
    SHA512 26629edd9dcd17bae8d1089bfeb479914f3c7f7cd595345fad3e4be18d8dc7e079fd2ac89906199acc61ae5ce14c15ea66bcd0dfb44411788ab1ee0468c91192
    HEAD_REF master
    PATCHES
        fix-openxr-sdk-jsoncpp.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SDK_SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK-Source
    REF release-1.0.20
    SHA512 1f989b76c76cdece3c47b758a1c77a78a4bc91cb01504cc033a543da6bc85b18a4e981b35a2875cab454660fbb2443ea4d09e98079aae6e6253f768428012a20
    HEAD_REF master
    PATCHES
        fix-openxr-sdk-jsoncpp.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH HPP_SOURCE_PATH
    REPO KhronosGroup/OpenXR-hpp
    REF 6fcea9e472622c9c7f4df0b5f0bfe7ff5d8553f7
    SHA512 04d1f9db6fd0a01cdf3274089ab17bf17974ff799b4690561c16067e83710e1422a2aefd070b26023ff832eb58e6a3365297a818c9546ea4c531328bd1fb2de4
    HEAD_REF master
    PATCHES
        002-fix-hpp-gen.patch
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
file(STRINGS "${HPP_SOURCE_PATH}/headers.txt" HEADER_LIST REGEX "^openxr.*")
foreach(HEADER ${HEADER_LIST})
    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} "${HPP_SOURCE_PATH}/scripts/hpp_genxr.py" -registry "${SDK_SOURCE_PATH}/specification/registry/xr.xml" -o "${CURRENT_PACKAGES_DIR}/include/openxr" ${HEADER}
        WORKING_DIRECTORY "${HPP_SOURCE_PATH}"
        LOGNAME openxrhpp
    )
endforeach()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/openxr)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
