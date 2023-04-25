vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kpu/kenlm
    REF 1f054617eca14eae921e987b4b4eeb2b1d91de6b
    SHA512 c18f9c22fbbb1f54ebe9c3b771fb2d7c09d502141d1b3645cff9db44cc51b3c976311ff0db79b60f410622579d043f185c56a4c7386e1b0ba8708e433238968b
    HEAD_REF master
    PATCHES 
        fix-boost.patch
        fix-const-overloaded.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/modules/FindEigen3.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
    interpolate ENABLE_INTERPOLATE
)

if ("interpolate" IN_LIST FEATURES AND VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "The interpolate feature does not support Windows.")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFORCE_STATIC=OFF #already handled by vcpkg
        -DENABLE_PYTHON=OFF # kenlm.lib(bhiksha.cc.obj) : fatal error LNK1000: Internal error during IMAGE::Pass2
        -DCOMPILE_TESTS=OFF
)
vcpkg_cmake_install()

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

# Copyright and License
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME license)
