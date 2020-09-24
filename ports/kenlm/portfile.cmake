vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kpu/kenlm
    REF 689a25aae9171b3ea46bd80d4189f540f35f1a02
    SHA512 a1d3521b3458c791eb1242451b4eaafda870f68b5baeb359549eba10ed69ca417eeaaac95fd0d48350852661af7688c6b640361e9f70af57ae24d261c4ac0b85
    HEAD_REF master
    PATCHES fix-build-install.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/modules/FindEigen3.cmake)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    test COMPILE_TESTS
)

if ("test" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_WINDOWS)
        message(FATAL_ERROR "Feature test only support unix.")
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
         ${FEATURE_OPTIONS}
        -DFORCE_STATIC=OFF #already handled by vcpkg
        -DENABLE_PYTHON=OFF # kenlm.lib(bhiksha.cc.obj) : fatal error LNK1000: Internal error during IMAGE::Pass2
)
vcpkg_install_cmake()

set(KENLM_TOOLS count_ngrams filter fragment kenlm_benchmark lmplz phrase_table_vocab)
if (NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND probing_hash_table_benchmark query build_binary)
endif()
vcpkg_copy_tools(TOOL_NAMES ${KENLM_TOOLS} AUTO_CLEAN)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Copyright and License
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME license)
