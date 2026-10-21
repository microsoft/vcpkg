vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-SDK
    REF "v${VERSION}"
    SHA512 be396a7aad6251d9d1f1af265ecf20f3428d87610d680c14d92fb5b060a59ce8b8522135a0dd29eaf20e75683e45c1c8ea55035a7c3ec3eddc4bc7680d68b66e
    HEAD_REF main
    PATCHES
        # see https://github.com/KhronosGroup/OpenCL-SDK/pull/88/files#r1905072265
        001-remove-extra-install-rules.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH OPENCL_HEADERS
    REPO KhronosGroup/OpenCL-Headers
    REF "v${VERSION}"
    SHA512 9d2ed2a8346bc3f967989091d8cc36148ffe5ff13fe30e12354cc8321c09328bbe23e74817526b99002729c884438a3b1834e175a271f6d36e8341fd86fc1ad5
    HEAD_REF main
)
if(NOT EXISTS "${SOURCE_PATH}/external/OpenCL-Headers/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/external/OpenCL-Headers")
    file(RENAME "${OPENCL_HEADERS}" "${SOURCE_PATH}/external/OpenCL-Headers")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH OPENCL_CLHPP
    REPO KhronosGroup/OpenCL-CLHPP
    REF "v${VERSION}"
    SHA512 7cdadc8ef182d1556346bd34b5a9ffe6e239ab61ec527e5609d69e1bcaf81a88f3fc534f5bdeed037236e1b0e61f1544d2a95c06df55f9cd8e03e13baf4143ba
    HEAD_REF main
)
if(NOT EXISTS "${SOURCE_PATH}/external/OpenCL-CLHPP/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/external/OpenCL-CLHPP")
    file(RENAME "${OPENCL_CLHPP}" "${SOURCE_PATH}/external/OpenCL-CLHPP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH OPENCL_ICD_LOADER
    REPO KhronosGroup/OpenCL-ICD-Loader
    REF "v${VERSION}"
    SHA512 29043eff21076440046314edf62bb488b7e4e17d9fbdac4c3727d8e2523c0c8fbf89ee7fcf762528af761ddbcb4be24e5f062ffa82f778401d6365faa35344a8
    HEAD_REF main
    PATCHES
        icd-loader-pkgconfig.diff
)
if(NOT EXISTS "${SOURCE_PATH}/external/OpenCL-ICD-Loader/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/external/OpenCL-ICD-Loader")
    file(RENAME "${OPENCL_ICD_LOADER}" "${SOURCE_PATH}/external/OpenCL-ICD-Loader")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH WHEREAMI
    REPO gpakosz/whereami
    REF f5e3eac441acbb4ec1fe3e2c32646248ae463398 # 2024-06-09
    SHA512 d6fa8b6788cabdbb185a6ffba79c994762924a1c60595b769a7d3bb4a3ddf0f80cdeac7bd915cffa720f9123a720a1b7f0023fd7f2cf58906d15758529a99e2d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DFETCHCONTENT_SOURCE_DIR_WHEREAMI-EXTERNAL=${WHEREAMI}"
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DOPENCL_HEADERS_BUILD_CXX_TESTS=OFF
        -DOPENCL_SDK_BUILD_SAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/OpenCLHeaders" PACKAGE_NAME "OpenCLHeaders" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/OpenCLICDLoader" PACKAGE_NAME "OpenCLICDLoader" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/OpenCLHeadersCpp" PACKAGE_NAME "OpenCLHeadersCpp" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/OpenCLUtils" PACKAGE_NAME "OpenCLUtils" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/OpenCLUtilsCpp" PACKAGE_NAME "OpenCLUtilsCpp" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/OpenCL" PACKAGE_NAME "opencl")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES cllayerinfo AUTO_CLEAN)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${WHEREAMI}/LICENSE.MIT"
    COMMENT [[
The OpenCL SDK is licensed under the terms of the Apache-2.0 license.
The OpenCL Utility Library uses code from https://github.com/gpakosz/whereami
which is dual licensed under both the WTFPLv2 and MIT licenses.
]])
