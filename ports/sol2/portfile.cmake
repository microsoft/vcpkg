vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF v3.2.2
    SHA512 e5a739b37aea7150f141f6a003c2689dd33155feed5bb3cf2569abbfe9f0062eacdaaf346be523d627f0e491b35e68822c80e1117fa09ece8c9d8d5af09fdbec
    HEAD_REF develop
    PATCHES fix-namespace.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sol2)

file(
    REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/debug
        ${CURRENT_PACKAGES_DIR}/lib
        ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL ${SOURCE_PATH}/single/include/sol DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
