vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eranpeer/FakeIt
    REF "${VERSION}"
    SHA512 3575dc2247a97ea6d3c584e9b933e32cc0d1936fec480b19caf8305e8ba39bb11b4437930a5343b343df66347354ef5aaa8d2811e0ff3119bfc619629a0c2b8b
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_INSTALL_INCLUDEDIR=include/fakeit/single_header
        -DENABLE_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FakeIt)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
