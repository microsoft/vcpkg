set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARMmbed/mbedtls
    REF d65aeb37349ad1a50e0f6c9b694d4b5290d60e49 # v3.1.0
    SHA512 a3fde5e6e206d0ab43282502fec45da14f1ccb24974db7a9348a18870d3c07b10fe72419ebf5130cec1b9e819ef804608b0f7b48670f619e328f5b798a8d9eb1
    HEAD_REF development
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
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_TESTING=OFF
        -DENABLE_PROGRAMS=OFF
        -DMBEDTLS_FATAL_WARNINGS=FALSE
)

vcpkg_cmake_install()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if (VCPKG_TARGET_IS_WINDOWS AND pthreads IN_LIST FEATURES)
    file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
endif ()

vcpkg_copy_pdbs()
