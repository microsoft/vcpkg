include(vcpkg_common_functions)
set(PORT_VERSION 6.1.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CoolProp/CoolProp
    REF 0e934e842e9ce83eea64fda1d4ab8e59adf9d8cd
    SHA512 a44eafc84f2b88259d7bcf6cfa81daeb81ea9d55bd356e59b3ef77b6f68ea405961c7cb54ba899e3896bb2a02d3e01119a4a51f72899126c8da6081fa2ece948
    HEAD_REF master
)

# Patch up the file locations
file(COPY 
    ${CURRENT_INSTALLED_DIR}/include/catch.hpp 
    DESTINATION ${SOURCE_PATH}/externals/Catch/single_include
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
    ${CURRENT_INSTALLED_DIR}/include
    DESTINATION ${SOURCE_PATH}/externals/msgpack-c
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

if(${VCPKG_LIBRARY_LINKAGE} STREQUAL "dynamic")
    set(TARGET_FOLDER "shared_library")
else()
    set(TARGET_FOLDER "static_library")
endif()

file(GLOB COOLPROP_HEADERS ${CURRENT_PACKAGES_DIR}/${TARGET_FOLDER}/*.h)
file(INSTALL ${COOLPROP_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(GLOB_RECURSE COOLPROP_LIBS ${CURRENT_PACKAGES_DIR}/${TARGET_FOLDER}/*.lib))
file(INSTALL ${COOLPROP_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(REMOVE_RECURSE ${TARGET_FOLDER})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(
  INSTALL ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/coolprop
  RENAME copyright
)
