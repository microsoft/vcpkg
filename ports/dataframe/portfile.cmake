vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hosseinmoein/DataFrame
    REF 1.17.0
    SHA512 8f402c9298d50102984d4b52f830cd995cbbc1cb20f65a8d371e7b013e78c9211b40c2cec38dd97ecfe7d425d54fdaf8a876522db2dc6562194946fc73f7663b
    HEAD_REF master
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_TESTING:BOOL=OFF
)

vcpkg_install_cmake()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/dataframe)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/DataFrame TARGET_PATH share/dataframe)

endif()
vcpkg_fixup_pkgconfig()

file( REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

file( INSTALL
    ${SOURCE_PATH}/License DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)
