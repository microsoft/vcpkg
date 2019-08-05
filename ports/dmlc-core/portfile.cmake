include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dmlc/dmlc-core
    REF v0.3
    SHA512 eddec2e79ce2dc6da79cf310fe2985bc5097698342003fd0a799ae23a8f248ad0f84ade39edbd9c35dd8ec0f89d655684e7d3d474c17791df7293aedd67a856d
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA       
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
