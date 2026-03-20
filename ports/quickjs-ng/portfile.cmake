if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO quickjs-ng/quickjs
    REF v${VERSION}
    SHA512 c9e27746287571603db0ab5b5af5d8d1e7784bd0d70dbc549a2d5ea34378b512d695a19a561e8763218919b6cbbd494664660835aabfc96d0379905aa2dceedf
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
