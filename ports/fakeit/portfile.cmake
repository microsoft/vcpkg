vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eranpeer/FakeIt
    REF "${VERSION}"
    SHA512 19ed2000837574598f72f28b42a4ecc7f3a7f46f69b744025521f6668da469fefbbf91f30d00460d3a7d72722fec2030d43365272953947bb530f04c707e5d65
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
