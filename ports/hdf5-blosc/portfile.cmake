vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Blosc/hdf5-blosc
    REF bd8ee59708f366ac561153858735165d3a543b18 # v1.0.0
    SHA512 75bd35323cd21b8109053e7d75b8bf0783507ff08ce63945ac95c59fa8cc3211f3ff1b4c410bae07a2d6f527bf8f407cd7b6ba58189ff2606676c647f10a8c87
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(blosc_h5_SHARED 0)
else()
    set(blosc_h5_SHARED 1)
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/src)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    PREFER_NINJA
    OPTIONS
        -Dblosc_h5_SHARED=${blosc_h5_SHARED}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/${PORT})

file(INSTALL ${CURRENT_PACKAGES_DIR}/plugin/H5Zblosc.dll DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/plugin 
	${CURRENT_PACKAGES_DIR}/debug/plugin
	${CURRENT_PACKAGES_DIR}/debug/include 
	${CURRENT_PACKAGES_DIR}/debug/share
)

configure_file(${SOURCE_PATH}/LICENSES/BLOSC_HDF5.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
configure_file(${SOURCE_PATH}/LICENSES/BLOSC.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE_BLOSC COPYONLY)
configure_file(${SOURCE_PATH}/LICENSES/H5PY.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE_H5PY COPYONLY)
