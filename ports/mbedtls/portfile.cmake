set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARMmbed/mbedtls
    REF "v${VERSION}"
    SHA512
 e2de0260341c7e2be7f1dcc2bde48b2287272528de3a9e7d7b4c8468b74a6530d4e84b2a4e959dff46169c34d70c908ec58b33f67db151129d5a3c0c6b34b297
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
