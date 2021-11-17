if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/sentencepiece
    REF v0.1.96
    SHA512 c3f23b483ebe148a37a01908f5624f06536efcba5609192957239d844244ab445d39e59b1b44b6df1f182166d58a6df38c046506ce45160a272f1e7f46c25010
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSPM_ENABLE_SHARED=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
if(NOT VCPKG_CMAKE_SYSTEM_NAME)
   file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/sentencepiece.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/sentencepieced.lib")
   file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/sentencepiece_train.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/sentencepiece_traind.lib")
endif()

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
