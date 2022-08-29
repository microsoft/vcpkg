vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tbeu/matio
    REF e9e063e08ef2a27fcc22b1e526258fea5a5de329 # v1.5.23
    SHA512 78b13f4796870158f5cf2b8234c0ab6dc8b449cba49608ce40c51a3f91994c33c29b8a6de1ceed94a81fc7faa798d8c3a45a275f3a3abba70a0cd7be731e1d9c
    HEAD_REF master
    PATCHES fix-dependencies.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hdf5            MATIO_WITH_HDF5
        zlib            MATIO_WITH_ZLIB
        extended-sparse MATIO_EXTENDED_SPARSE
        mat73           MATIO_MAT73
        pic             MATIO_PIC
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DMATIO_SHARED=${BUILD_SHARED}
        -DMATIO_USE_CONAN=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES matdump AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
