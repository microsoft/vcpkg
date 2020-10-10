vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookresearch/faiss
    REF a17a631dc326b3b394f4e9fb63d0a7af475534dc # v1.6.3
    SHA512 78b85aa14d183e7e65bf79e70c2c13195728055957ca6c7618081097446aa9b8418d032ca6fc34d18461b8e9f080df88fe4eb62723f7044a794862c3e9efff56
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    gpu FAISS_ENABLE_GPU
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFAISS_ENABLE_PYTHON=OFF  # Requires SWIG
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

file(INSTALL     ${SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
     RENAME copyright
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
