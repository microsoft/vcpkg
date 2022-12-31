vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libproxy/libproxy
    REF 8fec01ed4b95afc71bf7710bf5b736a5de03b343 #0.4.18
    SHA512 6367d21b8816d7e5e3c75ee124c230ec89abbffa09538b6700c9ae61be33629f864617f51a2317e18d2fb960b09e26cae0e3503d747112f23921d1910856b109
    HEAD_REF master
    PATCHES
        fix-tools-path.patch
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
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/Modules)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
          "${CMAKE_CURRENT_LIST_DIR}/usage"
          DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
