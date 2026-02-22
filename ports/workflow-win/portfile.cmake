vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sogou/workflow
    REF b92ead03ec62609a3cc1293041a9caa58a6b4800
    SHA512 4f9ac3daefcafaffe9121bd2b91b7a9311bd9f09690f723c970ebeab9f092fe3cd6745983c459c9781f673e898d74b6382e654db758914e9c73f9462394e2f73
    HEAD_REF windows
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_STATIC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # because configure_package_config_file to ${PROJECT_SOURCE_DIR}
    OPTIONS
        -DWORKFLOW_BUILD_STATIC_RUNTIME=${BUILD_STATIC_RUNTIME}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/workflow" PACKAGE_NAME "workflow")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
