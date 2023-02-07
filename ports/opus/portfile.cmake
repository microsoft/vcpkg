vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/opus
    REF 5c94ec3205c30171ffd01056f5b4622b7c0ab54c
    SHA512 2423b1fc86d5b46c32d8e3bde5fc2b410a5c25c001995ce234a94a3a6c7a8b1446fdf19eafe9d6a8a7356fe0857697053db5eb8380d18f8111818aa770b4c4ea
    HEAD_REF master
    PATCHES fix-pkgconfig-version.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        avx AVX_SUPPORTED
)

set(ADDITIONAL_OPUS_OPTIONS "")
if(VCPKG_TARGET_IS_MINGW)
    set(STACK_PROTECTOR OFF)
    string(APPEND VCPKG_C_FLAGS "-D_FORTIFY_SOURCE=0")
    string(APPEND VCPKG_CXX_FLAGS "-D_FORTIFY_SOURCE=0")
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "^(ARM|arm)64$")
        list(APPEND ADDITIONAL_OPUS_OPTIONS "-DOPUS_USE_NEON=OFF") # for version 1.3.1 (remove for future Opus release)
        list(APPEND ADDITIONAL_OPUS_OPTIONS "-DOPUS_DISABLE_INTRINSICS=ON") # for HEAD (and future Opus release)
    endif()
elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
    set(STACK_PROTECTOR OFF)
else()
    set(STACK_PROTECTOR ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DPACKAGE_VERSION=1.3.1
        -DOPUS_STACK_PROTECTOR=${STACK_PROTECTOR}
        -DOPUS_INSTALL_PKG_CONFIG_MODULE=ON
        -DOPUS_INSTALL_CMAKE_CONFIG_MODULE=ON
        -DOPUS_BUILD_PROGRAMS=OFF
        -DOPUS_BUILD_TESTING=OFF
        ${ADDITIONAL_OPUS_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        OPUS_USE_NEON
        OPUS_DISABLE_INTRINSICS
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Opus)
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m)


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
