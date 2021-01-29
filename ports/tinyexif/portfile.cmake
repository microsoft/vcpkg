vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/TinyEXIF
    REF c57a5fec1a847ec0e7b482b2da72e1f04fc2e147
    SHA512 a968e79b4b7a6f5f189328a8dc493da5c0d568526b5dca46b9bfc0cf85295fb348bd0b38828fedbb7b6e4467fc8932d0d7b435b4acbfe662e954cbed1d0ea914
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DBUILD_DEMO=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/TinyEXIF)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyexif RENAME copyright)
