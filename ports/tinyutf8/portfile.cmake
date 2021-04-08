vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DuffsDevice/tinyutf8
    REF 68eaf247a3761c324b1a3806a954d773dfe9106b
    SHA512 e8bd51ea66a84d236be7c2028b6f3a67b5b01f0fac758729f3152542c8a6a859ddb3f72d6c5abb058c909bf84862ed816e2235cfde6bfa7edaa8026a4f7f4b2a
    HEAD_REF master
    PATCHES fixbuild.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" TINYUTF8_BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DTINYUTF8_BUILD_STATIC=${TINYUTF8_BUILD_STATIC}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENCE ${CURRENT_PACKAGES_DIR}/share/tinyutf8/copyright COPYONLY)

# remove unneeded files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
