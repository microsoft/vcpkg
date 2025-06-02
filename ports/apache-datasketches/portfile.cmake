vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/datasketches-cpp
    REF "${VERSION}"
    SHA512 3be2480390bff9ec62d92885174dc5cb7e86c9e5f8215ee57e77626151002d614d41254d532e53c7e1d509b420ee0024edfcea6043caa1b9863d100f492096cd
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME DataSketches CONFIG_PATH lib/DataSketches/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
