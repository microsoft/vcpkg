if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO quickjs-ng/quickjs
    REF v${VERSION}
    SHA512 39870b7dbe82ffe4cf9ae25b9aa653af536c83460302126b3e868a29cf657d0f1206fd66eebbc37dd46c5bb991c8b00230f6850bf743561bc1f48233c45c327b
    HEAD_REF master
    PATCHES
        pdb_name_conflict.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libc          QJS_BUILD_LIBC
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/quickjs PACKAGE_NAME qjs)

vcpkg_copy_tools(
    TOOL_NAMES qjs qjsc
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
