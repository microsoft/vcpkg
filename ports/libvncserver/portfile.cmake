vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LibVNC/libvncserver
    REF "LibVNCServer-${VERSION}"
    SHA512 3ad7e14eef3b591574714e320257ac465778e05bd157ddff09e48b990f35890bfa6883ce4ac027fcb08dccd96f721117d56aaee681482f7643cfee9adc59804b
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBVNCSERVER_BUILD_SHARED)

if(VCPKG_TARGET_IS_WINDOWS)
    set(LIBVNCSERVER_PREFER_WIN32THREADS ON)
else()
    set(LIBVNCSERVER_PREFER_WIN32THREADS OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    gcrypt WITH_GCRYPT
    gnutls WITH_GNUTLS
    jpeg WITH_JPEG
    lzo WITH_LZO
    png WITH_PNG
    sasl WITH_SASL
    ssl WITH_OPENSSL
    systemd WITH_SYSTEMD
    tightvnc-filetransfer WITH_TIGHTVNC_FILETRANSFER
    websockets WITH_WEBSOCKETS
    zlib WITH_ZLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=${LIBVNCSERVER_BUILD_SHARED}
        -DWITH_ZLIB=OFF
        -DWITH_LZO=OFF
        -DWITH_JPEG=OFF
        -DWITH_PNG=OFF
        -DWITH_EXAMPLES=OFF
        -DWITH_TESTS=OFF
        -DWITH_GTK=OFF
        -DWITH_QT=OFF
        -DWITH_SDL=OFF
        -DWITH_THREADS=ON
        -DPREFER_WIN32THREADS=${LIBVNCSERVER_PREFER_WIN32THREADS}
        -DWITH_FFMPEG=OFF
        -DWITH_XCB=OFF
        -DWITH_SASL=OFF
        -DWITH_SYSTEMD=OFF
        -DWITH_GNUTLS=OFF
        -DWITH_GCRYPT=OFF
        -DWITH_TIGHTVNC_FILETRANSFER=OFF
        -DWITH_24BPP=ON
        -DWITH_IPv6=ON
        -DWITH_WEBSOCKETS=OFF
        -DWITH_OPENSSL=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/LibVNCServer" PACKAGE_NAME LibVNCServer)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
