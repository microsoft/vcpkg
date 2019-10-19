
include(vcpkg_common_functions)
include(vcpkg_common_definitions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/MDL-SDK
    REF 2019.1.1
    SHA512 20bd336bac76932271dae5c071b897f99464e53fe3f47c139a2aec777826f016ecd75f613076f0355a54344c5cfc47a48a515a857b06a97cb1692de057bcbcbe
    HEAD_REF master
    PATCHES
        0001-freeimage-dependency-search.patch
        0002-install-rules.patch
        0003-disable-freeimage-faxg3.patch
        0004-clang-tool-version.patch
        0005-embedded-clang.patch
)

vcpkg_download_distfile(CLANG_ARCHIVE
    URLS "http://releases.llvm.org/7.0.0/cfe-7.0.0.src.tar.xz"
    FILENAME "mdl-cfe-7.0.0.src.tar.xz"
    SHA512 17a658032a0160c57d4dc23cb45a1516a897e0e2ba4ebff29472e471feca04c5b68cff351cdf231b42aab0cff587b84fe11b921d1ca7194a90e6485913d62cb7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH CLANG_SOURCE_PATH
    ARCHIVE ${CLANG_ARCHIVE}
    PATCHES
        fix-build-error.patch
        install-clang-modules-to-share.patch
)

set(MDL_LLVM_PATH "${SOURCE_PATH}/src/mdl/jit/llvm/dist")

if(NOT EXISTS ${MDL_LLVM_PATH}/tools/clang)
  file(RENAME ${CLANG_SOURCE_PATH} ${MDL_LLVM_PATH}/tools/clang)
endif()

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR ${PYTHON2} DIRECTORY)
vcpkg_add_to_path(PREPEND ${PYTHON2_DIR})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFREEIMAGE_DIR=${CURRENT_INSTALLED_DIR}
        -DMDL_BUILD_SDK_EXAMPLES:BOOL=OFF
        -DMDL_BUILD_CORE_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_CUDA_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_D3D12_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_OPENGL_EXAMPLES:BOOL=OFF
        -DMDL_ENABLE_QT_EXAMPLES:BOOL=OFF
)

vcpkg_install_cmake()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
    file(RENAME
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    )

    # HACK
    file(RENAME
        "${CURRENT_PACKAGES_DIR}/lib/libmdl_core${CMAKE_SHARED_MODULE_SUFFIX}"
        "${CURRENT_INSTALLED_DIR}/lib/libmdl_core${CMAKE_SHARED_MODULE_SUFFIX}"
    )
    file(RENAME
        "${CURRENT_PACKAGES_DIR}/lib/libmdl_sdk${CMAKE_SHARED_MODULE_SUFFIX}"
        "${CURRENT_INSTALLED_DIR}/lib/libmdl_sdk${CMAKE_SHARED_MODULE_SUFFIX}"
    )

    # Make vcpkg believe everything is fine
    file(TOUCH "${CURRENT_PACKAGES_DIR}/lib/libmdl_core${CMAKE_STATIC_LIBRARY_SUFFIX}")
    file(TOUCH "${CURRENT_PACKAGES_DIR}/lib/libmdl_sdk${CMAKE_STATIC_LIBRARY_SUFFIX}")

    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/tools")
    file(RENAME
        "${CURRENT_PACKAGES_DIR}/debug/bin"
        "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}"
    )

    # HACK
    file(RENAME
        "${CURRENT_PACKAGES_DIR}/debug/lib/libmdl_core${CMAKE_SHARED_MODULE_SUFFIX}"
        "${CURRENT_INSTALLED_DIR}/debug/lib/libmdl_core${CMAKE_SHARED_MODULE_SUFFIX}"
    )
    file(RENAME
        "${CURRENT_PACKAGES_DIR}/debug/lib/libmdl_sdk${CMAKE_SHARED_MODULE_SUFFIX}"
        "${CURRENT_INSTALLED_DIR}/debug/lib/libmdl_sdk${CMAKE_SHARED_MODULE_SUFFIX}"
    )

    # Make vcpkg believe everything is fine
    file(TOUCH "${CURRENT_PACKAGES_DIR}/debug/lib/libmdl_core${CMAKE_STATIC_LIBRARY_SUFFIX}")
    file(TOUCH "${CURRENT_PACKAGES_DIR}/debug/lib/libmdl_sdk${CMAKE_STATIC_LIBRARY_SUFFIX}")

    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

file(INSTALL
    "${SOURCE_PATH}/LICENSE.md"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME
        "COPYRIGHT"
)
