include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "Neargye/magic_enum"
    REF v0.6.0
    SHA512 3079155509f0141e9a50b2a773e33e3ebda1a4c1a7d0b78f093e2d0e8a4b78ef108876e63ef986a55c03bb712a494943b7c4c37bcbe08d932035106f4afe3bd2
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS
      -DMAGIC_ENUM_OPT_BUILD_EXAMPLES=OFF
      -DMAGIC_ENUM_OPT_BUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/magic_enum)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/magic-enum RENAME copyright)
