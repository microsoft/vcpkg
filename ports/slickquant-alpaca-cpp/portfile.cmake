vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/alpaca-cpp
    REF "v${VERSION}"
    SHA512 f509b38d613ca8b08743ee704cc0dfc36d665225a8f535b95fd243616d92dd1a5e0411a91a98c6d03fc3d58c7685a61c03488fe24363197e344146d299f60cc3
    HEAD_REF main
    PATCHES
        use-vcpkg-dependencies.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES options-streaming BUILD_ALPACA_OPTIONS_STREAMING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_ALPACA_CORE=ON
        -DBUILD_ALPACA_BROKER=OFF
        -DBUILD_ALPACA_TESTS=OFF
        -DBUILD_ALPACA_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME alpaca-cpp CONFIG_PATH lib/cmake/alpaca-cpp
    DO_NOT_DELETE_PARENT_CONFIG_PATH)

if ("options-streaming" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(PACKAGE_NAME alpaca-options-streaming-cpp 
        CONFIG_PATH lib/cmake/alpaca-options-streaming-cpp)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/lib/cmake"
    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
