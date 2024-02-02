vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/alkimia
    REF 8f21e4f5154f6d390609174783705ccc0559dc59
    SHA512 c03ac5b52c858dbc6c71a4c5c3908057dba0c6094e33441f93490f2b1e7bd3b516d141b9ef3c50b11fc8002c129280b274721e38972cd76c7092a2f555a13975
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
        -DBUILD_DOXYGEN_DOCS=OFF
        -DBUILD_WITH_WEBKIT=OFF
        -DBUILD_APPLETS=OFF
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        BUNDLE_INSTALL_DIR
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME LibAlkimia5 CONFIG_PATH lib/cmake/LibAlkimia5-8.1)
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
