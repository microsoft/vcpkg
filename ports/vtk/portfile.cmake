include(vcpkg_common_functions)

set(VTK_SHORT_VERSION "8.0")
set(VTK_LONG_VERSION "${VTK_SHORT_VERSION}.0")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "Kitware/VTK"
    REF "v${VTK_LONG_VERSION}"
    SHA512 1a328f24df0b1c40c623ae80c9d49f8b27570144b10af02aeed41b90b50b8d4e0dd83d1341961f6818cde36e2cd793c578ebc95a46950cebfc518f486f249791
    HEAD_REF "master"
)

# =============================================================================
# Options: These should be set by feature-packages when they become available
set(VTK_WITH_QT                          ON ) # IMPORTANT: if ON make sure `qt5` is listed as dependency in the CONTROL file
set(VTK_WITH_MPI                         ON ) # IMPORTANT: if ON make sure `mpi` is listed as dependency in the CONTROL file
set(VTK_WITH_PYTHON                      OFF) # IMPORTANT: if ON make sure `python3` is listed as dependency in the CONTROL file
set(VTK_WITH_ALL_MODULES                 OFF) # IMPORTANT: if ON make sure `qt5`, `mpi`, `python3`, `ffmpeg`, `gdal`, `fontconfig`,
                                              #            `libmysql` and `atlmfc` are  listed as dependency in the CONTROL file

# =============================================================================
# Apply patches to the source code
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        # Disable ssize_t because this can conflict with ssize_t that is defined on windows.
        ${CMAKE_CURRENT_LIST_DIR}/dont-define-ssize_t.patch

        # We force CMake to use it's own version of the FindHDF5 module since newer versions
        # shipped with CMake behave differently. E.g. the one shipped with CMake 3.9 always
        # only finds the release libraries, but not the debug libraries.
        # The file shipped with CMake allows us to set the libraries explicitly as it is done below.
        # Maybe in the future we can disable the patch and use the new version shipped with CMake
        # together with the hdf5-config.cmake that is written by HDF5 itself, but currently VTK
        # disables taking the config into account explicitly.
        ${CMAKE_CURRENT_LIST_DIR}/use-fixed-find-hdf5.patch

        # We disable a workaround in the VTK CMake scripts that can lead to the fact that a dependency
        # will link to both, the debug and the release library.
        ${CMAKE_CURRENT_LIST_DIR}/disable-workaround-findhdf5.patch

        ${CMAKE_CURRENT_LIST_DIR}/fix-find-libproj4.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-find-libharu.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-find-mysql.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-find-odbc.patch
)

# Remove the FindGLEW.cmake and FindPythonLibs.cmake that are distributed with VTK,
# since they do not detect the debug libraries correctly.
# The default files distributed with CMake (>= 3.9) should be superior by all means.
# For GDAL, the one distributed with CMake does not detect the debug libraries correctly,
# so we provide an own one.
file(REMOVE ${SOURCE_PATH}/CMake/FindGLEW.cmake)
file(REMOVE ${SOURCE_PATH}/CMake/FindPythonLibs.cmake)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindGDAL.cmake DESTINATION ${SOURCE_PATH}/CMake)

# =============================================================================
# Collect CMake options for optional components
if(VTK_WITH_QT)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_Group_Qt=ON
        -DVTK_QT_VERSION=5
        -DVTK_BUILD_QT_DESIGNER_PLUGIN=OFF
    )
endif()

if(VTK_WITH_MPI)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_Group_MPI=ON
    )
endif()

if(VTK_WITH_PYTHON)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_WRAP_PYTHON=ON
        -DVTK_PYTHON_VERSION=3
    )
endif()

if(VTK_WITH_ALL_MODULES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_BUILD_ALL_MODULES=ON
        -DVTK_USE_TK=OFF # TCL/TK currently not included in vcpkg
        # -DVTK_USE_SYSTEM_AUTOBAHN=ON
        # -DVTK_USE_SYSTEM_SIX=ON
        # -DVTK_USE_SYSTEM_MPI4PY=ON
        # -DVTK_USE_SYSTEM_CONSTANTLY=ON
        # -DVTK_USE_SYSTEM_INCREMENTAL=ON
        # -DVTK_USE_SYSTEM_TWISTED=ON
        # -DVTK_USE_SYSTEM_XDMF2=ON
        # -DVTK_USE_SYSTEM_XDMF3=ON
        # -DVTK_USE_SYSTEM_ZFP=ON
        # -DVTK_USE_SYSTEM_ZOPE=ON
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND ADDITIONAL_OPTIONS "-DVTK_EXTERNAL_HDF5_IS_SHARED=ON")
endif()

