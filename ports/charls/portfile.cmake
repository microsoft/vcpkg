vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO team-charls/charls
    REF "${VERSION}"
    SHA512 56261e06c080f5ed59ede65cc1159a1796595cad5906c355e1ccc1fb23eb26ff585823fd9bbd0845107db34058df91a660ca18866ddcf6129f8f15737eb25e26
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCHARLS_BUILD_TESTS=OFF
        -DCHARLS_BUILD_SAMPLES=OFF
        -DCHARLS_BUILD_FUZZ_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/charls)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/charls/api_abi.h"
        "#if defined(CHARLS_STATIC)" "#if 1")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB charls_import_libraries
        "${CURRENT_PACKAGES_DIR}/lib/${VCPKG_TARGET_IMPORT_LIBRARY_PREFIX}charls-*${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}")
    list(GET charls_import_libraries 0 charls_import_library)
    get_filename_component(charls_library_name "${charls_import_library}" NAME)
    string(REPLACE "${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX}" "" charls_library_name "${charls_library_name}")
    if(VCPKG_TARGET_IMPORT_LIBRARY_PREFIX)
        string(REGEX REPLACE "^${VCPKG_TARGET_IMPORT_LIBRARY_PREFIX}" "" charls_library_name "${charls_library_name}")
    endif()
    foreach(config IN ITEMS "" "/debug")
        if(EXISTS "${CURRENT_PACKAGES_DIR}${config}/lib/pkgconfig/charls.pc")
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}${config}/lib/pkgconfig/charls.pc"
                "-lcharls" "-l${charls_library_name}")
        endif()
    endforeach()
endif()

vcpkg_fixup_pkgconfig()
