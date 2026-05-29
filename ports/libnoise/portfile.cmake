set( LIBNOISE_VERSION "1.0.0" )
set( LIBNOISE_COMMIT "d7e68784a2b24c632868506780eba336ede74ecd" )

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RobertHue/libnoise
    REF ${LIBNOISE_COMMIT}
    SHA512 8c4d654acb4ae3d90ee62ebdf0447f876022dcb887ebfad88f39b09d29183a58e6fc1b1f1d03edff804975c8befcc6eda33c44797495285aae338c2e869a14d7
    HEAD_REF master
    PATCHES fix-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_WALL=ON
        -DBUILD_SPEED_OPTIMIZED=ON
        -DBUILD_LIBNOISE_DOCUMENTATION=OFF
        -DBUILD_LIBNOISE_UTILS=ON
        -DBUILD_LIBNOISE_EXAMPLES=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-noise CONFIG_PATH share/unofficial-noise)
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-noiseutils CONFIG_PATH share/unofficial-noiseutils)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/noise/module/modulebase.h
        "if NOISE_STATIC" "if 1" )
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)