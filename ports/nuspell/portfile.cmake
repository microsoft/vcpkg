vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nuspell/nuspell
    REF v3.0.0
    SHA512 d9cd7dd276e2bca43dec3abaf11c5206695949b9fda8c9b86f2772cc7e8fa95bf17c685a2ef9ca87fe3c4f0b55f2fcb435bc21c187355f5e3fa35dcafab2c8c2
    HEAD_REF master
    PATCHES cmake-disable-cli-and-docs.patch
)

# To remove the patch so the CLI tool can be installed, one has to install the
# executables under /tools, not /bin. This is specific only to vcpkg.

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
