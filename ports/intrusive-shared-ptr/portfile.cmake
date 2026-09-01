set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gershnik/intrusive_shared_ptr
    REF "v${VERSION}"
    SHA512 0a80f6c21c54e8b263a7929334ef1df97d5dfb4f70d08a8b080ff82a99b0965f7414ac5381d12575d18db0f94cb06e946644da2a50aa3aaf26a2de34d33fa322
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "-DBUILD_TESTING=OFF"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME isptr)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
