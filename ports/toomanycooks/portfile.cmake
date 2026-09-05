set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tzcnt/TooManyCooks
    REF e3e1e5f399a9c02ad3665ad87b181e868ce8f8c0
    SHA512 17e0aff92c848009793f4712202764e3d0ec2ed388a8b807cc31e12977b1dc2bdf9f2ac67177c9dc1bfac2691c721eecbef8bfffeb79539d0d48464697da539d
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DTMC_USE_HWLOC=ON
    -DTMC_USE_BOOST_ASIO=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME TooManyCooks CONFIG_PATH lib/cmake/TooManyCooks)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/licenses"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
