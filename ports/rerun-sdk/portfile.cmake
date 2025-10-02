# Must download SDK distfile because some binaries are prebuilt from Rust.
vcpkg_download_distfile(
    ARCHIVE
    URLS "https://github.com/rerun-io/rerun/releases/download/${VERSION}/rerun_cpp_sdk.zip"
    FILENAME "rerun_cpp_sdk_${VERSION}.zip"
    SHA512 580033c8016c6f966270f909df16ae1b3bcb8392db6b5e5f63330d5adcd59908d72238158dc8efbf91b0f54d3e65d197f328218501899f008a2cbaeb95c7daad
)

# Workaround: The distributed SDK contains a prebuilt rerun_c that is built in Release mode.  On Windows, this means
# that it always links to the release MSVC C runtime (CRT) and causes vcpkg's post-build CRT linkage check to fail for
# Debug builds.  As such, this post-build check is suppressed for Windows builds.
if(VCPKG_TARGET_IS_WINDOWS)
    # TODO: Remove this policy when rerun ships a Debug rerun_c.
    set(VCPKG_POLICY_SKIP_CRT_LINKAGE_CHECK enabled)
endif()

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
