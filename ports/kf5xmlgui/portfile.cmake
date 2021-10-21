vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kxmlgui
    REF v5.84.0
    SHA512 39657ec545c1463cadec719e7c6dc546fb6d1804b5c2b86904bfffd01be173c3ead1533ec33f749343f5575785394fe659ca0be51af706911e5176d485ef7f20
    HEAD_REF master
    PATCHES
        remove_explicit_shared_argument.patch # https://invent.kde.org/frameworks/kxmlgui/-/commit/d12e8f6266188ce7e221dc014a56071b8a5ef706
        add_support_for_static_builds.patch   # https://invent.kde.org/frameworks/kxmlgui/-/commit/2f1b948ad690942d4ec208c5676c11218f29181a
        fix_static_resources.diff             # https://invent.kde.org/frameworks/kxmlgui/-/merge_requests/77
)

vcpkg_check_features(
     OUT_FEATURE_OPTIONS FEATURE_OPTIONS
     FEATURES
         designerplugin BUILD_DESIGNERPLUGIN
 )

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5XmlGui CONFIG_PATH lib/cmake/KF5XmlGui)
vcpkg_copy_pdbs()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(
        TOOL_NAMES ksendbugmail
        AUTO_CLEAN
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")	
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")	
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")