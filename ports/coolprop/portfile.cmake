
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CoolProp/CoolProp
    REF "v${VERSION}"
    SHA512 ccd868cb297d86f054318acec4c3bf9f8ec07b54c320d5e887853c4190adefbd3b2d188e7453896656b5ad0e81b32d133fd0ce67bf58e647d58c96918bc993eb
    HEAD_REF master
    PATCHES
        fmt-fix.patch
        fix-builderror.patch
        fix-dependency.patch
        fix-install.patch
)
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "CACHE LIST" "CACHE STRING")

file(REMOVE_RECURSE "${SOURCE_PATH}/externals")
file(COPY "${CURRENT_INSTALLED_DIR}/include/IF97.h" DESTINATION "${SOURCE_PATH}/externals/IF97")
file(COPY "${CURRENT_INSTALLED_DIR}/include/REFPROP_lib.h" DESTINATION "${SOURCE_PATH}/externals/REFPROP-headers/")
file(COPY "${CURRENT_INSTALLED_DIR}/include/rapidjson" DESTINATION "${SOURCE_PATH}/externals/rapidjson/include")
# Fix GCC warning when thread_local is substitude as __thread
vcpkg_replace_string("${SOURCE_PATH}/externals/rapidjson/include/rapidjson/document.h" "thread_local static " "static thread_local ")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" COOLPROP_SHARED_LIBRARY)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" COOLPROP_STATIC_LIBRARY)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" COOLPROP_MSVC_DYNAMIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" COOLPROP_MSVC_STATIC)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DCOOLPROP_SHARED_LIBRARY=${COOLPROP_SHARED_LIBRARY}
        -DCOOLPROP_STATIC_LIBRARY=${COOLPROP_STATIC_LIBRARY}
        -DCOOLPROP_MSVC_DYNAMIC=${COOLPROP_MSVC_DYNAMIC}
        -DCOOLPROP_MSVC_STATIC=${COOLPROP_MSVC_STATIC}
        "-DPYTHON_EXECUTABLE=${PYTHON3}"
    OPTIONS_RELEASE
        "-DCOOLPROP_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}"
    OPTIONS_DEBUG
        "-DCOOLPROP_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if (VCPKG_TARGET_IS_WINDOWS AND COOLPROP_SHARED_LIBRARY)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/CoolPropLib.h
        "#if defined(COOLPROP_LIB)" "#if 1"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
