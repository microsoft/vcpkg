include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/VTK-7.1.1)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.vtk.org/files/release/7.1/VTK-7.1.1.tar.gz"
    FILENAME "VTK-7.1.1.tar.gz"
    SHA512 34a068801fe45f98325e5334d2569fc9b15ed38620386f1b5b860c9735e5fb8510953b50a3340d3ef9795e22fecf798c25bf750215b2ff1ff1eb7a1ecd87b623
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/transfer-3rd-party-module-definitions.patch
        ${CMAKE_CURRENT_LIST_DIR}/transfer-hdf5-definitions.patch
        ${CMAKE_CURRENT_LIST_DIR}/netcdf-use-hdf5-definitions.patch
        ${CMAKE_CURRENT_LIST_DIR}/dont-define-ssize_t.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-findhdf5-shared.patch
        ${CMAKE_CURRENT_LIST_DIR}/disable-workaround-findhdf5.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    # HACK: The FindHDF5.cmake script does not seem to detect the HDF5_DEFINITIONS correctly
    #       if HDF5 has been built without the tools (which is the case in the HDF5 port),
    #       so we set the BUILT_AS_DYNAMIC_LIB=1 flag here explicitly because we know HDF5
    #       has been build as dynamic library in the current case.
    list(APPEND ADDITIONAL_OPTIONS "-DHDF5_DEFINITIONS=-DH5_BUILT_AS_DYNAMIC_LIB=1")
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

file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/vtkEncodeString-7.1.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/vtkHashSource-7.1.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vtkEncodeString-7.1.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vtkHashSource-7.1.exe)

# Handle copyright
file(COPY ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/vtk/Copyright.txt ${CURRENT_PACKAGES_DIR}/share/vtk/copyright)
