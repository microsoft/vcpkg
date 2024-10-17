# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF "${VERSION}"
    SHA512 fd1612a2689e7e54bcbebb0b9da7d20aa6fe2fce395d544d476136d8de7f63a638bbbbab1bc2d00991649bcdf66ee6493ffdeed28c42121f98c82ee208c35947
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADERS_SRC "${SOURCE_PATH}/src/*.hpp")
file(GLOB HEADERS_MLPACK "${SOURCE_PATH}/src/mlpack/*.hpp")
file(COPY ${HEADERS_SRC} DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY ${HEADERS_MLPACK} DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack")
file(COPY "${SOURCE_PATH}/src/mlpack/methods/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack/methods")
file(COPY "${SOURCE_PATH}/src/mlpack/core/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack/core")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT.txt")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
