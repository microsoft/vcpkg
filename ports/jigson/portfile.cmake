vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JoshuaSledden/Jigson
    REF "${VERSION}"
    SHA512 88cbd9d83d4b51b508c4d778ed5a230c6723274121e09170dff17aaaca01e1df0705f0b06e0ef395bd02aa85ad3da49fb60e1742935fb329afad713bd18b97dc
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
