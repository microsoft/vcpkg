vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LibVNC/libvncserver
    REF "LibVNCServer-${VERSION}"
    SHA512 3ad7e14eef3b591574714e320257ac465778e05bd157ddff09e48b990f35890bfa6883ce4ac027fcb08dccd96f721117d56aaee681482f7643cfee9adc59804b
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBVNCSERVER_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=${LIBVNCSERVER_BUILD_SHARED}
        -DWITH_LIBVNCSERVER=ON
        -DWITH_LIBVNCCLIENT=ON
        -DWITH_EXAMPLES=OFF
        -DWITH_TESTS=OFF
        -DWITH_GTK=OFF
        -DWITH_QT=OFF
        -DWITH_SDL=OFF
        -DWITH_FFMPEG=OFF
        -DWITH_XCB=OFF
        -DWITH_SASL=OFF
        -DWITH_SYSTEMD=OFF
        -DWITH_GNUTLS=OFF
        -DWITH_GCRYPT=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/LibVNCServer" PACKAGE_NAME LibVNCServer)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
