vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxml2
    REF 7c06d99e1f4f853e3c5b307c0dc79c8a32a09855
    SHA512 8879649231ab5288497b9ed56cfed3ffb288a689c739acfd7094ddefdd0e4c140c34ebc821d0ebf70322bddb8fb34b04af87ebae87ae2b235bf318945dcf9dc2
    HEAD_REF master
    PATCHES
        fix-uwp-build.patch
        fix-docs-path.patch
        fix-dependencies.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLIBXML2_WITH_ZLIB=ON
        -DLIBXML2_WITH_ICONV=ON
        -DLIBXML2_WITH_LZMA=ON
        -DLIBXML2_WITH_ZLIB=ON
        -DLIBXML2_WITH_ICU=OFF
        -DLIBXML2_WITH_THREADS=ON
        -DLIBXML2_WITH_PYTHON=OFF
        -DLIBXML2_WITH_PROGRAMS=ON
        -DLIBXML2_WITH_RUN_DEBUG=OFF
        -DLIBXML2_WITH_TESTS=OFF
    OPTIONS_DEBUG
        -DLIBXML2_WITH_DEBUG=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libxml2-2.9.10 TARGET_PATH share/libxml2)

vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES xmlcatalog xmllint AUTO_CLEAN)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${CURRENT_PORT_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
file(INSTALL ${SOURCE_PATH}/Copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)