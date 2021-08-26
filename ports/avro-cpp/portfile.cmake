vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/avro
    REF 2ab8fa85d05f04387bd5d63b10ad1c8fd2243616
    SHA512 fd21f0919b0e5e884bdf4d66c4d5ba056f04c426b309ec0b5ab26642a5f6b00d46f4dd965431b10130bc5f0d81699e2195780e90e127f63049ee5763403ef7c8
    HEAD_REF master
    PATCHES
        install.patch
        fix-windows-build.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
    snappy     CMAKE_DISABLE_FIND_PACKAGE_Snappy
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/lang/c++
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DAVRO_ADD_PROTECTOR_FLAGS=1
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/lang/c++/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
