vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kpu/kenlm
    REF 5bf7b46558e1c5595bf3b8c9b0b1f9d8d257040a
    SHA512 04b645d09e60b65cb1e5065a1623ad01737f0dd9415cf620288ace0db10b1c424d72f304b34c52fa08684f3fecdaad9db91088134f34ed374cb1eb9d58c635b5
    HEAD_REF master
    PATCHES 
        fix-boost.patch
        fix-boost-imported-targets.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/modules/FindEigen3.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        interpolate ENABLE_INTERPOLATE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFORCE_STATIC=OFF #already handled by vcpkg
        -DENABLE_PYTHON=OFF # kenlm.lib(bhiksha.cc.obj) : fatal error LNK1000: Internal error during IMAGE::Pass2
        -DCOMPILE_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT}/cmake)

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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/LICENSE")
