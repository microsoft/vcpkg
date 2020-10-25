# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/indicators
    REF 755900d
    SHA512 2d553ab80cf862645a7256de2c9abca724ce786e2f30f06ceafd8c4e7dc93ede9fab646e7a36f7d106dfc60ba5e5feaee076c9a5f49193dedc5299f7d60b7d7b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DINDICATORS_BUILD_TESTS=OFF
        -DINDICATORS_SAMPLES=OFF
        -DINDICATORS_DEMO=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/indicators TARGET_PATH share/indicators)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE.termcolor DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
