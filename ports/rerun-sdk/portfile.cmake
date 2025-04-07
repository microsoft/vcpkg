# Must download SDK distfile because some binaries are prebuilt from Rust.
vcpkg_download_distfile(
    ARCHIVE
    URLS "https://github.com/rerun-io/rerun/releases/download/${VERSION}/rerun_cpp_sdk.zip"
    FILENAME rerun_cpp_sdk.zip
    SHA512 1351dd0937d6ddf73622b69a803a7233eb92e5ec52607fc1c775accd015d52eaf3259c0aea64cfac3109f1c55218fb6a4597bff5b067ccdd194cd8695b3f4c8c
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ARROW_LINK_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DRERUN_DOWNLOAD_AND_BUILD_ARROW=OFF # Disable downloading and building Arrow
    -DRERUN_ARROW_LINK_SHARED=${ARROW_LINK_SHARED} # Enable shared linking if not static
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME rerun_sdk CONFIG_PATH "lib/cmake/rerun_sdk")

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(LIBRERUN_C_FILE "rerun_c__win_x64.lib")
    else()
        message(FATAL_ERROR "Unsupported Windows architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(LIBRERUN_C_FILE "librerun_c__linux_x64.a")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(LIBRERUN_C_FILE "librerun_c__linux_arm64.a")
    else()
        message(FATAL_ERROR "Unsupported Linux architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(LIBRERUN_C_FILE "librerun_c__macos_x64.a")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(LIBRERUN_C_FILE "librerun_c__macos_arm64.a")
    else()
        message(FATAL_ERROR "Unsupported macOS architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/rerun_sdk/rerun_sdkConfig.cmake"
    "${SOURCE_PATH}/lib/${LIBRERUN_C_FILE}"
    "\${CURRENT_PACKAGES_DIR}/lib/${LIBRERUN_C_FILE}"
)
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/rerun_sdk/rerun_sdkConfig.cmake"
    "set(RERUN_LIB_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../..\")"
    "set(RERUN_LIB_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../lib\")"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE-MIT"
    "${SOURCE_PATH}/LICENSE-APACHE"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")