if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oliora/ppconsul
    REF v${VERSION}
    SHA512 217bb0f29291973cba8a87830028050a986ff06461f491d1bfe28f1eeb8d02939a8e8037188e2bb20fa1d592be4a21257ed5f995f61da0510cd1c46ffd0d5c68
    HEAD_REF master
    PATCHES 
        cmake_build.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/ext/b64")
file(REMOVE_RECURSE "${SOURCE_PATH}/ext/catch")
file(REMOVE_RECURSE "${SOURCE_PATH}/ext/json11")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCMAKE_CXX_STANDARD=17
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
vcpkg_fixup_pkgconfig()

file(READ "${CURRENT_PACKAGES_DIR}/share/ppconsul/ppconsulConfig.cmake" cmake-config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/ppconsul/ppconsulConfig.cmake" "include(CMakeFindDependencyMacro)
find_dependency(Boost COMPONENTS
    fusion
    mpl
    optional
    preprocessor
    variant
)
find_dependency(CURL)
find_dependency(unofficial-b64 CONFIG)

${cmake-config}"
)


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
