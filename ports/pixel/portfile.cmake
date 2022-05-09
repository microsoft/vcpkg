if(VCPKG_TARGET_IS_LINUX)
    message(WARNING"${PORT} currently requires libglu1-mesa from the system package manager:
    This can be installed on Ubuntu systems via sudo apt install libglu1-mesa-dev")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dascandy/pixel
    REF c4411f67746fdd811aa5f8c102ac340e9eaf4ec5
    SHA512 e4f704c076bb61220349524b0b1033a92c44128bb81e79dbd32ea2d1aa9d4abb0d6daab3617f69b59d1c1e50d750767153174fea015d8718804612f4d9f68ff6
    HEAD_REF master
    PATCHES
        001-prevent-examples.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
