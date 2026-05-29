set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sebsjames/maths
    REF "${VERSION}"
    SHA512 4f0b9b2a799dcffb32237e54919256704aa1b082ecee7e4e9c1ed3d69f68e33111887065c9ea1979c1f92feb2e24106a816a5fca67e9e8bb9ab423e0057001d5
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
