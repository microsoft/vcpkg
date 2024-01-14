vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Caltech-IPAC/json5_parser
    REF 580bfe30c5ee5e06a0f536d7bddb75c07a29eda6 # 1.0.0
    SHA512 25cdbc02ed2e3b05f0644c3398230ab82ede093ed6f7d8f140a9810509dd05feab1187d62fc38818725a92c47029fe3dc5ecfdbe14e1e0a2ef314e925b369d59
    HEAD_REF master
	PATCHES 00001-fix-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/json5_parser"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/json5-parser)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
