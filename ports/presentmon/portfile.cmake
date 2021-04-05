# The upstream doesn't export any symbols
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "linux" "osx" "uwp" "ios" "android" "freebsd")

set(PRESENTMON_VERSION 1.6.0)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GameTechDev/PresentMon
    REF 6ddc9e15d2ef169cdce954b589c1ba190b3a25bd # 1.6.0
    SHA512 2522b0e3218d4a6588531a09bc82631f14ad05c20f4560fe0574f00f2f5eece114ae04320f920eb52ba64173cea5cdf15bb223b7395c3782e4a6465afb5d9bec
    HEAD_REF main
)

file(COPY ${CURRENT_PORT_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    tools BUILD_TOOLS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES presentmon AUTO_CLEAN)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)