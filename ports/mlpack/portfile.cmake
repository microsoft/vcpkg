# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF "${VERSION}"
    SHA512 899a70f76bee626ef00993bedea188f8a2e9db5f0faec41cf125607b7c4bbda16d0e0343aac757618cd48fcb520f968539a8a97d89cf577037f69c624caf8bc6
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADERS "${SOURCE_PATH}/src/*.hpp"  "${SOURCE_PATH}/src/mlpack/*.hpp")
file(COPY ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack")
file(COPY "${SOURCE_PATH}/src/mlpack/methods/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack/methods")
file(COPY "${SOURCE_PATH}/src/mlpack/core/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack/core")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT.txt")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
