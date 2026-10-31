vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/sonnet
    REF "v${VERSION}"
    SHA512 2d06bc82d692741ef8438303309616fb9c9fbd5a86ed453d52b1e04ec7c73f43edae76c679002c0af05bd46266be68b0fd81c7acdef24dd5eb720c548d1a8ca6
    HEAD_REF master
    PATCHES
        use-given-parsetrigrams.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        designerplugin BUILD_DESIGNERPLUGIN
        hunspell       CMAKE_REQUIRE_FIND_PACKAGE_HUNSPELL
        qml            SONNET_USE_QML
    INVERTED_FEATURES
        hunspell       CMAKE_DISABLE_FIND_PACKAGE_HUNSPELL
        translations   KF_SKIP_PO_PROCESSING
)

if("hunspell" IN_LIST FEATURES)
    # FindHUNSPELL.cmake gets the version from pkg-config, to select the hunspell API
    vcpkg_find_acquire_program(PKGCONFIG)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")
elseif(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_OSX)
    list(APPEND FEATURE_OPTIONS -DSONNET_NO_BACKENDS=ON)
endif()

# parsetrigrams generates the trigrams used to guess the language.
# The host executable is passed whenever the triplet is different from the host one, not just when
# crosscompiling.
set(install_options "")
if(VCPKG_CROSSCOMPILING)
    list(APPEND FEATURE_OPTIONS "-DPARSETRIGRAMS_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/parsetrigrams6${VCPKG_HOST_EXECUTABLE_SUFFIX}")
else()
    set(install_options ADD_BIN_TO_PATH)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ASPELL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_HSPELL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_VOIKKO=ON
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DKDE_INSTALL_QMLDIR=qml
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        SONNET_NO_BACKENDS
)

vcpkg_cmake_install(${install_options})
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6sonnet CONFIG_PATH lib/cmake/KF6Sonnet)

if(NOT VCPKG_CROSSCOMPILING)
    vcpkg_copy_tools(TOOL_NAMES parsetrigrams6 AUTO_CLEAN)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
