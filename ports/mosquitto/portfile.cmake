include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message("mosquitto only supports dynamic linkage")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "mosquitto does not support static CRT linkage")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse/mosquitto
    REF v1.5
    SHA512 f6a5c8e71d642ef931176fe428fb79353933facc2db226d9e55b87d4ff9bd6610a1bd05d71159e30c8afb1fda542d233630ae164770e652baa7ea51117211489
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/win64-cmake.patch"
        "${CMAKE_CURRENT_LIST_DIR}/output_folders-cmake.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_SRV=OFF
        -DWITH_WEBSOCKETS=ON
        -DWITH_TLS=ON
        -DWITH_TLS_PSK=ON
        -DWITH_THREADING=ON
        -DDOCUMENTATION=OFF 
    OPTIONS_RELEASE
        -DENABLE_DEBUG=OFF
    OPTIONS_DEBUG
        -DENABLE_DEBUG=ON
)

vcpkg_install_cmake()

# Remove debug/include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB DEBUG_EXE ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${EXE})
file(REMOVE ${DEBUG_EXE})

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/mosquitto RENAME copyright)

# Copy pdb
vcpkg_copy_pdbs()
