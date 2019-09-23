include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/value-ptr-lite
    REF v0.2.1
    SHA512  96bea32310b3b3f91d19706d8ae9bdfa9a6ba485f529562e3b7cf89311d1e9b99fd24c0c6f23d169c5a7c84ebd9bd7b8ace972ee279b38c4c1caa398a3dd1590
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    test BUILD_TESTS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS
        -DVALUE_PTR_LITE_OPT_BUILD_TESTS=${BUILD_TESTS}
        -DVALUE_PTR_LITE_OPT_BUILD_EXAMPLES=OFF   
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/value_ptr-lite)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
