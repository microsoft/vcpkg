vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zlib-ng/zlib-ng
    REF "${VERSION}"
    SHA512 f49a89497988db55a2f2375f79443e7e2c57470dbd94b35ae38a39d988eb42f8ecc295a1bd68845fc273b59ea508d0e74b142585d85b7e869dd3c01cc6923d8d
    HEAD_REF develop
)

# Set ZLIB_COMPAT in the triplet file to turn on
if(NOT DEFINED ZLIB_COMPAT)
    set(ZLIB_COMPAT OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DZLIB_FULL_VERSION=${ZLIB_FULL_VERSION}"
        -DZLIB_ENABLE_TESTS=OFF
        -DWITH_NEW_STRATEGIES=ON
        -DZLIB_COMPAT=${ZLIB_COMPAT}
    OPTIONS_RELEASE
        -DWITH_OPTIM=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Condition in `WIN32`, from https://github.com/zlib-ng/zlib-ng/blob/2.1.5/CMakeLists.txt#L1081-L1100
# (dynamic) for `zlib` or (static `MSVC) for `zlibstatic` or default `z`
# i.e. (windows) and not (static mingw) https://learn.microsoft.com/en-us/vcpkg/maintainers/variables#vcpkg_target_is_system
if(VCPKG_TARGET_IS_WINDOWS AND (NOT (VCPKG_LIBRARY_LINKAGE STREQUAL static AND VCPKG_TARGET_IS_MINGW)))
    set(_port_suffix)
    if(ZLIB_COMPAT)
        set(_port_suffix "")
    else()
        set(_port_suffix "-ng")
    endif()

    set(_port_output_name)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(_port_output_name "zlib${_port_suffix}")
    else()
        set(_port_output_name "zlibstatic${_port_suffix}")
    endif()

    # CMAKE_DEBUG_POSTFIX from https://github.com/zlib-ng/zlib-ng/blob/2.1.5/CMakeLists.txt#L494
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/zlib${_port_suffix}.pc" " -lz${_port_suffix}" " -l${_port_output_name}")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/zlib${_port_suffix}.pc" " -lz${_port_suffix}" " -l${_port_output_name}d")
    endif()
endif()

vcpkg_fixup_pkgconfig()

if(ZLIB_COMPAT)
    set(_cmake_dir "ZLIB")
else()
    set(_cmake_dir "zlib-ng")
endif()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${_cmake_dir})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
