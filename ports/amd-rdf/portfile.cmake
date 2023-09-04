vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO GPUOpen-Drivers/libamdrdf
        REF v1.1.2
        SHA512 76c7246ae2738cfde8cff9be41776163397bd924d3ef5ff95115e8c22c5442491873fbe284b6ff6d9a1ac969bf096a7a0b1ad0cb35da609eb8a19c7b649b5416
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
