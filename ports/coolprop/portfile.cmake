
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CoolProp/CoolProp
    REF "v${VERSION}"
    SHA512 8cc3a62d345914e95c34ba6cf2fdf93a8fb15618f7702b973203e2e974abe99d1c12dade2197327c291a790b0e961afdc28d085cf318507f5a5b346b78a26407
    HEAD_REF master
    PATCHES
        fix-install.patch
)
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "CACHE LIST" "CACHE STRING")

file(REMOVE_RECURSE "${SOURCE_PATH}/externals/Catch2")
file(REMOVE_RECURSE "${SOURCE_PATH}/externals/Eigen")
file(REMOVE_RECURSE "${SOURCE_PATH}/externals/ExcelAddinInstaller")
file(REMOVE_RECURSE "${SOURCE_PATH}/externals/FindMathematica")
file(REMOVE_RECURSE "${SOURCE_PATH}/externals/fmtlib")
file(REMOVE_RECURSE "${SOURCE_PATH}/externals/IF97")
file(REMOVE_RECURSE "${SOURCE_PATH}/externals/msgpack-c")
file(REMOVE_RECURSE "${SOURCE_PATH}/externals/multicomplex")
file(REMOVE_RECURSE "${SOURCE_PATH}/externals/pybind11")
file(REMOVE_RECURSE "${SOURCE_PATH}/externals/rapidjson")
file(REMOVE_RECURSE "${SOURCE_PATH}/externals/REFPROP-headers")
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
