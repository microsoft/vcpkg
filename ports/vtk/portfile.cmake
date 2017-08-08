include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "Kitware/VTK"
    REF "v8.0.0"
    SHA512 1a328f24df0b1c40c623ae80c9d49f8b27570144b10af02aeed41b90b50b8d4e0dd83d1341961f6818cde36e2cd793c578ebc95a46950cebfc518f486f249791
    HEAD_REF "master"
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/disable-workaround-findhdf5.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND ADDITIONAL_OPTIONS "-DVTK_EXTERNAL_HDF5_IS_SHARED=ON")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DVTK_Group_MPI=ON
        -DVTK_Group_Qt=ON
        -DVTK_QT_VERSION=5
        -DVTK_BUILD_QT_DESIGNER_PLUGIN=OFF
        # -DVTK_WRAP_PYTHON=ON
        # -DVTK_PYTHON_VERSION=3
        -DVTK_USE_SYSTEM_EXPAT=ON
        -DVTK_USE_SYSTEM_FREETYPE=ON
        # -DVTK_USE_SYSTEM_GL2PS=ON
        -DVTK_USE_SYSTEM_GLEW=ON
        -DVTK_USE_SYSTEM_HDF5=ON
        -DVTK_USE_SYSTEM_JSONCPP=ON
        # -DVTK_USE_SYSTEM_LIBPROJ4=ON
        # -DVTK_USE_SYSTEM_LIBRARIES=ON
        -DVTK_USE_SYSTEM_LIBXML2=ON
        # -DVTK_USE_SYSTEM_NETCDF=ON
        # -DVTK_USE_SYSTEM_OGGTHEORA=ON
        -DVTK_USE_SYSTEM_PNG=ON
        -DVTK_USE_SYSTEM_TIFF=ON
        -DVTK_USE_SYSTEM_ZLIB=ON
        -DVTK_INSTALL_DATA_DIR=share/vtk/data
        -DVTK_INSTALL_DOC_DIR=share/vtk/doc
        -DVTK_INSTALL_PACKAGE_DIR=share/vtk
        -DVTK_FORBID_DOWNLOADS=ON
        ${ADDITIONAL_OPTIONS}
    OPTIONS_RELEASE
        -DHDF5_C_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/hdf5.lib
        -DHDF5_C_HL_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/hdf5_hl.lib
    OPTIONS_DEBUG
        -DHDF5_C_LIBRARY=${CURRENT_INSTALLED_DIR}/debug/lib/hdf5_D.lib
        -DHDF5_C_HL_LIBRARY=${CURRENT_INSTALLED_DIR}/debug/lib/hdf5_hl_D.lib
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Remove tools from the bin directory.
# We make sure no references to the deleted files are left in the CMake config files.
file(READ ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-release.cmake VTK_TARGETS_RELEASE_MODULE)
string(REPLACE "list\(APPEND _IMPORT_CHECK_FILES_FOR_vtkEncodeString" "#list(APPEND _IMPORT_CHECK_FILES_FOR_vtkEncodeString" VTK_TARGETS_RELEASE_MODULE "${VTK_TARGETS_RELEASE_MODULE}")
string(REPLACE "list\(APPEND _IMPORT_CHECK_FILES_FOR_vtkHashSource" "#list(APPEND _IMPORT_CHECK_FILES_FOR_vtkHashSource" VTK_TARGETS_RELEASE_MODULE "${VTK_TARGETS_RELEASE_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-release.cmake "${VTK_TARGETS_RELEASE_MODULE}")

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/vtk/VTKTargets-debug.cmake VTK_TARGETS_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" VTK_TARGETS_DEBUG_MODULE "${VTK_TARGETS_DEBUG_MODULE}")
string(REPLACE "list\(APPEND _IMPORT_CHECK_FILES_FOR_vtkEncodeString" "#list(APPEND _IMPORT_CHECK_FILES_FOR_vtkEncodeString" VTK_TARGETS_DEBUG_MODULE "${VTK_TARGETS_DEBUG_MODULE}")
string(REPLACE "list\(APPEND _IMPORT_CHECK_FILES_FOR_vtkHashSource" "#list(APPEND _IMPORT_CHECK_FILES_FOR_vtkHashSource" VTK_TARGETS_DEBUG_MODULE "${VTK_TARGETS_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-debug.cmake "${VTK_TARGETS_DEBUG_MODULE}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/vtkEncodeString-8.0.exe)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/vtkHashSource-8.0.exe)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vtkEncodeString-8.0.exe)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vtkHashSource-8.0.exe)
else()
    # On static builds there should be no bin directory at all
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/vtk/Copyright.txt ${CURRENT_PACKAGES_DIR}/share/vtk/copyright)
