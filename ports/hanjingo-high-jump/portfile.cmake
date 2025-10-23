vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanjingo/high-jump
    REF v${VERSION}
    SHA512 de21d3e9f8005164362257d3ff6503e3aa7b9fb96959a3e95d6e7593604b60435d11d1c7e2b4035709bbd0ec5aa9056789f3f934d14f60fbc76bfb4fcb9da379
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_LIB=OFF
        -DBUILD_EXAMPLE=OFF
        -DBUILD_TEST=OFF
        -DBUILD_BENCH=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
