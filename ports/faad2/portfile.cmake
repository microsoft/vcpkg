vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knik0/faad2
    REF 043d37b60cdded2abed7c4054f954e # 2_9_1
    SHA512 8658256bbcb3ce641eef67c4f5d22d54b348805a06b2954718a44910861a9882371c887feb085060c524f955993ae26c211c6bb4fb8d95f9e9d1d0b5dca0ebe4
    HEAD_REF master
    PATCHES
        0001-Fix-non-x86-msvc.patch    # https://github.com/knik0/faad2/pull/42
        0002-Fix-unary-minus.patch     # https://github.com/knik0/faad2/pull/43
        0003-Initialize-pointers.patch # https://github.com/knik0/faad2/pull/44
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    build-decoder   FAAD_BUILD_BINARIES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
