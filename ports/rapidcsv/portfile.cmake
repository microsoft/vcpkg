vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO d99kris/rapidcsv
    REF v8.53
    SHA512 64a6100f1adf90eeaa4a513fbcf4ffd611a40b1f41b6e88eeda6c73c360e26c5a7cc6fc68a65bb2dff5f72ba663a976d2922e3114468dbd8c291c7eef211ae1f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
