if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
    set(_static_runtime ON)
else()
    set(_static_runtime OFF)
endif()

# Libtorrent exports TORRENT_ABI_VERSION=2 when deprecated-functions is enabled,
# and 100 otherwise. Public headers use this value to select their ABI:
# https://github.com/arvidn/libtorrent/blob/56ae8caba38bf154ffc210403cb23f91d0ecaa49/CMakeLists.txt#L738-L741
if("deprfun" IN_LIST FEATURES)
    set(_torrent_abi_version 2)
else()
    set(_torrent_abi_version 100)
endif()

# Libtorrent exports TORRENT_USE_RTC=0 when WebTorrent is disabled. When enabled,
# config.hpp defaults it to 1, so no explicit definition is emitted:
# https://github.com/arvidn/libtorrent/blob/56ae8caba38bf154ffc210403cb23f91d0ecaa49/CMakeLists.txt#L749-L750
if("webtorrent" IN_LIST FEATURES)
    set(_torrent_use_rtc 1)
else()
    set(_torrent_use_rtc 0)
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        deprfun     deprecated-functions
        examples    build_examples
        python      python-bindings
        test        build_tests
        tools       build_tools
        webtorrent  webtorrent
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arvidn/libtorrent
    REF "v${VERSION}"
    SHA512 5563939466e4240849fd24b1eec394b56f39f71ebae9a26fd858e638e819c78c856afb6146963e998e2e1355eaed56b74f27228980ceed1c53ad189cf3fc2b80
    HEAD_REF RC_2_1
    PATCHES
        use-system-libdatachannel.patch
        fix-shared-extra-exports.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH TRYSIGNAL_SOURCE_PATH
    REPO arvidn/try_signal
    REF 105cce59972f925a33aa6b1c3109e4cd3caf583d
    SHA512 4a0090755831e0e4a1930817345fa5934144421d9a9d710fe8ed3712233fa2fa037fc0e0d4f88b7cc8fb1bc05fe2d55372af1ff47d6fbf5208e03f45f2a424e4
    HEAD_REF master
)

file(COPY "${TRYSIGNAL_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/deps/try_signal")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dstatic_runtime=${_static_runtime}
        -Dgnutls=OFF
)

vcpkg_cmake_install()

# These mirror libtorrent's public target compile definitions for this port's
# fixed OpenSSL configuration. TORRENT_USE_LIBCRYPTO also selects the public
# lcrypto inline namespace, so headers must define it to match the library ABI.
# https://github.com/arvidn/libtorrent/blob/56ae8caba38bf154ffc210403cb23f91d0ecaa49/CMakeLists.txt#L769-L784
set(_torrent_header_config [=[
#ifndef TORRENT_USE_OPENSSL
#define TORRENT_USE_OPENSSL
#endif
#ifndef TORRENT_USE_LIBCRYPTO
#define TORRENT_USE_LIBCRYPTO
#endif
#ifndef TORRENT_SSL_PEERS
#define TORRENT_SSL_PEERS
#endif
#ifndef TORRENT_ABI_VERSION
#define TORRENT_ABI_VERSION @_torrent_abi_version@
#endif
#ifndef TORRENT_USE_RTC
#define TORRENT_USE_RTC @_torrent_use_rtc@
#endif
]=])
string(CONFIGURE "${_torrent_header_config}" _torrent_header_config @ONLY)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    # Libtorrent exports this definition when building torrent-rasterbar shared:
    # https://github.com/arvidn/libtorrent/blob/56ae8caba38bf154ffc210403cb23f91d0ecaa49/CMakeLists.txt#L549-L554
    string(APPEND _torrent_header_config [=[
#ifndef TORRENT_LINKING_SHARED
#define TORRENT_LINKING_SHARED
#endif
]=])
endif()
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/libtorrent/config.hpp"
    "#define TORRENT_CONFIG_HPP_INCLUDED"
    "#define TORRENT_CONFIG_HPP_INCLUDED\n${_torrent_header_config}"
)

vcpkg_cmake_config_fixup(
    PACKAGE_NAME LibtorrentRasterbar
    CONFIG_PATH lib/cmake/LibtorrentRasterbar
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/include/libtorrent/aux_/puff.hpp"
        "${TRYSIGNAL_SOURCE_PATH}/LICENSE"
)

file(
    REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/cmake"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(
        REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

vcpkg_fixup_pkgconfig()
