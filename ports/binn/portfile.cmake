vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liteserver/binn
    REF b657ef3f38b37aa1e5dea88a9332889d0fbf3a81 # 3.0
    SHA512 14bf572152ec5343a161dea9ebfd2b63cd5ce48c0db3decf5591aa94ae7766771cf521ba22978e9ae8855feef694bad85951f3c4a29cb9ddd881918fc6d3722a
    HEAD_REF master
    PATCHES
        0001_fix_uwp.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

file(INSTALL "${SOURCE_PATH}/src/binn.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/binn")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
