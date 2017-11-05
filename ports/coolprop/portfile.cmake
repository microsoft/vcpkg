include(vcpkg_common_functions)
set(PORT_VERSION 6.1.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CoolProp/CoolProp
    REF v${PORT_VERSION}
    SHA512 012b994db829ee1c4e0702a964bd7d3402f378bd88d5c38b874178a3402cf39fa656b1a9e4645ad257c7184fd0bf8652e3435af7f8d41fa13aa200cd7ee7f534
    HEAD_REF master
)

# Patch up the file locations
file(COPY 
    ${CURRENT_INSTALLED_DIR}/include/catch.hpp 
    DESTINATION ${SOURCE_PATH}/externals/Catch/single_include
)

file(COPY 
    ${CURRENT_INSTALLED_DIR}/include/rapidjson/rapidjson.h
    DESTINATION ${SOURCE_PATH}/externals/rapidjson/include/rapidjson
)

file(COPY
    ${CURRENT_INSTALLED_DIR}/include
    DESTINATION ${SOURCE_PATH}/externals/msgpack-c
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCOOLPROP_SHARED_LIBRARY=${COOLPROP_SHARED_LIBRARY}
        -DCOOLPROP_STATIC_LIBRARY=${COOLPROP_STATIC_LIBRARY}
        -DCOOLPROP_MSVC_DYNAMIC=${COOLPROP_MSVC_DYNAMIC}
        -DCOOLPROP_MSVC_STATIC=${COOLPROP_MSVC_STATIC}
    OPTIONS_RELEASE
        -DCOOLPROP_RELEASE=ON
    OPTIONS_DEBUG
        -DCOOLPROP_DEBUG=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(
  INSTALL ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/coolprop
  RENAME copyright
)
