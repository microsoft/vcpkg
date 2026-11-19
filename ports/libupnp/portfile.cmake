vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pupnp/pupnp
    REF "release-${VERSION}"
    SHA512 ae4e904948dff2e471f741db14aeeb25dcd8cac912a0f7dd24b278bc9b7fb74a14ed346a38759bdd865e1cba404ae9a71bd79c851e3bb2fef0dc03674053bd00
    PATCHES
        fix-pthreads4w-targets.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBUPNP_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBUPNP_BUILD_SHARED)

if(LIBUPNP_BUILD_STATIC)
    set(UPNP_TARGET "Static")
else()
    set(UPNP_TARGET "Shared")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    client-api      UPNP_ENABLE_CLIENT_API
    ipv6            UPNP_ENABLE_IPV6
    ssl             UPNP_ENABLE_OPEN_SSL
    webserver       UPNP_ENABLE_WEBSERVER
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUPNP_BUILD_SAMPLES=OFF
        -DUPNP_BUILD_SHARED=${LIBUPNP_BUILD_SHARED}
        -DUPNP_BUILD_STATIC=${LIBUPNP_BUILD_STATIC}
        -DUPNP_ENABLE_BLOCKING_TCP_CONNECTIONS=OFF
        -DUPNP_ENABLE_DEVICE_API=${UPNP_ENABLE_WEBSERVER}
        -DUPNP_ENABLE_GENA=ON
        -DUPNP_ENABLE_SOAP=ON
        -DUPNP_ENABLE_SSDP=ON
        -DUPNP_ENABLE_TESTING=OFF
        -DUPNP_ENABLE_UNSPECIFIED_SERVER=OFF
        -DUPNP_MINISERVER_REUSEADDR=${UPNP_ENABLE_WEBSERVER}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/UPNP PACKAGE_NAME UPNP)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
