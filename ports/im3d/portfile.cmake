vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO john-chapman/im3d
    REF 651220df4d595ff3d7ac5c1a64b3355774e86bc8
    SHA512 0a117bddcf2de51870367a0d6d2753d9b691466427c5942be448d9930fac41fd8502788d76162831686f50f880a6b0a7fad541a380598c830ff8f44670f29381
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DIM3D_SKIP_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT} CONFIG_PATH share/unofficial-${PORT})

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
