vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/fswatch
    REF ee32afdf4c1168fddb59ec095e5aacd925e9889e
    SHA512 364a889de2eaf04c8706aab7949b642bdbbcea35133db1954746d57af6ce14dcbf1bb273a9187bae90e6868b05a259851c7b5ddf34df6222452e9d814277d4a3
    HEAD_REF multi-os-ci
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/COPYING"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/libfswatch"
     RENAME copyright)
