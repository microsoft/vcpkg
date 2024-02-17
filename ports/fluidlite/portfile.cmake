vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO divideconcept/FluidLite
    REF d59d2328818f913b7d1a6a59aed695c47a8ce388
    SHA512 d08ddd0b61dc16c26e5ebc8e54e2efef163f8d0b4da6ce4a040b49756feb105220d48ec6238568b00c68dfa244fac0ab53e3c59c066d4b92dc248df3715c388c
    PATCHES
        fix-dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sf3     ENABLE_SF3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME fluidlite
    CONFIG_PATH lib/cmake/fluidlite
)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
