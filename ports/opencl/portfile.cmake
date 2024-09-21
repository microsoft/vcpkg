vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-SDK
    REF "${VERSION}"
    SHA512 995ed5cff95fec7ffd8470f04eb4d00325f9acb20cc1f0d78442890d0636554c2526c015351f4b19bc673dcadd531bb62d9d3c8c526dd921f236cb5035e906e0
    HEAD_REF main
)

vcpkg_from_github(
    OUT_SOURCE_PATH OPENCL_HEADERS
    REPO KhronosGroup/OpenCL-Headers
    REF "${VERSION}"
    SHA512 2f1a46d58a5a9329470bab4c3662f17e81aab9558bfd9e1aafa14d3e1ab129513ab9493eeeb3cc48f0f91f0bc6b61bd54e28d7083eed58af9f34cd973cc93de1
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
    SHA512 6396cd67a2edef6a76695857e3e45f7eeb8cdaa8c729197357c6374ac58b41caa37bbe8c3b7a1724d43d3805f8cd5edd53a8ed833d6415bf072745800b744572
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
    SHA512 12d62183e49c5a1f813807291744d816008afca55b09f5acf2eef1bce50a453bf35a8dfbeb5f433022b0c5517f0a210d7123a3bac7a15ea63cc10f3bc71510f0
    HEAD_REF main
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
vcpkg_replace_string("${SOURCE_PATH}/cmake/Dependencies/whereami/whereami.cmake" [[${CMAKE_CURRENT_BINARY_DIR}/_deps/whereami-external-src]] [[${whereami-external_SOURCE_DIR}]])

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
