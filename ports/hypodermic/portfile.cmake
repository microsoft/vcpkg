vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ybainier/Hypodermic
    REF ba5516d4e78230c1187debb01ebdf01e5d11f62d # 2023-03-03
    SHA512 40a119baafc23149117e286c38c00bdc0debda1cb6fefbecfdbc6e1a779789c6c884d1e7513aaf55060d550232c3dc8777ef0ebf0cd94e998ff2d5d6d375d2ff
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