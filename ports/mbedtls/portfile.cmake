set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARMmbed/mbedtls
    REF "v${VERSION}"
    SHA512 72a25a6b2a132545d32c7a6819bde569a315f2e83049467653af6347c918e4781462dceca21c64c76a4af7d19cedaf968f48b3f0309a6b0289466c087e49dd38
    HEAD_REF mbedtls-2.28
    PATCHES
        enable-pthread.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pthreads ENABLE_PTHREAD
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_TESTING=OFF
        -DENABLE_PROGRAMS=OFF
        -DMBEDTLS_FATAL_WARNINGS=FALSE
)

vcpkg_cmake_install()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if (VCPKG_TARGET_IS_WINDOWS AND pthreads IN_LIST FEATURES)
    file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
endif ()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
