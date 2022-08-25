vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BowenFu/matchit.cpp
    REF v1.0.1
    SHA512 60edc6a392f5629391fa9e3ff09b7b98a0a782919a066ad2999eabb58e60f38bd50e080037b1276c5bca986f81ca0dfff2914816d46458b7b4e1c947a6134169
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
