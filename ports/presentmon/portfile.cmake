# The upstream doesn't export any symbols
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "linux" "osx" "uwp" "ios" "android" "freebsd")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GameTechDev/PresentMon
    REF 47669ad0efaddc9787772d5e4900734417b2c07c # 1.7.0
    SHA512 fac2e2ca4d8476e2cdde7c3f77cf1881b7d7a9208387f12dbf07f3ea7f4012ce79602f4fedbf1e778871fd9ce898b101659a6f192de29dc6a4404213aee444be
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
