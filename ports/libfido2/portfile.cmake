vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Yubico/libfido2
    REF 1.10.0
    SHA512 ba03e25d3f42f11cec74dee48c853ae35d03600f24ca06d2b751840408a132290fe22461372ae42ae31419061a63d9908c20a2c0cf3c0c9c8dbc46c34916784f
    HEAD_REF master
    PATCHES
        "fix_cmakelists.patch"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBFIDO2_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBFIDO2_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_MANPAGES=OFF
        -DBUILD_STATIC_LIBS=${LIBFIDO2_BUILD_STATIC}
        -DBUILD_SHARED_LIBS=${LIBFIDO2_BUILD_SHARED}
        -DBUILD_TOOLS=OFF
 )

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
