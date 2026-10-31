vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-SDK
    REF "${VERSION}"
    SHA512 3280bfe35fd5c155eab2d47b844c35873e71ceb17fdf00c9dccbdb0d6e308bdb8e2ff3776c5f3c7aa63182e248027c46d697e8d8cd79c91cbb43e57c96d37ac9
    HEAD_REF main
)

vcpkg_from_github(
    OUT_SOURCE_PATH OPENCL_HEADERS
    REPO KhronosGroup/OpenCL-Headers
    REF "${VERSION}"
    SHA512 65908880c36e75fe7d11cf326f4a6e67d2b36b06a405eb331b66d02a8ea43c9eee8b82be955cfb2c4538332b6ca1586af76dfcd44ec92aed5cf9131142aead34
    HEAD_REF main
)
if(NOT EXISTS "${SOURCE_PATH}/external/OpenCL-Headers/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/external/OpenCL-Headers")
    file(RENAME "${OPENCL_HEADERS}" "${SOURCE_PATH}/external/OpenCL-Headers")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH OPENCL_CLHPP
    REPO KhronosGroup/OpenCL-CLHPP
    REF "${VERSION}"
    SHA512 bc20aad03c374bcdba1bcffe5156d6b38337d84d60ae41bdd05be2f3281e0fb12c6b0b7513d8d6b538a04b72b288dff1046027e9e2e89d3a54585e0604c95b1a
    HEAD_REF main
)
if(NOT EXISTS "${SOURCE_PATH}/external/OpenCL-CLHPP/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/external/OpenCL-CLHPP")
    file(RENAME "${OPENCL_CLHPP}" "${SOURCE_PATH}/external/OpenCL-CLHPP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH OPENCL_ICD_LOADER
    REPO KhronosGroup/OpenCL-ICD-Loader
    REF "${VERSION}"
    SHA512 10135363ee04dedf034a617e272eb538639add90f0e821f3a12cee78fa27578b18b466568bd613f1d4bd29f77f09521df98bfd6a9af0fe0041d145fdad21bf27
    HEAD_REF main
)
if(NOT EXISTS "${SOURCE_PATH}/external/OpenCL-ICD-Loader/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/external/OpenCL-ICD-Loader")
    file(RENAME "${OPENCL_ICD_LOADER}" "${SOURCE_PATH}/external/OpenCL-ICD-Loader")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH WHEREAMI
    REPO gpakosz/whereami
    REF dcb52a058dc14530ba9ae05e4339bd3ddfae0e0e # 2024-08-26
    SHA512 afd5999316c398218d8a401b6dc6a9885c9e474bde6804f464d55eca42fdee126329856da5b337bdfad5582e6ed1364fc86a47c92b49b6d57f1bea4e3d5120e0
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
