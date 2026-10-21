set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sebsjames/maths
    REF "${VERSION}"
    SHA512 2723179f328e9e79c58e7fc24f0e43db321be48d48b8197e0565bab8bda81aa9f1347866e111201908d54a9f6fb8824fb28912c065ac636ef1cd8e1d84f6dc3e
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_HDF5=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Armadillo=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Eigen3=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/maths)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
