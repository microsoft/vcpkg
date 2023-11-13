vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO GPUOpen-Drivers/libamdrdf
        REF v1.2.0
        SHA512 f003efbb621ac130174cbd5165e30c20f5c39482
        HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES 
        tools           RDF_BUILD_TOOLS
        cxx             RDF_ENABLE_CXX_BINDINGS
        tests           RDF_BUILD_TESTS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS} 
        -DRDF_BUILD_INSTALL=ON
        -DRDF_STATIC=OFF
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")


if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES rdfg 
                                rdfi
                                rdfm 
                     AUTO_CLEAN)
endif()
if("tests" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES rdf.Test AUTO_CLEAN)
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")


# configure file

if (VCPKG_TARGET_IS_LINUX)
    set(dll_name "amdrdf.so")
    set(dll_dir  "lib")
    set(lib_name "amdrdf.so")
    set(rdf_platform "RDF_PLATFORM_UNIX")
else()
    set(dll_name "amdrdf.dll")
    set(dll_dir  "bin")
    set(lib_name "amdrdf.lib")
    set(rdf_platform "RDF_PLATFORM_WINDOWS")
endif()

if("cxx" IN_LIST FEATURES)
    set(cxx ON)
else()
    set(cxx OFF)
endif()


configure_file("${CMAKE_CURRENT_LIST_DIR}/amd-rdf-config.cmake.in"
  "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
  @ONLY)
