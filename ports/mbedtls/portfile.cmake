set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARMmbed/mbedtls
    REF 869298bffeea13b205343361b7a7daf2b210e33d #3.2.1
    SHA512 49bf05b986746e73900dbe90701c1b8c8319cbf24fe09d5ffb395c33af1f692ccc8ef58e5212da818545541703b9a6843e3ee3cd88fb939fa93f79372a917a2d
    HEAD_REF mbedtls-2.28
    PATCHES
        #enable-pthread.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pthreads ENABLE_PTHREAD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DMBEDTLS_FATAL_WARNINGS=OFF
        -DGEN_FILES=OFF
        -DUNSAFE_BUILD=OFF
        -DDISABLE_PACKAGE_CONFIG_AND_INSTALL=OFF
        -DENABLE_PROGRAMS=OFF
        -DENABLE_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME MbedTLS CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
