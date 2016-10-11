include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/spdlog-0.11.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/gabime/spdlog/archive/v0.11.0.zip"
    FILENAME "v0.11.0.zip"
    SHA512 4e759b8a18d0e3f256d974920260ebb6c6792885651290637a8a7210731e1d24a6f662d7dc7d3ae165a78c6e738229bd4b6922f36df26581bf43c8bca7c90314
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/share
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/spdlog/ ${CURRENT_PACKAGES_DIR}/share/spdlog/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spdlog)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/spdlog/LICENSE ${CURRENT_PACKAGES_DIR}/share/spdlog/copyright)
