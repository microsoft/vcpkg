vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ridiculousfish/libdivide
    REF v3.0
    SHA512 fae17a4125c3b17aeb37283d7bba9fea2e4d3b208861d6ed81a6cdcf5dbf3286cf676cedba99c73a16115cf8bf9dcbd2cf6a48ca52fb85d4b0b24024e53d055e
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    test BUILD_TESTS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS ${FEATURE_OPTIONS}
      -DLIBDIVIDE_SSE2=OFF
      -DLIBDIVIDE_AVX2=OFF
      -DLIBDIVIDE_AVX512=OFF
      -DENABLE_VECTOR_EXTENSIONS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright) 
