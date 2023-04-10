# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF ${VERSION}
    SHA512 4a3a3c8c770a67f949252f664837f0bbfd0c4ef073536c6b2d28cd127cf514e08ab524bdec44559ac14ced65ba48d9c2ab99b16651649cfd100e92932ab126bb
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADERS "${SOURCE_PATH}/src/*.hpp"  "${SOURCE_PATH}/src/mlpack/*.hpp")
file(COPY ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack")
file(COPY "${SOURCE_PATH}/src/mlpack/methods/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack/methods")
file(COPY "${SOURCE_PATH}/src/mlpack/core/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack/core")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT.txt")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
