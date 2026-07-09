vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yunsmall/usbipdcpp
    REF "v${VERSION}"
    SHA512 21a390d1f093a5b6416fba31693323011411152f077f8e64c07b179905c1648cf16f8526e4a7843a8701b2a91f1c6f92cbaa00aaec3f550edd166e993b0d1a2e
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        physical-usb-forwarding USBIPDCPP_BUILD_LIBUSB_COMPONENTS
        virtual-device          USBIPDCPP_BUILD_VIRTUAL_DEVICE
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(SHARED_OPTION -DUSBIPDCPP_BUILD_SHARED_LIBS=ON)
else()
    set(SHARED_OPTION -DUSBIPDCPP_BUILD_SHARED_LIBS=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSBIPDCPP_BUILD_EXAMPLES=OFF
        -DUSBIPDCPP_BUILD_TESTS=OFF
        ${SHARED_OPTION}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME usbipdcpp CONFIG_PATH lib/cmake/usbipdcpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
