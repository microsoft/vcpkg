vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tbeu/matio
    REF ca56394e5672115df1981996ed12524d1d551259 # v1.5.19
    SHA512 67c239d8aabafaa935775f3b260ba0756c196b0d845ef5116365c9aa6a0b24dae70d92c4e74d5d43ae073ae0744f084f0f58ead864eb77c813d43dbbb3e4ec5e
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
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DMATIO_SHARED=${BUILD_SHARED}
        -DMATIO_USE_CONAN=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES matdump AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
