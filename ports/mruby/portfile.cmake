set(VERSION 3.2.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mruby/mruby
    REF 87260e7bb1a9edfb2ce9b41549c4142129061ca5
    SHA512 dbc0602ac7265076dc9fa1f862585fe0a3669be32cef0f0b13f1fdc18e82e45d2b9eb205723a87581a8a96382fb0ca23ec19fe0494cba29f7a2eaa512e5b26cc
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)