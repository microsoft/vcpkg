
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK
    REF release-1.0.22
    SHA512 fe3c393c2d11981b42355acd8dbc337727120bcd0ff595abac1975c4ce5f68bb74a9a1b4c959e64e9a847ae5d504100d31979ffd7d9702c55b2dbd889de17d3e
    HEAD_REF master
    PATCHES
        fix-openxr-sdk-jsoncpp.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SDK_SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK-Source
    REF release-1.0.22
    SHA512 92802d57a45ca1d697d3cea1b3f5619af4ba36156cb28c2c39b2295a74ebc45907caf371c916c54ec3be44a2f3ae447ffc1cd62f54b7b24f7a081408328c7651
    HEAD_REF master
    PATCHES
        fix-openxr-sdk-jsoncpp.patch
        fix-jinja2.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH HPP_SOURCE_PATH
    REPO KhronosGroup/OpenXR-hpp
    REF release-1.0.21
    SHA512 cda111f20392a64d5f4de6bd71f1fe7fe39d688bb2376c6b1841763459e32fd6d03b9552804b5ee464ba84cd4c05cfdaa1a6e8a8e5da3eae6b94c7797c65cb36
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
