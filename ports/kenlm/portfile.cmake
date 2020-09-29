vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kpu/kenlm
    REF ac454207c69f293315ae9be3aff2238fc8c999a0
    SHA512 96f35c46237870ce71c04e20783b4d410e7dfec6eb10673e29aa9ba27f95c5ad77aafd443a1583cd7b757a8c360fc16f236ef8ecf965f317c24c8f3b45547722
    HEAD_REF master
    PATCHES fix-build-install.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/modules/FindEigen3.cmake)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    interpolate ENABLE_INTERPOLATE
)

if ("interpolate" IN_LIST FEATURES AND VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "Feature interpolate only support unix.")
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

set(KENLM_TOOLS count_ngrams filter fragment kenlm_benchmark lmplz phrase_table_vocab)
if (NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND KENLM_TOOLS probing_hash_table_benchmark query build_binary interpolate streaming_example)
endif()
vcpkg_copy_tools(TOOL_NAMES ${KENLM_TOOLS} AUTO_CLEAN)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Copyright and License
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME license)
