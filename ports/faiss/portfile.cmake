vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookresearch/faiss
    REF v1.7.4
    SHA512 9622fb989cb2e1879450c2ad257cb55d0c0c639f54f0815e4781f4e4b2ae2f01779f5c8c0738ae9a29fde7e418587e6a92e91240d36c1ca051a6228bfb777638
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
