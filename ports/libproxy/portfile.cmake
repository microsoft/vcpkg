vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libproxy/libproxy
    REF "${VERSION}"
    SHA512 1148d688a9f070273a1a2b110a788561789799089660292bbba59fbf0a9caf7d28cb039a9ccdcb935f752e1e34739b2d2f4c784b1bb3bbaa03d108e7b38a4754
    HEAD_REF master
    PATCHES
        support-windows.patch
        fix-install-py.patch
        fix-module-lib-name.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATICCRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bindings-csharp WITH_DOTNET
        bindings-python WITH_PYTHON2
        bindings-python WITH_PYTHON3
        bindings-perl   WITH_PERL
        bindings-vala   WITH_VALA
        tools           BUILD_TOOLS
        tests           BUILD_TESTING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DWITH_WEBKIT3=OFF
        -DWITH_KDE=${VCPKG_TARGET_IS_LINUX}
        -DMSVC_STATIC=${STATICCRT}
        -DWITH_GNOME3=OFF
    MAYBE_UNUSED_VARIABLES
        WITH_DOTNET
        WITH_PERL
        WITH_PYTHON2
        WITH_PYTHON3
        WITH_VALA
        MSVC_STATIC
        BUILD_TOOLS
        WITH_GNOME3
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/Modules)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES proxy AUTO_CLEAN)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
          "${CMAKE_CURRENT_LIST_DIR}/usage"
          DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
