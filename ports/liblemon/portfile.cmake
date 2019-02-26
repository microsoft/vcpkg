include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("Dynamic linkage not supported. Building static instead.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

set(VERSION 1.3.1)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lemon-${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "http://lemon.cs.elte.hu/pub/sources/lemon-${VERSION}.zip"
    FILENAME "lemon-${VERSION}.zip"
    SHA512 86d15914b8c3cd206a20c37dbe3b8ca4b553060567a07603db7b6f8dd7dcf9cb043cca31660ff1b7fb77e359b59fac5ca0aab57fd415fda5ecca0f42eade6567
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/cmake.patch
        ${CMAKE_CURRENT_LIST_DIR}/fixup-targets.patch
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
