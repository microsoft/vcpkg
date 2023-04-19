vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rioki/c9y
    REF v0.7.0
    SHA512 1c68351a42cea3a5cc52e00d3828acb16d6a96dfc4b9bf53fa4f8090b691a6f5734e2bb219af5cc54bc997517434417a4567d133c5a589f247abe9de73ba1cac
    )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/c9y)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
