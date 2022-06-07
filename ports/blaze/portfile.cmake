vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blaze-lib/blaze
    REF v3.8.1
    SHA512 6dfd3cb46d796b94cc44a30c4cd5ebfb366d2eb312d75a28787cacb4636df52e4e4e3dce3d9501bf2c07e7fd3621e8ce7f9ffa61a950a4146375b12d75d4872b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBLAZE_SMP_THREADS=OpenMP
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/blaze/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
