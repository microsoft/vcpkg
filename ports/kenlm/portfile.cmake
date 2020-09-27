vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kpu/kenlm
    REF a900efaee160c80dc19ec065f603d7f1d28196ed
    SHA512 8c2b86670df0266d1dc411dfda7ce568a27461c889fb4bbdb6b9d11fc42a62ef3e7e61d464ef4015dd04355fca1cc44ed4d0d589bf789a5e8320b9126d35fb9f
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
