include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("Armadillo only supports static library linkage")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

#as conradsnicta/armadillo-code has no release, and the link http://sourceforge.net/projects/arma/files/armadillo-8.400.0.tar.xz is not worked, I use the latest commit for 8.400.x branch
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO conradsnicta/armadillo-code
    REF a25f66da4c27d40a4a7699199cbf4dc747e712a7
    SHA512 bf5e1de18c38503e46f72f4f9f145477b6b782baf0df42600acb8811c7a07a5d8c0cd2ac3015d4169c961876e4cbb0457a7c1417b55ba52c98d4f78d145f9ae6
    HEAD_REF unstable
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/disable-wrapper.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDETECT_HDF5=false
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/Armadillo/CMake)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/ArmadilloConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/Armadillo)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt  DESTINATION ${CURRENT_PACKAGES_DIR}/share/Armadillo RENAME copyright)
