include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DuffsDevice/tinyutf8
    REF v2.1.1
    SHA512 0be9cebe1ac962c89e0620586d4f8d4f3059b52394e13506f19723855d146c35e6a1205ae5430a53ba95a89c60216054bfad9c4e8e8f1ec047f4096585de2efc
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
