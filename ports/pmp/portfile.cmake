vcpkg_download_distfile(PR_137_PATCH_PATH
    URLS "https://github.com/pmp-library/pmp-library/pull/137.diff"
    FILENAME pmp-pr-137.patch
    HEADERS "Accept: application/vnd.github.v3.raw"
    SHA512 11e70b137556bdc5f08245c6c9d9e031d4c35a6f29ee8643404ab9be3484c7d851d915369b590da46c76825a40db62b57727c4f156fc5f9a722b81ca4e8ab827
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmp-library/pmp-library
    REF 2.0.1
    SHA512 f3b8b4962e0543af68f257dab7544968e99fc61f20399f6acb34fdf4634088a78c01df73b72a8387d94893844feace567b26085012ef617062c75489a584bae6
    PATCHES
        ${PR_137_PATCH_PATH}
        fix-sources.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPMP_BUILD_EXAMPLES=OFF
        -DPMP_BUILD_TESTS=OFF
        -DPMP_BUILD_DOCS=OFF
        -DPMP_BUILD_VIS=OFF
        -DPMP_BUILD_APPS=OFF
        -DPMP_INSTALL=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/pmp)
vcpkg_copy_pdbs()

if("tools" IN_LIST FEATURES)
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        vcpkg_copy_tools(TOOL_NAMES mconvert AUTO_CLEAN)
    endif()
    vcpkg_copy_tools(TOOL_NAMES mview curview subdiv smoothing fairing parameterization decimation remeshing mpview AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
