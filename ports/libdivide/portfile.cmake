include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ridiculousfish/libdivide
    REF v2.0
    SHA512 0599c6d6206d8a7273804f65e79c32df47b0e7de9703460201c2eb8a480542d88ad6d5d8b8135d576805892edfd88ef304249f51667088c8f8a9db4c32cbb9e2
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS
      -DLIBDIVIDE_SSE2=OFF
      -DLIBDIVIDE_AVX2=OFF
      -DLIBDIVIDE_AVX512=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)