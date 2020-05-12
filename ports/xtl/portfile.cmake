# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtl
    REF be592a531e89f0e4eb3d384b00fec43451f3e734 # 0.6.11
    SHA512 101bbb0430171499a1167ef39458e908ccf5b39c2037860c2a334642f3d2323f4b8766fe78973967e9cc731956a9c358882165a3713c490fd6513905c3173629
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
