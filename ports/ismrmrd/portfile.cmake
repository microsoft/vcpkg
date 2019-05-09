include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ismrmrd/ismrmrd
    REF v1.3.2
    SHA512 eb806f71c4b183105b3270d658a68195e009c0f7ca37f54f76d650a4d5c83c44d26b5f12a4c47c608aae9990cd04f1204b0c57e6438ca34a271fd54880133106
    HEAD_REF master
	PATCHES
		# Makes optional hdf5 dependency explicit
		optional_hdf5_dependency.patch
)

if ("dataset" IN_LIST FEATURES)
    set(ENABLE_DATASET ON)
else()
    set(ENABLE_DATASET OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
		-DUSE_SYSTEM_PUGIXML=ON
		-DUSE_HDF5_DATASET_SUPPORT=${ENABLE_DATASET}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/ismrmrd/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/ismrmrd.dll)
    file(COPY ${CURRENT_PACKAGES_DIR}/lib/ismrmrd.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/ismrmrd.dll)
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/ismrmrd.dll)
    file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/ismrmrd.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/ismrmrd.dll)
endif()

file(COPY ${CURRENT_PACKAGES_DIR}/bin/ismrmrd_info.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/ismrmrd)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/ismrmrd_info.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/ismrmrd_info.exe)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ismrmrd)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ismrmrd/LICENSE ${CURRENT_PACKAGES_DIR}/share/ismrmrd/copyright)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/ismrmrd)
