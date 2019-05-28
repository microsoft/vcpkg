include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/collada-dom-2.5.0)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdiankov/collada-dom
    REF 6b39635f7b929f68f15993002e177d075485f21a
    SHA512 a0f8e712dd97b3bf9f0a18aa9acd0f1c15daed0dd0597849b00de707dd24ef6fef89e4fe61d06824b0f23dd3b0d873e6460d127d6193e3d85377368157231184
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