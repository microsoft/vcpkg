if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oliora/ppconsul
    REF 1a889ce54cc10be4186daa48ccf7003588ceaade
    SHA512 e583eee7f0f88a2d1c1daa4b5e8b6e66c46d6abaea2fdb558b5931241ff85bf327f758f38a524e0af1a023b09a4a503da50cd4e25af791b36a376048cd0d1ca1
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
