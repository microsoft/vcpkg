include(vcpkg_common_functions)
set(PORT_VERSION 6.1.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CoolProp/CoolProp
    REF 0e934e842e9ce83eea64fda1d4ab8e59adf9d8cd
    SHA512 a44eafc84f2b88259d7bcf6cfa81daeb81ea9d55bd356e59b3ef77b6f68ea405961c7cb54ba899e3896bb2a02d3e01119a4a51f72899126c8da6081fa2ece948
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR ${PYTHON2} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON2_DIR}")

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
    ${CURRENT_INSTALLED_DIR}/include/msgpack.h
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCOOLPROP_SHARED_LIBRARY=${COOLPROP_SHARED_LIBRARY}
        -DCOOLPROP_STATIC_LIBRARY=${COOLPROP_STATIC_LIBRARY}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(TARGET_FOLDER "shared_library")
else()
    set(TARGET_FOLDER "static_library")
endif()

# Install the headers
file(GLOB COOLPROP_HEADERS "${SOURCE_PATH}/install_root/${TARGET_FOLDER}/*.h")
file(INSTALL ${COOLPROP_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Install the libs
set(TARGET_FOLDER ${TARGET_FOLDER}/Windows)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(BITS 32bit)
else()
    set(BITS 64bit)
endif()

file(INSTALL 
    "${SOURCE_PATH}/install_root/${TARGET_FOLDER}/${BITS}/CoolProp.lib"
    DESTINATION ${COOLPROP_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL 
    "${SOURCE_PATH}/install_root/${TARGET_FOLDER}/${BITS}/CoolPropd.lib"
    DESTINATION ${COOLPROP_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)

file(INSTALL 
    "${SOURCE_PATH}/install_root/${TARGET_FOLDER}/${BITS}/CoolProp.dll"
    DESTINATION ${COOLPROP_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)

file(INSTALL 
    "${SOURCE_PATH}/install_root/${TARGET_FOLDER}/${BITS}/CoolPropd.dll"
    DESTINATION ${COOLPROP_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(
  INSTALL ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/coolprop
  RENAME copyright
)
