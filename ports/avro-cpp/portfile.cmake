vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/avro
    REF e44b680621328c4e6524bd2983af1ce11afeebed
    SHA512 932f642f272997b5c0be467d3a3ccc354c6edf425c36b33aa7e61984f67312c712bb1d74cb1a5fd8066169104851e73830f0ed3fdb450e005a5c5bef33c34f20
    HEAD_REF master
    PATCHES
        install.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test               BUILD_TESTING
    INVERTED_FEATURES
        snappy             CMAKE_DISABLE_FIND_PACKAGE_Snappy
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/lang/c++"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/lang/c++/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
