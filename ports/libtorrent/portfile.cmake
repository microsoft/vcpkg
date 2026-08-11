if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
    set(_static_runtime ON)
else()
    set(_static_runtime OFF)
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

vcpkg_cmake_config_fixup(
    PACKAGE_NAME LibtorrentRasterbar
    CONFIG_PATH lib/cmake/LibtorrentRasterbar
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

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