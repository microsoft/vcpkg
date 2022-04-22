vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF bf42276c5a44eed31e5bacec95d166d01d65f9a4 #v2.18.1
    SHA512 09f96b2f0e0bd34245c34ee727e633bbb3957c2ab8076cfac66f976ba4e327096e2e76fadcc729dfffe73b56348bcc14fa61e3bb59a7ca0e17221f8f4cd0d59c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ensmallen)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/COPYRIGHT.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
