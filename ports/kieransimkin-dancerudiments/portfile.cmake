vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_download_distfile(ARCHIVE
    URLS "https://files.pythonhosted.org/packages/61/2e/c2d0e6ce012c5cf320bdb3e7749336cfd082706ac6c3e4ee6af9b19d1fa7/dancerudiments-0.2.4.tar.gz"
    FILENAME "dancerudiments-0.2.4.tar.gz"
    SHA512 51c10813eebc136a37c5eb0c3d50bc08d1a2ecc612abf7692f1d7b7c69247691071cf424bcc66b36490ece3517cf2db24c25efc712fcc5d31b07b2f220eb70f9
)
vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDANCERUDIMENTS_BUILD_TESTS=OFF
        -DDANCERUDIMENTS_BUILD_PYTHON=OFF
        -DDANCERUDIMENTS_BUILD_C_ABI=OFF
        -DDANCERUDIMENTS_BUILD_WASM=OFF
        -DDANCERUDIMENTS_BUILD_DEMO_TOOLS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME DanceRudiments CONFIG_PATH lib/cmake/DanceRudiments)
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/collections/initial/THIRD_PARTY_NOTICES.md"
    "${SOURCE_PATH}/collections/initial/sources/d3-ease/LICENSE"
    "${SOURCE_PATH}/python/dancerudiments_authoring/packs/THIRD_PARTY_NOTICES.md"
)
