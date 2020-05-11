vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nuspell/nuspell
    REF v3.1.1
    SHA512 239855051d9f49ba16913283090c4214a8f6a6cc290d359ab54014ff76fc297c131b67c6748bd1d4cdcec43c00dccc7f0c1bf8b07e06c9c648bff52ff193e096
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
