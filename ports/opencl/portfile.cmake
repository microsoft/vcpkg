# OpenCL headers
vcpkg_from_github(
    OUT_SOURCE_PATH OPENCL_HEADERS
    REPO KhronosGroup/OpenCL-Headers
    REF "${VERSION}"
    SHA512 41730e80b267de45db9d7a3bcf9e0f29bfc86b25475a86d50180a7258e1240fc8c8f2ad3e222b03b3ef50c10ef63fb5b1647c056fec615e87965aa3196e8ac60
    HEAD_REF main
)

# OpenCL C++ headers
vcpkg_from_github(
    OUT_SOURCE_PATH OPENCL_CLHPP
    REPO KhronosGroup/OpenCL-CLHPP
    REF "${VERSION}"
    SHA512 30252a832287375d550a5e184779881d5b22207a636298c7f52f277c219d3a1ae6983259cfea7bf4f90f0840fec114ee0e7a8c1e6a6fe48c24fd3b5119e7a7f8
    HEAD_REF main
)

# OpenCL ICD loader
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-ICD-Loader
    REF "${VERSION}"
    SHA512 e418b8f3cccb4716ed44acd0677afb96705f8b40a7714d483f1efe1a9b835f4a823c5a80f8457e72c8004f76d8a07c45d9cca55b699dd2fdaa6fe9f8cc863cbd
    HEAD_REF main
)

block(SCOPE_FOR VARIABLES)
    set(VCPKG_BUILD_TYPE release)  # header-only SDK components

    message(STATUS "OpenCL headers (${OPENCL_HEADERS})")
    vcpkg_cmake_configure(
        SOURCE_PATH "${OPENCL_HEADERS}"
        OPTIONS
            -DOPENCL_HEADERS_BUILD_CXX_TESTS=OFF
            -DBUILD_TESTING=OFF
    )
    vcpkg_cmake_install()
    vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/OpenCLHeaders" PACKAGE_NAME "openclheaders")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/share/pkgconfig")
    unset(Z_VCPKG_CMAKE_GENERATOR CACHE)  # suppress warning

    message(STATUS "OpenCL C++ headers (${OPENCL_CLHPP})")
    vcpkg_cmake_configure(
        SOURCE_PATH "${OPENCL_CLHPP}"
        OPTIONS
            -DBUILD_DOCS=OFF
            -DBUILD_EXAMPLES=OFF
            -DBUILD_TESTING=OFF
            "-DOpenCLHeaders_DIR=${CURRENT_PACKAGES_DIR}/share/openclheaders"
    )
    vcpkg_cmake_install()
    vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/OpenCLHeadersCpp" PACKAGE_NAME "openclheaderscpp")
    unset(Z_VCPKG_CMAKE_GENERATOR CACHE)  # suppress warning
endblock()

message(STATUS "OpenCL ICD loader (${SOURCE_PATH})")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DOPENCL_ICD_LOADER_HEADERS_DIR=${CURRENT_PACKAGES_DIR}/include"
        -DENABLE_OPENCL_LAYERINFO=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/OpenCLICDLoader" PACKAGE_NAME "openclicdloader")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(GLOB files_in_bin "${CURRENT_PACKAGES_DIR}/bin/*")
if(files_in_bin STREQUAL "")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
