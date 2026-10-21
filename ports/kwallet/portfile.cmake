vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kwallet
    REF "v${VERSION}"
    SHA512 e22e5c35e3e519df560db7d39b8aac71b9cf53f64543baa07e46a2317f51d50c88d9b4e0bbe275cf6c651618afbfb049e9e7d94dc9843a8e945692722ca042d1
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

if(VCPKG_CROSSCOMPILING)
    # Use kconfig_compiler from the host
    list(APPEND CROSS_OPTIONS
        "-DKF6_HOST_TOOLING=${CURRENT_HOST_INSTALLED_DIR}/share"
        "-DKCONFIGCOMPILER_PATH=${CURRENT_HOST_INSTALLED_DIR}/share/kf6config/KF6ConfigCompilerTargets.cmake"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${CROSS_OPTIONS}
        -DBUILD_TESTING=OFF
        -DBUILD_KWALLETD=OFF
        -DBUILD_KSECRETD=OFF
        -DBUILD_KWALLET_QUERY=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_KF6DocTools=ON
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_KF6DocTools
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6wallet CONFIG_PATH lib/cmake/KF6Wallet)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_download_distfile(GPL_LICENSE
    URLS "https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt"
    FILENAME "kwallet-GPL-2.0.txt"
    SHA512 7a1dba2c878f7a2395175da465a20103ac7e33b145c662373114cd84a29b2b1f0a45e04e6140cdcdf56c11e2e0260dab90a2cc29babc0e6cbf1676b1dd377af2
)
list(APPEND LICENSE_FILES "${GPL_LICENSE}")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
