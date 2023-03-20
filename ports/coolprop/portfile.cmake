
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

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})

file(REMOVE_RECURSE ${SOURCE_PATH}/externals)

# Patch up the file locations
file(COPY
    ${CURRENT_INSTALLED_DIR}/include/catch.hpp
    DESTINATION ${SOURCE_PATH}/externals/Catch/single_include
)

file(COPY
    ${CURRENT_INSTALLED_DIR}/include/eigen3/Eigen
    DESTINATION ${SOURCE_PATH}/externals/Eigen
)
file(COPY
    ${CURRENT_INSTALLED_DIR}/include/eigen3/unsupported/Eigen
    DESTINATION ${SOURCE_PATH}/externals/Eigen/unsupported
)

file(COPY
    ${CURRENT_INSTALLED_DIR}/include/rapidjson
    DESTINATION ${SOURCE_PATH}/externals/rapidjson/include
)

file(COPY
    ${CURRENT_INSTALLED_DIR}/include/IF97.h
    DESTINATION ${SOURCE_PATH}/externals/IF97
)

file(COPY
    ${CURRENT_INSTALLED_DIR}/include/msgpack.hpp
    ${CURRENT_INSTALLED_DIR}/include/msgpack
    DESTINATION ${SOURCE_PATH}/externals/msgpack-c/include
)

file(COPY
    ${CURRENT_INSTALLED_DIR}/include/fmt
    DESTINATION ${SOURCE_PATH}/externals/cppformat
)

file(COPY
    ${CURRENT_INSTALLED_DIR}/include/REFPROP_lib.h
    DESTINATION ${SOURCE_PATH}/externals/REFPROP-headers/
)

# Use a nasty hack to include the correct header
file(APPEND
    ${SOURCE_PATH}/externals/msgpack-c/include/fmt/format.h
    "#include \"fmt/printf.h\""
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" COOLPROP_SHARED_LIBRARY)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" COOLPROP_STATIC_LIBRARY)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" COOLPROP_MSVC_DYNAMIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" COOLPROP_MSVC_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCOOLPROP_SHARED_LIBRARY=${COOLPROP_SHARED_LIBRARY}
        -DCOOLPROP_STATIC_LIBRARY=${COOLPROP_STATIC_LIBRARY}
        -DCOOLPROP_MSVC_DYNAMIC=${COOLPROP_MSVC_DYNAMIC}
        -DCOOLPROP_MSVC_STATIC=${COOLPROP_MSVC_STATIC}
    OPTIONS_RELEASE
        -DCOOLPROP_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}
    OPTIONS_DEBUG
        -DCOOLPROP_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug
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
