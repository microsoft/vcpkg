set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARMmbed/mbedtls
    REF 8b3f26a5ac38d4fdccbc5c5366229f3e01dafcc0 # mbedtls-2.28.0
    SHA512 a5d2694ae87347be7ebf5c32b86d7bb809cc696b549947efb3d12d41d5f726d4f7caed3cc6ee3f3c9b9e46b3c42c4ce8a5f9741b1b0a3c644b6ae615d2f4c55a
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
