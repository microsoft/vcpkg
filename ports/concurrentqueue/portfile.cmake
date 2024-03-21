# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/concurrentqueue
    REF v${VERSION}
    SHA512 a27306d1a7ad725daf5155a8e33a93efd29839708b2147ba703d036c4a92e04cbd8a505d804d2596ccb4dd797e88aca030b1cb34a4eaf09c45abb0ab55e604ea
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-concurrentqueue)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-concurrentqueue-config.in.cmake"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-concurrentqueue/unofficial-concurrentqueue-config.cmake"
    @ONLY
)

file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
