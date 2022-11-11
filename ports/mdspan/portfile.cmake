vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kokkos/mdspan
    REF mdspan-0.4.0
    SHA512 9452bed074401b5bbaea7ff6e318e1b631ba8a9b4c6e6c8d05f82be9b24055026645a501963b0443b211833124228499d2acf7fb0ff79c48a43e0ea198dba0af
    HEAD_REF stable
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mdspan)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
