vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO libcgroup/libcgroup
        SHA512 29fb7f5c795080cafc27ab99f2f3d7683933515840226564e047605e41a76f7ca31b48c8c9e8e1963eb808e3fc82206ea6ad550c80dcfb745b5cb7425e2875a9
        REF "v${VERSION}"
        HEAD_REF master
)

message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n"
        "\t- <autoconf>\n"
        "\t- <automake>\n"
        "\t- <libtool>\n\n"
        "It can be installed with your package manager"
)

vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            --enable-tools=no
            --enable-python=no
            --enable-tests=no
            --enable-samples=no
            --enable-systemd=no
            --enable-pam=no
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
