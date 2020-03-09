include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/ogg
    REF c8fca6b4a02d695b1ceea39b330d4406001c03ed
    SHA512 52980fcca3c1dbb5fbfa4032f179679a5c4000f1fea88e7ed8b2522d80d27513be96d94933daeb9e36f4ac8556e7e4e8ec7e91101e2ba456e0fce51c484eee9e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DINSTALL_DOCS=0 -DINSTALL_PKG_CONFIG_MODULE=0
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Ogg TARGET_PATH share/ogg)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

