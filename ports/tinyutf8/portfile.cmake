include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DuffsDevice/tinyutf8
    REF 8dc06049d8bc4455145eaf647ce7a4733ba26557
    SHA512 00a11febc36f7bc7c6af60c7d43e558ea145ec9f3ef85cfe4bc53ef4d51e233e85c15159825aa684b5a003f04c48d3453256ebb572e810a75206e79c5c87f2d6
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
