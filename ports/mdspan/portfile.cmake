vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kokkos/mdspan
    REF mdspan-0.5.0
    SHA512 f14b021006f945434435c5575a734bcf308598b5c21fd62a54248ad6c5b1ffe29ba4bcf57935751f5c8dd3dd9b56bd799a502c4818f06f8594a32f0202b1b52e
    HEAD_REF stable
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mdspan)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