# =============================================================================
# Configure & Install
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DVTK_Group_Imaging=ON
        -DVTK_Group_Views=ON
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DVTK_USE_SYSTEM_EXPAT=ON
        -DVTK_USE_SYSTEM_FREETYPE=ON
        # -DVTK_USE_SYSTEM_GL2PS=ON
        -DVTK_USE_SYSTEM_LIBHARU=ON
        -DVTK_USE_SYSTEM_JPEG=ON
        -DVTK_USE_SYSTEM_GLEW=ON
        -DVTK_USE_SYSTEM_HDF5=ON
        -DVTK_USE_SYSTEM_JSONCPP=ON
        -DVTK_USE_SYSTEM_LIBPROJ4=ON
        -DVTK_USE_SYSTEM_LIBXML2=ON
        -DVTK_USE_SYSTEM_LZ4=ON
        # -DVTK_USE_SYSTEM_NETCDF=ON
        # -DVTK_USE_SYSTEM_NETCDFCPP=ON
        -DVTK_USE_SYSTEM_OGGTHEORA=ON
        -DVTK_USE_SYSTEM_PNG=ON
        -DVTK_USE_SYSTEM_TIFF=ON
        -DVTK_USE_SYSTEM_ZLIB=ON
        -DVTK_INSTALL_INCLUDE_DIR=include
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

# =============================================================================
# Fixup target files
vcpkg_fixup_cmake_targets()

