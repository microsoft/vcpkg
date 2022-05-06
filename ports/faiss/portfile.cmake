vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookresearch/faiss
    REF v1.7.2
    SHA512 dddf55af3cc73a15fbbd104ab75942194a4d5d088611bd98b11e459e034ba5df1d9247eb8c8b9f4631cc64c6ed284b2cf407041be7b6095f9395f9ac29d78df4
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gpu FAISS_ENABLE_GPU
)

if ("${FAISS_ENABLE_GPU}")
    if (NOT VCPKG_CMAKE_SYSTEM_NAME AND NOT ENV{CUDACXX})
        set(ENV{CUDACXX} "$ENV{CUDA_PATH}/bin/nvcc.exe")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFAISS_ENABLE_PYTHON=OFF  # Requires SWIG
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
