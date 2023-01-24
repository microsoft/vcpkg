# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cppfastio/fast_io
    REF 88c3c87290f07bd97b31c71fbd815b7d20ab66d9
    SHA512 da356498797d2bc50671e5a12099e9a9c50f1f1c570cd7ed68ef32082e1778d86efeeddea57c84a116fb817572d9fbbd33d8e44fef6a38b760fcb8ab8edbe6ab
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)