vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookresearch/faiss
    REF "v${VERSION}"
    SHA512 739641644a6a0b12430ab172fdd7c657b4c88e6389688c359919e2286bb494ff2011a33905719dc9dd95116c7c834f76969c457b67104223447ac04de339000d
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
        -DFAISS_ENABLE_MKL=OFF
        -DFAISS_ENABLE_PYTHON=OFF  # Requires SWIG
        -DFAISS_ENABLE_EXTRAS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
