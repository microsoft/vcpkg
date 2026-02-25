if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF v${VERSION}
    SHA512 7eea385d79d88a5690cde131fe7ccda97d5c54ea09d6f515000d7bf07c828809d61c1ac99912c1ee507cf933f61c1c47ecdcc45df7850ffa82714034b0fccf35
    HEAD_REF devel
    PATCHES
        fix-install-path.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        thread-safe-assertions CATCH_CONFIG_EXPERIMENTAL_THREAD_SAFE_ASSERTIONS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -DCATCH_INSTALL_DOCS=OFF
        -DCMAKE_CXX_STANDARD=17
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Catch2)
vcpkg_fixup_pkgconfig()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/catch2-with-main.pc" [["-L${libdir}"]] [["-L${libdir}/manual-link"]])
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/catch2-with-main.pc" [["-L${libdir}"]] [["-L${libdir}/manual-link"]])
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# We remove these folders because they are empty and cause warnings on the library installation
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/catch2/benchmark/internal")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/catch2/generators/internal")

file(WRITE "${CURRENT_PACKAGES_DIR}/include/catch.hpp" "#include <catch2/catch_all.hpp>")

# Copy pdb files to lib folders
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
  # Catch2 builds static libraries even when shared libraries are requested.
  # We thus cannot use vcpkg_copy_pdbs which only works for dlls but have to search for the pdbs manually.
  file(GLOB_RECURSE catch2_pdb_files "${CURRENT_BUILDTREES_DIR}/*.pdb")
  list(FILTER catch2_pdb_files INCLUDE REGEX ".*${TARGET_TRIPLET}.*")
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(catch2_release_pdb_files ${catch2_pdb_files})
    list(FILTER catch2_release_pdb_files INCLUDE REGEX ".*${TARGET_TRIPLET}-rel.*")
    file(COPY ${catch2_release_pdb_files} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  endif()
  if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(catch2_debug_pdb_files ${catch2_pdb_files})
    list(FILTER catch2_debug_pdb_files INCLUDE REGEX ".*${TARGET_TRIPLET}-dbg.*")
    file(COPY ${catch2_debug_pdb_files} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
  endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
