vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kpu/kenlm
    REF bdf3c71a34a874de11ab02f23ebe0a0b877c27ef
    SHA512 3782cf4b08b5686ea320fa248012c780faa0417fa5b23f2645bc8c92f7741ec8b8c7f81cd3f58676b1d1ea5817d1b56eaffa608ea993e3d213b63fcba44e2afb
    HEAD_REF master
    PATCHES 
        fix-boost.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/modules/FindEigen3.cmake)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    interpolate ENABLE_INTERPOLATE
)

if ("interpolate" IN_LIST FEATURES AND VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "The interpolate feature does not support Windows.")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFORCE_STATIC=OFF #already handled by vcpkg
        -DENABLE_PYTHON=OFF # kenlm.lib(bhiksha.cc.obj) : fatal error LNK1000: Internal error during IMAGE::Pass2
        -DCOMPILE_TESTS=OFF
)
vcpkg_install_cmake()

set(KENLM_TOOLS count_ngrams filter fragment kenlm_benchmark lmplz phrase_table_vocab query build_binary)
if (NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND KENLM_TOOLS probing_hash_table_benchmark)
    if ("interpolate" IN_LIST FEATURES)
        list(APPEND KENLM_TOOLS interpolate)
    endif()
endif()
vcpkg_copy_tools(TOOL_NAMES ${KENLM_TOOLS} AUTO_CLEAN)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Copyright and License
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME license)
