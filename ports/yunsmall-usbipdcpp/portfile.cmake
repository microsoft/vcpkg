vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yunsmall/usbipdcpp
    REF "v${VERSION}"
    SHA512 636c715f21d3c379844d97b5d7c2e85f3b8811370e5086d44dadde5d1cc996b0acdc0cc5fc765fdf3081ce16915f8ad7b258a19b2d99b6278680c1d5488c6434
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
