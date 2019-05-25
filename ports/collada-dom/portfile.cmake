include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/collada-dom-2.5.0)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdiankov/collada-dom
    REF 6b39635f7b929f68f15993002e177d075485f21a
    SHA512 f189d09e2396faa266734981bb7b5e91ec34b6faa9ad340206e769dae316496bf4271c129980668dc2756874dbb8c1157162197d0d3a74075e35200821875156
    HEAD_REF v2.5.0
    PATCHES
        vs-version-detection.patch
        use-uriparser.patch
		use-vcpkg-minizip.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/collada_dom-2.5")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/licenses/license_e.txt DESTINATION
             ${CURRENT_PACKAGES_DIR}/share/collada-dom
             RENAME copyright)