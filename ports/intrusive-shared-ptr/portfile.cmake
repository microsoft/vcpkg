set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gershnik/intrusive_shared_ptr
    REF "v${VERSION}"
    SHA512 f4e8ebf58d4a51e04c951cef7f8726094a3f3892df582871c3f44d1b39cb289ccb4d3919e454527fadd5efeb69a186df9de4d0c1746a230cdb44ae7f8380ed4d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/isptr PACKAGE_NAME isptr)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
