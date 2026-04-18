vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LibVNC/libvncserver
    REF "LibVNCServer-${VERSION}"
    SHA512 3ad7e14eef3b591574714e320257ac465778e05bd157ddff09e48b990f35890bfa6883ce4ac027fcb08dccd96f721117d56aaee681482f7643cfee9adc59804b
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBVNCSERVER_BUILD_SHARED)

if(VCPKG_TARGET_IS_WINDOWS)
    foreach(disabled_feature IN ITEMS systemd xcb gtk qt)
        if(disabled_feature IN_LIST FEATURES)
            message(FATAL_ERROR "Feature '${disabled_feature}' is not supported on Windows triplets.")
        endif()
    endforeach()
endif()

set(LIBVNCSERVER_EXAMPLE_BACKEND_FEATURES
    ffmpeg
    gtk
    libsshtunnel
    qt
    sdl
    xcb
)

foreach(example_backend_feature IN LISTS LIBVNCSERVER_EXAMPLE_BACKEND_FEATURES)
    if(example_backend_feature IN_LIST FEATURES)
        list(APPEND FEATURES examples)
        break()
    endif()
endforeach()

if("tests" IN_LIST FEATURES)
    list(APPEND FEATURES examples)
endif()

if("tightvnc-filetransfer" IN_LIST FEATURES)
    list(APPEND FEATURES threads)
endif()

if("prefer-win32threads" IN_LIST FEATURES)
    list(APPEND FEATURES threads)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    allow-24bpp WITH_24BPP
    examples WITH_EXAMPLES
    ffmpeg WITH_FFMPEG
    gcrypt WITH_GCRYPT
    gnutls WITH_GNUTLS
    gtk WITH_GTK
    ipv6 WITH_IPv6
    jpeg WITH_JPEG
    libsshtunnel WITH_LIBSSHTUNNEL
    lzo WITH_LZO
    png WITH_PNG
    prefer-win32threads PREFER_WIN32THREADS
    qt WITH_QT
    sasl WITH_SASL
    sdl WITH_SDL
    ssl WITH_OPENSSL
    systemd WITH_SYSTEMD
    tests WITH_TESTS
    threads WITH_THREADS
    tightvnc-filetransfer WITH_TIGHTVNC_FILETRANSFER
    vncclient WITH_LIBVNCCLIENT
    vncserver WITH_LIBVNCSERVER
    websockets WITH_WEBSOCKETS
    xcb WITH_XCB
    zlib WITH_ZLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=${LIBVNCSERVER_BUILD_SHARED}
        -DWITH_LIBVNCSERVER=OFF
        -DWITH_LIBVNCCLIENT=OFF
        -DWITH_ZLIB=OFF
        -DWITH_LZO=OFF
        -DWITH_JPEG=OFF
        -DWITH_PNG=OFF
        -DWITH_EXAMPLES=OFF
        -DWITH_TESTS=OFF
        -DWITH_GTK=OFF
        -DWITH_QT=OFF
        -DWITH_SDL=OFF
        -DWITH_LIBSSHTUNNEL=OFF
        -DWITH_THREADS=OFF
        -DPREFER_WIN32THREADS=OFF
        -DWITH_FFMPEG=OFF
        -DWITH_XCB=OFF
        -DWITH_SASL=OFF
        -DWITH_SYSTEMD=OFF
        -DWITH_GNUTLS=OFF
        -DWITH_GCRYPT=OFF
        -DWITH_TIGHTVNC_FILETRANSFER=OFF
        -DWITH_24BPP=OFF
        -DWITH_IPv6=OFF
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
