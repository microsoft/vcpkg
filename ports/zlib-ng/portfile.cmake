vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zlib-ng/zlib-ng
    REF "${VERSION}"
    SHA512 3cb3e97ee1d20e1f3cdf0efcdf55aee0e3a192f9a2ae781cd209b1d37620c48f2ada345fb1f4357315b1cb5e09b7ea5fcdfa2fd54f7b4ac5dcb6e73860000aad
    HEAD_REF develop
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DZLIB_FULL_VERSION=${ZLIB_FULL_VERSION}"
        -DZLIB_ENABLE_TESTS=OFF
        -DWITH_NEW_STRATEGIES=ON
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zlib-ng)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
