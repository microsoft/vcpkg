vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ybainier/Hypodermic
    REF ba5516d4e78230c1187debb01ebdf01e5d11f62d # 2023-03-03
    SHA512 0
    HEAD_REF master
    PATCHES
        "disable_hypodermic_tests.patch"
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/debug"
)


# Put the license file where vcpkg expects it
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)