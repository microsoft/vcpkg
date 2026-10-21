vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chadaustin/cpptoml
    REF "v${VERSION}"
    SHA512 80fa659b529b242e02ae233d2870b666c3c7cfd9d6d6bb9d07cd5539d7778c8809e614b46a3d4cf97f9a2b0b5d5f953bba170fb1d95b5b920c395f3df52f2c9a
    HEAD_REF master
)

if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    list(APPEND OPTIONS -DENABLE_LIBCXX=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -DCPPTOML_BUILD_EXAMPLES=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
