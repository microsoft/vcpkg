include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cyan4973/xxHash
    REF 810f9d209b65cc523c159ca96fddd614d890a5e2
    SHA512 2d7a06a5cabc945ac841df4451a744f0a666e4afcce77f5eea70bd68547ac46ebf776dd0e3645ef0204c7ff1dea3f5ff8228a8d9894dae0077f865ffdc123c66
    HEAD_REF dev)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake_unofficial
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xxhash)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xxhash/LICENSE ${CURRENT_PACKAGES_DIR}/share/xxhash/copyright)
