vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/alkimia
    REF "v${VERSION}"
	SHA512 ec7867e439178d6ed104c388c60bfe0bad223a9e35f4d9e05f2a7b3b2b2badac74b9a872f7922f58bb2b7a1127da742c430eff7caca71388085abdd1ad12cb1d
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools       BUILD_TOOLS
        webengine   BUILD_WITH_WEBENGINE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUNDLE_INSTALL_DIR=bin
        -DBUILD_TESTING=OFF
        -DBUILD_WITH_WEBKIT=OFF
        -DBUILD_APPLETS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=1
        -DCMAKE_DISABLE_FIND_PACKAGE_MPIR=1
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        BUNDLE_INSTALL_DIR
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/LibAlkimia5-8.1 PACKAGE_NAME libalkimia5)
vcpkg_fixup_pkgconfig()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES onlinequoteseditor5 AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LIB")
