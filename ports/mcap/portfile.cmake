vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foxglove/mcap
    REF "releases/cpp/v${VERSION}"
    SHA512 cbd518e10b9a276b2a46eafe02e2693328555605cb8d21f7db8263b69a85c0d0062d2d77b759aba2d8dfcf41d571744cc34f0193dc47987b512cd021e2ab2650
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

