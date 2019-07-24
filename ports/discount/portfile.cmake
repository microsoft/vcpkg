include(vcpkg_common_functions)

# No dynamic link for MSVC
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Orc/discount
    REF v2.2.6
    SHA512 4c5956dea78aacd3a105ddac13f1671d811a5b2b04990cdf8485c36190c8872c4b1b9432a7236f669c34b07564ecd0096632dced54d67de9eaf4f23641417ecc
    HEAD_REF master
    PATCHES
      cmake.patch
      generate-blocktags-command.patch
)

if(VCPKG_TARGET_TRIPLET MATCHES "^arm" OR VCPKG_TARGET_TRIPLET MATCHES "uwp$")
    file(COPY "${CURRENT_PORT_DIR}/blocktags" DESTINATION "${SOURCE_PATH}/blocktags")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DDISCOUNT_ONLY_LIBRARY=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/discount)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/discount" RENAME copyright)

