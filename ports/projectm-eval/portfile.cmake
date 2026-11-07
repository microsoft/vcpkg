vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO projectM-visualizer/projectm-eval
    REF "v${VERSION}"
    SHA512 "7d4d1c3bc980225ad070ab21f316d497cc617699b8ee2bc68284373651d62c667edeab234bdd2fa29a05664c90e9e6af04b747035a28ec463caa1bca36724284"
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DBUILD_NS_EEL_SHIM=ON
      -DCMAKE_DISABLE_FIND_PACKAGE_BISON=ON
      -DCMAKE_DISABLE_FIND_PACKAGE_FLEX=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "projectm-eval"
    CONFIG_PATH "lib/cmake/projectM-Eval"
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "projectM-EvalMilkdrop"
    CONFIG_PATH "lib/cmake/projectM-EvalMilkdrop"
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
