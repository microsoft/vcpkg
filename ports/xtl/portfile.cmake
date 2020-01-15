# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtl
    REF 557bbc914e91e4efa93b2ca8d09ab11b1e70b711 # 0.6.10
    SHA512 bf02c90f17dcf46ca424fb4bb6bbda5a57f0f1258c35f0c9ddc3ff6f0bcdd1c5f485f786b986ee96b0044340b2a9e25f1750fbee1b32c76b0c68e8a04127fba5
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
