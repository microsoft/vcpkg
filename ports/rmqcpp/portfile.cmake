vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bloomberg/rmqcpp
    REF 093aaa1db711eb7d29fded9df72d8c3213daa1b6
    SHA512 4158fbdca42a94188130291563d1000185b47b94f59894153647d7d3ad29025bc04e8328ceed4176890bdf9f020d47ef37abe46af5d631b7e31e5db4c865f47e
    HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBDE_BUILD_TARGET_CPP17=ON
    -DCMAKE_CXX_STANDARD=17
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -DBDE_BUILD_TARGET_SAFE=ON
    -DCMAKE_INSTALL_LIBDIR=lib64
)

vcpkg_cmake_build()

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
