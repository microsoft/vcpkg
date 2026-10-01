vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yunsmall/usbipdcpp
    REF "v${VERSION}"
    SHA512 05d81b967bff76be5bd40b5cd826e10d20bd1651dff3a0f6a10e1934578b80d6bc7a40d3669127c1fd651c9945cf6dc4e89edd62dcf8821a4ab5a0ba507a2a81
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
