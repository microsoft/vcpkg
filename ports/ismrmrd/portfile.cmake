if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(WIN32_INCLUDE_STDDEF_PATCH "x86-windows-include-stddef.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ismrmrd/ismrmrd
    REF v1.13.0
    SHA512 4654c416f7acc4e2da2616216706ff3dc98a9b8afbdf38c990a792ad681ce0e95eab8e3b382ad266d67f7b808fb86cc32f2f7b3d950e10e1a1473de38acb8104
    HEAD_REF master
    PATCHES
        ${WIN32_INCLUDE_STDDEF_PATCH}
        fix-depends-hdf5.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_SYSTEM_PUGIXML=ON
        -DUSE_HDF5_DATASET_SUPPORT=ON
        -DVCPKG_TARGET_TRIPLET=ON
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_UTILITIES=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ISMRMRD/)

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/ismrmrd.dll")
    file(COPY "${CURRENT_PACKAGES_DIR}/lib/ismrmrd.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/ismrmrd.dll")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/ismrmrd.dll")
    file(COPY "${CURRENT_PACKAGES_DIR}/debug/lib/ismrmrd.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/ismrmrd.dll")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/ismrmrd/cmake")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
