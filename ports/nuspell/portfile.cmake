vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nuspell/nuspell
    REF v3.1.0
    SHA512 a9bedfd6e2d77fd34d249cf7aa1fcb6bde5bced26f02f8a2dd860416a61488c9b7016a0df6015052fcccb272b342e6205db601107f46efa44c9d78ce261a826c
    HEAD_REF master

    PATCHES cmake-disable-cli-and-docs.patch
    # This patch disables building the CLI tool and leaves only the library.
    # That is because Vcpkg complains when it finds .exe files in the folder
    # "bin". Instead it expects them under "tools", which is different
    # convention than on Unixes. This patch is quick fix, the CLI is not
    # that important.
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_TESTING=OFF
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/nuspell)
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(
    INSTALL ${SOURCE_PATH}/COPYING.LESSER
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright)
