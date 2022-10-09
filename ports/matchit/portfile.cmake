vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BowenFu/matchit.cpp
    REF v1.0.1
    SHA512 60edc6a392f5629391fa9e3ff09b7b98a0a782919a066ad2999eabb58e60f38bd50e080037b1276c5bca986f81ca0dfff2914816d46458b7b4e1c947a6134169
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/matchit")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
