vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO agruzdev/Yato
    REF 9b5a49f6ec4169b67b9e5ffd11fdae9c238b0a3d
    SHA512 41962839cd13a314a17fef5f6065d7c3ed9967832039ca31993105685d584307d00f17c1514f4acf855a71fd884a1104c2d9c6a4461be5d2d7cfdc50b1ea7bdb
    HEAD_REF master
)

# Copy all header files
file(COPY "${SOURCE_PATH}/include/yato"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)
file(COPY "${SOURCE_PATH}/modules/actors/yato"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)
file(COPY "${SOURCE_PATH}/modules/config/yato"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DYATO_BUILD_TESTS:BOOL=OFF
        -DYATO_BUILD_ACTORS:BOOL=ON
        -DYATO_BUILD_CONFIG:BOOL=ON
)

vcpkg_cmake_build()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
