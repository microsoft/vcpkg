# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foxglove/mcap
    REF 07540999a18b63cd4a4433f3fb1bdb5384b93af9
    SHA512 a4d0232d428e03e59a74a10b17830566b4ce0b0a5e4f9a81137d3480accbd8ac4a4f7e2ad59a6f1660ffa4fccaaa75b5c1b9b8520743fdde33270eb1a8675e59
    HEAD_REF master
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

set(_LIB_NAME mcap)
set(_PACKAGE_CONFIG_DIR "${CURRENT_PACKAGES_DIR}/share/${_LIB_NAME}")
configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/${_LIB_NAME}Targets.cmake.in
    ${_PACKAGE_CONFIG_DIR}/${_LIB_NAME}Targets.cmake
    @ONLY
)
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

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage"
    COPYONLY
)
