vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_download_distfile(ARCHIVE
    URLS "https://files.pythonhosted.org/packages/d1/cb/037c41889e0c58867aee88bbb5033d410e8bf36b7370bfa02a01a221262d/dancerudiments-0.3.0.tar.gz"
    FILENAME "dancerudiments-0.3.0.tar.gz"
    SHA512 1c4ce46783f32180abdfeedcf6ed30fa01b4b7628140148ddfc311a07c3c039febdd67436ebddcfc4eacdd0ef4b682a370696d7f9d1bc3c2667f4271e4ddf767
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
