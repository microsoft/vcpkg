vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oclero/qlementine
    REF "v${VERSION}"
    SHA512 e6c2fb7855cf6152330d225b971fa8f2c2fd7b0c73ce10e1c55129606762632ae4ff4bddf23cb034dc19bd00d82f186663190d16923058eb4c2423d7c34e38a3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQLEMENTINE_SANDBOX=OFF
        -DQLEMENTINE_SHOWCASE=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/qlementine)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
