include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(VERSION 1.3.1)

vcpkg_download_distfile(ARCHIVE
    URLS "http://lemon.cs.elte.hu/pub/sources/lemon-${VERSION}.zip"
    FILENAME "lemon-${VERSION}.zip"
    SHA512 86d15914b8c3cd206a20c37dbe3b8ca4b553060567a07603db7b6f8dd7dcf9cb043cca31660ff1b7fb77e359b59fac5ca0aab57fd415fda5ecca0f42eade6567
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
    PATCHES
        "cmake.patch"
        "fixup-targets.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLEMON_ENABLE_GLPK=OFF
        -DLEMON_ENABLE_ILOG=OFF
        -DLEMON_ENABLE_COIN=OFF
        -DLEMON_ENABLE_SOPLEX=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/lemon/cmake TARGET_PATH share/lemon)

file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(COPY ${EXE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/liblemon/)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/liblemon)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblemon RENAME copyright)
