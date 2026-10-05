vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrtulka23/scinumtools3
    REF v0.9.1
    SHA512 4461662145e8790ad521d2ac60b9d10edf18ac6ab869a72669651c77bf84305cef842a8311843ee72424c3d8e180ed3e308c830770afbe95a91bb3b45fa8302e
    PATCHES
        use-vcpkg-imgui-glfw.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        report ENABLE_SNT_REPORT
        server ENABLE_SNT_SERVER
        viewer ENABLE_SNT_VIEW
)

if("report" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH BRIEFPP_SOURCE_PATH
        REPO vrtulka23/briefpp
        REF 624aa478149a0fa0e7213bb7cfb6d19615d6e771
        SHA512 1697cef47f04dd2105f0026ff36ee200ea86e450e38f58403d11f5eb213e82bba2b5b16d1d887599b518f0e1906a1cc56aebc6f76bb5cc7e150603b6a55476a1
    )
    set(SNT_BRIEFPP_OPTION -DSNT_BRIEFPP_INCLUDE_DIR=${BRIEFPP_SOURCE_PATH}/include)
endif()

if("server" IN_LIST FEATURES)
    set(SNT_HTTPLIB_OPTION -DSNT_HTTPLIB_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DENABLE_UNIT_TESTS=OFF
        -DENABLE_BINDING_PYTHON=OFF

        -DENABLE_CORE=ON
        -DENABLE_EXS=ON
        -DENABLE_VAL=ON
        -DENABLE_PUQ=ON
        -DENABLE_DIP=ON
        -DENABLE_MAT=OFF
        -DENABLE_API=ON

        -DENABLE_EXEC_APPS=ON
        -DENABLE_EXEC_APPS_SNT=ON
        ${FEATURE_OPTIONS}
        -DENABLE_SNT_DMAP=OFF
        ${SNT_BRIEFPP_OPTION}
        -DENABLE_EXEC_EXAMPLES=OFF
        -DENABLE_EXEC_BENCHMARKS=OFF
    OPTIONS_RELEASE
        ${SNT_HTTPLIB_OPTION}
    OPTIONS_DEBUG
        -DENABLE_EXEC_APPS=OFF
        -DENABLE_EXEC_APPS_SNT=OFF
        -DENABLE_SNT_SERVER=OFF
        -DENABLE_SNT_VIEW=OFF
        -DENABLE_SNT_DMAP=OFF
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES snt AUTO_CLEAN)

vcpkg_cmake_config_fixup(
    PACKAGE_NAME snt
    CONFIG_PATH lib/cmake/snt
)

# Headers should only be installed once.
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
