# Must download SDK distfile because some binaries are prebuilt from Rust.
vcpkg_download_distfile(
    ARCHIVE
    URLS "https://github.com/rerun-io/rerun/releases/download/${VERSION}/rerun_cpp_sdk.zip"
    FILENAME rerun_cpp_sdk.zip
    SHA512 2ddeb2447ac890c124fdfd3ff84719a03590366ea59bb14decdda525c70317fe1f7b1ee8fbbc45059d0c5e50eab20b023ec38d6168968ea342253793a7b7ab40
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRERUN_DOWNLOAD_AND_BUILD_ARROW=OFF # Disable downloading and building Arrow
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME rerun_sdk CONFIG_PATH "lib/cmake/rerun_sdk")

file(GLOB LIBRERUN_C_FILE
    RELATIVE "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/lib/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}rerunc_c_-*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
)

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/rerun_sdk/rerun_sdkConfig.cmake"
    "set(RERUN_LIB_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../..\")"
    "set(RERUN_LIB_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../lib\")"
)

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/rerun_sdk/rerun_sdkConfig.cmake"
    "${SOURCE_PATH}/lib/${LIBRERUN_C_FILE}"
    "\${CMAKE_CURRENT_LIST_DIR}/../../lib/${LIBRERUN_C_FILE}"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE-MIT"
    "${SOURCE_PATH}/LICENSE-APACHE"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
