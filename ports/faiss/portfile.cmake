vcpkg_fail_port_install(ON_ARCH "x86" ON_TARGET "uwp" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookresearch/faiss
    REF a17a631dc326b3b394f4e9fb63d0a7af475534dc # v1.6.3
    SHA512 f1ab5b3c4bb89d26c0bc425b59deb42c614d58c8c0d14447dc91db6428e9efe7e7e469d7e2ad3d00e1f068ae8ed997e6a9555e6b8427ab785f63637c2cd947a9 
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

file(INSTALL ${SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
     RENAME copyright
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
