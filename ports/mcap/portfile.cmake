vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foxglove/mcap
    REF "releases/cpp/v${VERSION}"
    SHA512 5f0c87174c940277212f8e4935f8f60faab37a3679d685a7c7a5b90579733970277f07c69326e1140e362f7d0187f43b2a920ed19e33ff99a1a300e22cf6eafe
    HEAD_REF main
)

file(INSTALL
    "${SOURCE_PATH}/cpp/mcap/include/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

# Set compile definitions, dependencies, and link libraries based on the configured features
set(MCAP_COMPILE_DEFINITIONS "")
set(MCAP_FIND_DEPENDENCIES "")
set(MCAP_LINK_LIBRARIES "")
if("lz4" IN_LIST FEATURES)
    list(APPEND MCAP_LINK_LIBRARIES lz4::lz4)
    list(APPEND MCAP_FIND_DEPENDENCIES lz4)
else()
    list(APPEND MCAP_COMPILE_DEFINITIONS MCAP_COMPRESSION_NO_LZ4)
endif()
if("zstd" IN_LIST FEATURES)
    list(APPEND MCAP_LINK_LIBRARIES zstd::libzstd)
    list(APPEND MCAP_FIND_DEPENDENCIES zstd)
else()
    list(APPEND MCAP_COMPILE_DEFINITIONS MCAP_COMPRESSION_NO_ZSTD)
endif()
list(JOIN MCAP_COMPILE_DEFINITIONS " " MCAP_COMPILE_DEFINITIONS)
list(JOIN MCAP_FIND_DEPENDENCIES " " MCAP_FIND_DEPENDENCIES)
list(JOIN MCAP_LINK_LIBRARIES " " MCAP_LINK_LIBRARIES)

set(_LIB_NAME unofficial-mcap)
set(_LIB_TARGET unofficial::mcap::mcap)
set(_PACKAGE_CONFIG_DIR "${CURRENT_PACKAGES_DIR}/share/${_LIB_NAME}")
configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/${_LIB_NAME}Config.cmake.in
    ${_PACKAGE_CONFIG_DIR}/${_LIB_NAME}Config.cmake
    @ONLY
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/cpp/mcap/LICENSE"
)

