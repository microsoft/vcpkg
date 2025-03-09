vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/ggml
    REF 9a4acb374565f4146b8d6eb1cffdcd7d437d1ba2
    SHA512 091a794baf669616ee20dc19d0232e64456c07cd50cbe6d81aa68b98f178801be1b62da9eea417e7a563a6b73bb3136777f860c756270569676fb760f2e751ed
    HEAD_REF master
    PATCHES
        0001-fix-cmakelists.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda     GGML_CUDA
        vulkan   GGML_VULKAN
        metal    GGML_METAL
        opencl   GGML_OPENCL
        openmp   GGML_OPENMP
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static"  GGML_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGGML_STATIC=${GGML_STATIC}
        -DGGML_CCACHE=OFF
        -DGGML_BUILD_NUMBER=1
        -DGGML_BUILD_TESTS=OFF
        -DGGML_BUILD_EXAMPLES=OFF
        -DGGML_HIP=OFF
        -DGGML_SYCL=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ggml CONFIG_PATH "lib/cmake/ggml")
vcpkg_copy_pdbs()

if (VCPKG_LIBRARY_LINKAGE MATCHES "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ggml/ggml-config.cmake"
        "set_and_check(GGML_BIN_DIR \"\${PACKAGE_PREFIX_DIR}/bin\")"
        ""
    )
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ggml/ggml-config.cmake"
    "add_library(ggml::ggml UNKNOWN IMPORTED)"
    "if (NOT TARGET ggml::ggml)
    add_library(ggml::ggml UNKNOWN IMPORTED)
endif()"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ggml/ggml-config.cmake"
    "add_library(ggml::ggml-base UNKNOWN IMPORTED)"
    "if (NOT TARGET ggml::ggml-base)
    add_library(ggml::ggml-base UNKNOWN IMPORTED)
endif()"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ggml/ggml-config.cmake"
    "add_library(ggml::\${_ggml_backend} UNKNOWN IMPORTED)"
    "if (NOT TARGET ggml::\${_ggml_backend})
        add_library(ggml::\${_ggml_backend} UNKNOWN IMPORTED)
    endif()"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ggml/ggml-config.cmake"
    "add_library(ggml::all INTERFACE IMPORTED)"
    "if (NOT TARGET ggml::all)
    add_library(ggml::all INTERFACE IMPORTED)
endif()"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ggml/ggml-config.cmake"
    "if (NOT GGML_SHARED_LIB)"
    "if (NOT GGML_SHARED_LIB)
    if (GGML_OPENCL)
        find_package(OpenCL REQUIRED)
        list(APPEND GGML_CPU_INTERFACE_LINK_LIBRARIES OpenCL::OpenCL)
    endif()"
)

if (NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/ggml.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/ggml.pc")
endif()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/ggml.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/ggml.pc")
vcpkg_fixup_pkgconfig()

if ("vulkan" IN_LIST FEATURES)
  vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES vulkan-shaders-gen)
endif()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
