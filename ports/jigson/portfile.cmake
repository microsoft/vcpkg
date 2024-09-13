vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JoshuaSledden/Jigson
    REF "${VERSION}"
    SHA512 dba66846021eab6914adf1e4d6e5fcd0fa5b54edea91c27d4d116002776ea1c1bcb5a6fed6b4778959d0aa525098ac037134842b65499ab2367b5d767b3cea10
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/src/Include/*")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/jigson")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

configure_file("${CMAKE_CURRENT_LIST_DIR}/jigson-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/jigson-config.cmake" @ONLY)

# Copy usage examples
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
