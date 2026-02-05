vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openapv
    REF v0.2.1.0
    SHA512 6489242a971d27e5a23fab1544beea7770812157919ddf9d15bfdc7f6de0514c458e7d43c7c65ae6036138b8cc7d3bdc2e85bf08aefa0c9dac3a7fac33545512
    HEAD_REF main
    PATCHES
        enable-msvc.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools OAPV_BUILD_APPS
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" OAPV_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OAPV_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOAPV_BUILD_STATIC_LIB=${OAPV_BUILD_STATIC}
        -DOAPV_BUILD_SHARED_LIB=${OAPV_BUILD_SHARED}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/oapv")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/oapv/oapv-config.cmake" "
include(CMakeFindDependencyMacro)
if(NOT TARGET oapv)
    add_library(oapv UNKNOWN IMPORTED)
    set_target_properties(oapv PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES \"\${CMAKE_CURRENT_LIST_DIR}/../../include/oapv\"
    )
    if(EXISTS \"\${CMAKE_CURRENT_LIST_DIR}/../../lib/oapv/liboapv.a\")
        set_target_properties(oapv PROPERTIES IMPORTED_LOCATION \"\${CMAKE_CURRENT_LIST_DIR}/../../lib/oapv/liboapv.a\")
    elseif(EXISTS \"\${CMAKE_CURRENT_LIST_DIR}/../../lib/liboapv.dylib\")
        set_target_properties(oapv PROPERTIES IMPORTED_LOCATION \"\${CMAKE_CURRENT_LIST_DIR}/../../lib/liboapv.dylib\")
    elseif(EXISTS \"\${CMAKE_CURRENT_LIST_DIR}/../../lib/liboapv.so\")
         set_target_properties(oapv PROPERTIES IMPORTED_LOCATION \"\${CMAKE_CURRENT_LIST_DIR}/../../lib/liboapv.so\")
    endif()
endif()
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES oapv_app_dec oapv_app_enc AUTO_CLEAN)
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)