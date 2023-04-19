#
# portfile.cmake
#

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baresip/re
    REF v3.0.0
    SHA512 c37e49cca0d7ff591a3d178cbf58511d27e08be2c9b210353d9f65bb2cd76d135e0e023702140623630440ffdcc7b4c51ac29495bd85df4424627a5a69adba52
    HEAD_REF main
    PATCHES
        766.diff
        openssl.diff
)


vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m)


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/lib/cmake")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
