include(vcpkg_common_functions)

message(WARNING "${PORT} requires C++17 or later to compile.")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vectorclass/version2
    REF v2.00.01
    SHA512 2e1f714cf0e23cf7986f0e78b4c1eeab4da6434ac92449b81990931e19ae189df6fbbef50f11e9532a41dc6eaff0a4fea840349a3747621ff537bbd7519f2c3d
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
   example VCL_BUILD_EXAMPLE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}   
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)