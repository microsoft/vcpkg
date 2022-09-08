if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(WIN32_INCLUDE_STDDEF_PATCH "x86-windows-include-stddef.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dchansen/ismrmrd
    REF 2325e0549af791b9bb6f8d33434097e3f75f1f26
    SHA512 a9690daf479d052d25fdf13e1699ee6af9c05f24dcd7bf1202dc350008170e5becced3d53ae2f4ab21d63b9ef7f0a000f4ba00c4dd797e0a82553d8aae69fbda
    HEAD_REF diffusion
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
