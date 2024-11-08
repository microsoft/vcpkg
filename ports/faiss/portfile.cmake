vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookresearch/faiss
    REF "v${VERSION}"
    SHA512 38d4215e3e019915d8b367ff0e8d14901b1495f6f45b835e9248276567a422b0370baab6bd887045442dd1e268b7fe7c347107162e66bb3ec6b1a53be4b2e441
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
