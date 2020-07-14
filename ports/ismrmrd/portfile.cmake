if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(WIN32_INCLUDE_STDDEF_PATCH "x86-windows-include-stddef.patch")
endif()



vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ismrmrd/ismrmrd
    REF v1.4.2.1 
    SHA512 8d3f3efb9fc52464c626d8a4b4328f92f69ea6a709aa1b4d4312c9740a342094cadecd028ac169b6c89df92503037a3156172d7955abcd616630f0a309b9e0b5
    HEAD_REF master
    PATCHES
        ${STATIC_PATCH}
        ${WIN32_INCLUDE_STDDEF_PATCH}
        fix-depends-hdf5.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_SYSTEM_PUGIXML=ON
        -DUSE_HDF5_DATASET_SUPPORT=ON
        -DVCPKG_TARGET_TRIPLET=ON
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_UTILITIES=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/ismrmrd/cmake)

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/ismrmrd.dll)
    file(COPY ${CURRENT_PACKAGES_DIR}/lib/ismrmrd.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/ismrmrd.dll)
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/ismrmrd.dll)
    file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/ismrmrd.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/ismrmrd.dll)
endif()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/FindFFTW3.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/FindFFTW3.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/ismrmrd/FindFFTW3.cmake)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/ismrmrd/cmake)

set(ISMRMRD_CMAKE_DIRS ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
foreach(ISMRMRD_CMAKE_DIR IN LISTS ISMRMRD_CMAKE_DIRS)
if (EXISTS ${ISMRMRD_CMAKE_DIR})
    file(GLOB ISMRMRD_CMAKE_FILES "${ISMRMRD_CMAKE_DIR}/ISMRMRD/ISMRMRD*.cmake")
    foreach(ICF ${ISMRMRD_CMAKE_FILES})
        file(COPY ${ICF} DESTINATION ${CURRENT_PACKAGES_DIR}/share/ismrmrd/cmake/)
    endforeach()
endif()
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${ISMRMRD_CMAKE_DIRS})

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    set(EXECUTABLE_SUFFIX ".exe")
endif()


if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/ismrmrd)
