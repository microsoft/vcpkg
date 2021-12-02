vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Yubico/libfido2
    REF 1.7.0
    SHA512 f40d394883d909e9e3ea3308b32f7ca31a882c709e11b3b143ed5734d16b0c244d4932effe06965d566776b03d152b1fc280e73cdfeeb81b65d8414042af19fe
    HEAD_REF master
    PATCHES
        "fix_cmakelists.patch"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBFIDO2_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBFIDO2_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
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

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
