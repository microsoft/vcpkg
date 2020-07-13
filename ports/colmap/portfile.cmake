vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO colmap/colmap
    REF 3.6-dev.3
    SHA512 7eec27fced20f43547e67e9824d33c8412b17c2c80d29d8346d583cef3f7598b59c7c10a0556b857e31106c9312aace54c5dee65b8465974930f35b58331304a
    HEAD_REF dev
)

set(CUDA_ENABLED OFF)
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    cuda CUDA_ENABLED
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(INSTALL     ${SOURCE_PATH}/COPYING.txt
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
     RENAME copyright
)