# For some reason the references to the XDMF libraries in the target files do not end up
# correctly, so we fix them here.
if(VTK_WITH_ALL_MODULES)
    file(READ ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-release.cmake VTK_TARGETS_RELEASE_CONTENT)
    string(REPLACE "lib/../XdmfCore.lib" "lib/XdmfCore.lib" VTK_TARGETS_RELEASE_CONTENT "${VTK_TARGETS_RELEASE_CONTENT}")
    string(REPLACE "bin/../XdmfCore.dll" "bin/XdmfCore.dll" VTK_TARGETS_RELEASE_CONTENT "${VTK_TARGETS_RELEASE_CONTENT}")
    string(REPLACE "lib/../vtkxdmf3.lib" "lib/vtkxdmf3.lib" VTK_TARGETS_RELEASE_CONTENT "${VTK_TARGETS_RELEASE_CONTENT}")
    string(REPLACE "bin/../vtkxdmf3.dll" "bin/vtkxdmf3.dll" VTK_TARGETS_RELEASE_CONTENT "${VTK_TARGETS_RELEASE_CONTENT}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-release.cmake "${VTK_TARGETS_RELEASE_CONTENT}")

    file(READ ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-debug.cmake VTK_TARGETS_DEBUG_CONTENT)
    string(REPLACE "lib/../XdmfCore.lib" "lib/XdmfCore.lib" VTK_TARGETS_DEBUG_CONTENT "${VTK_TARGETS_DEBUG_CONTENT}")
    string(REPLACE "bin/../XdmfCore.dll" "bin/XdmfCore.dll" VTK_TARGETS_DEBUG_CONTENT "${VTK_TARGETS_DEBUG_CONTENT}")
    string(REPLACE "lib/../vtkxdmf3.lib" "lib/vtkxdmf3.lib" VTK_TARGETS_DEBUG_CONTENT "${VTK_TARGETS_DEBUG_CONTENT}")
    string(REPLACE "bin/../vtkxdmf3.dll" "bin/vtkxdmf3.dll" VTK_TARGETS_DEBUG_CONTENT "${VTK_TARGETS_DEBUG_CONTENT}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets-debug.cmake "${VTK_TARGETS_DEBUG_CONTENT}")
endif()

# For VTK `vcpkg_fixup_cmake_targets` is not enough:
# Files for system third party dependencies are written to modules that
# are located in the paths `share/vtk/Modules` and `debug/share/vtk/Modules`.
# In the release folder, only the release libraries are referenced (e.g. "C:/vcpkg/installed/x64-windows/lib/zlib.lib").
# But in the debug folder both libraries (e.g. "optimized;C:/vcpkg/installed/x64-windows/lib/zlib.lib;debug;C:/vcpkg/installed/x64-windows/debug/lib/zlibd.lib")
# or only the debug library (e.g. "C:/vcpkg/installed/x64-windows/debug/lib/hdf5_D.lib") is referenced.
# This is because VCPKG appends only the release library prefix (.../x64-windows/lib)
# when configuring release but both (.../x64-windows/lib and .../x64-windows/debug/lib)
# when configuring debug.
# Now if we delete the debug/share/Modules folder and just leave share/Modules, a library
# that links to VTK will always use the release third party dependencies, even if
# debug VTK is used.
# 
# The following code merges the libraries from both release and debug:

include(${CMAKE_CURRENT_LIST_DIR}/SplitLibraryConfigurations.cmake)

function(_vtk_combine_third_party_libraries MODULE_NAME)
    set(MODULE_LIBRARIES_REGEX "set\\(${MODULE_NAME}_LIBRARIES \"([^\"]*)\"\\)")

    # Read release libraries
    file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/${MODULE_NAME}.cmake" RELEASE_MODULE_CONTENT)
    if("${RELEASE_MODULE_CONTENT}" MATCHES "${MODULE_LIBRARIES_REGEX}")
        set(RELEASE_LIBRARY_LIST "${CMAKE_MATCH_1}")
    else()
        message(FATAL_ERROR "Could not extract module libraries for ${MODULE_NAME}")
    endif()

    # Read debug libraries
    file(READ "${CURRENT_PACKAGES_DIR}/debug/share/vtk/Modules/${MODULE_NAME}.cmake" DEBUG_MODULE_CONTENT)
    if("${DEBUG_MODULE_CONTENT}" MATCHES "${MODULE_LIBRARIES_REGEX}")
        set(DEBUG_LIBRARY_LIST "${CMAKE_MATCH_1}")
    else()
        message(FATAL_ERROR "Could not extract module libraries for ${MODULE_NAME}")
    endif()
    
    split_library_configurations("${RELEASE_LIBRARY_LIST}" OPTIMIZED_RELEASE_LIBRARIES DEBUG_RELEASE_LIBRARIES GENERAL_RELEASE_LIBRARIES)
    split_library_configurations("${DEBUG_LIBRARY_LIST}" OPTIMIZED_DEBUG_LIBRARIES DEBUG_DEBUG_LIBRARIES GENERAL_DEBUG_LIBRARIES)

    # Combine libraries and wrap them in generator expressions
    foreach(LIBRARY ${OPTIMIZED_RELEASE_LIBRARIES} ${GENERAL_RELEASE_LIBRARIES})
        list(APPEND LIBRARY_LIST "$<$<NOT:$<CONFIG:Debug>>:${LIBRARY}>")
    endforeach()
    foreach(LIBRARY ${DEBUG_DEBUG_LIBRARIES} ${GENERAL_DEBUG_LIBRARIES})
        list(APPEND LIBRARY_LIST "$<$<CONFIG:Debug>:${LIBRARY}>")
    endforeach()

    # Write combined libraries back
    string(REGEX REPLACE "${MODULE_LIBRARIES_REGEX}"
        "set(${MODULE_NAME}_LIBRARIES \"${LIBRARY_LIST}\")"
        RELEASE_MODULE_CONTENT
        "${RELEASE_MODULE_CONTENT}"
    )
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/Modules/${MODULE_NAME}.cmake" "${RELEASE_MODULE_CONTENT}")
endfunction()

# IMPORTANT: Please make sure to extend this list whenever a new library is marked `USE_SYSTEM` in the configure step above!
set(SYSTEM_THIRD_PARTY_MODULES
    vtkexpat
    vtkfreetype
    vtkjpeg
    vtkglew
    vtkhdf5
    vtkjsoncpp
    vtklibproj4
    vtklibxml2
    vtklz4
    vtkoggtheora
    vtkpng
    vtktiff
    vtkzlib
    # vtkgl2ps
    vtklibharu
)

if(VTK_WITH_PYTHON OR VTK_WITH_ALL_MODULES)
    list(APPEND SYSTEM_THIRD_PARTY_MODULES
        vtkPython
    )
endif()

if(VTK_WITH_ALL_MODULES)
    list(APPEND SYSTEM_THIRD_PARTY_MODULES
        AutobahnPython
    )
endif()

foreach(MODULE IN LISTS SYSTEM_THIRD_PARTY_MODULES)
    _vtk_combine_third_party_libraries("${MODULE}")
endforeach()

# Remove all explicit references to vcpkg system libraries in the general VTKTargets.cmake file
# since these references always point to the release libraries, even in the debug case.
# The dependencies should be handled by the explicit modules we fixed above, so removing
# them here shouldn't cause any problems.
file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets.cmake" VTK_TARGETS_CONTENT)
string(REGEX REPLACE "${CURRENT_INSTALLED_DIR}/lib/[^\\.]*\\.lib" "" VTK_TARGETS_CONTENT "${VTK_TARGETS_CONTENT}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/VTKTargets.cmake" "${VTK_TARGETS_CONTENT}")

# =============================================================================
# Move executable to tools directory and clean-up other directories
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/vtk)

function(_vtk_move_tool TOOL_NAME)
    if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME}.exe)
        file(RENAME ${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME}.exe ${CURRENT_PACKAGES_DIR}/tools/vtk/${TOOL_NAME}.exe)
    endif()

    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME}.exe)
endfunction()

set(VTK_TOOLS
    vtkEncodeString-${VTK_SHORT_VERSION}
    vtkHashSource-${VTK_SHORT_VERSION}
    vtkWrapTclInit-${VTK_SHORT_VERSION}
    vtkWrapTcl-${VTK_SHORT_VERSION}
    vtkWrapPythonInit-${VTK_SHORT_VERSION}
    vtkWrapPython-${VTK_SHORT_VERSION}
    vtkWrapJava-${VTK_SHORT_VERSION}
    vtkWrapHierarchy-${VTK_SHORT_VERSION}
    vtkParseJava-${VTK_SHORT_VERSION}
    vtkParseOGLExt-${VTK_SHORT_VERSION}
    vtkpython
    pvtkpython
)

foreach(TOOL_NAME IN LISTS VTK_TOOLS)
    _vtk_move_tool("${TOOL_NAME}")
endforeach()

# =============================================================================
# Remove other files and directories that are not valid for vcpkg
if(VTK_WITH_ALL_MODULES)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/XdmfConfig.cmake)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/XdmfConfig.cmake)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# =============================================================================
# Handle copyright
file(COPY ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/vtk/Copyright.txt ${CURRENT_PACKAGES_DIR}/share/vtk/copyright)
