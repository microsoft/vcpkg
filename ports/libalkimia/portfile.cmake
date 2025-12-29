vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/alkimia
    REF "v${VERSION}"
	SHA512 8b9691058d1180294b8130f4f62fa32aa1040fe0af4f42ac1b41ae1dc526f3b2365f2a6175ea720f93b1eac7a5d46908b9655c8efa77d36d5f17595f24a7adcd
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        webengine   BUILD_WITH_WEBENGINE
        tools       BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DKDE_INSTALL_QMLDIR=qml
        -DBUNDLE_INSTALL_DIR=bin
        -DBUILD_TESTING=OFF
        -DBUILD_WITH_WEBKIT=OFF
        -DBUILD_APPLETS=OFF
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        BUNDLE_INSTALL_DIR
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME LibAlkimia5 CONFIG_PATH lib/cmake/LibAlkimia5-8.2)
vcpkg_copy_pdbs()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES onlinequoteseditor5 AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
