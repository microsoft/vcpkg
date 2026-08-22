# Must download SDK distfile because some binaries are prebuilt from Rust.
vcpkg_download_distfile(
    ARCHIVE
    URLS "https://github.com/rerun-io/rerun/releases/download/${VERSION}/rerun_cpp_sdk.zip"
    FILENAME "rerun_cpp_sdk_${VERSION}.zip"
    SHA512 b77366df2c032bb3033dde38740f202fc90fbd21f518c70971153f4d47aa9bf8e17d20f678b682c66cec54f5cf63abe784829b1d569af08758e922dcd3bb47ea
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

# The upstream install rule globs every header in the source tree, which sweeps in a vendored copy of cxxopts that no
# part of rerun-sdk includes.  Upstream considers it accidental (see rerun-io/rerun#5133).  Remove the unused, vendored
# third-party libraries since they provide no functional benefit.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/rerun/third_party")

# rerun_c is prebuilt and statically links a large Rust dependency tree, so those licenses have to be acknowledged.
# Provide instructions for how to obtain these licenses per the vcpkg maintainer guide.
string(CONCAT RERUN_LICENSE_COMMENT
    "The prebuilt rerun_c static library contains statically linked Rust dependencies.  Their licenses and "
    "corresponding copyright notices can be obtained by checking out the matching Rerun release at "
    "https://github.com/rerun-io/rerun/tree/${VERSION} and running `cargo-about` against "
    "`crates/top/rerun_c/Cargo.toml`."
)

vcpkg_install_copyright(
    COMMENT "${RERUN_LICENSE_COMMENT}"
    FILE_LIST
        "${SOURCE_PATH}/LICENSE-MIT"
        "${SOURCE_PATH}/LICENSE-APACHE"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
