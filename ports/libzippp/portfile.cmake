vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ctabin/libzippp
    REF 791bdc43eb18b87e3bdfa087493e3e32217e672c #v4.0-1.7.3 with CXX std version c++11
    SHA512 c6a90ecec21bb2d9e3af681c35d7eec0bee7b356fc1438004dc84be32ee7b94d047c35817d46b222237d54699ea54afa4fd3ae5deeba40dfce4fd2035a38b0e5
    HEAD_REF libzippp-v4.0-1.7.3
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    encryption LIBZIPPP_ENABLE_ENCRYPTION
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBZIPPP_BUILD_TESTS=OFF
    OPTIONS_DEBUG
        -DLIBZIPPP_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake/libzippp")
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH "share/libzippp")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)