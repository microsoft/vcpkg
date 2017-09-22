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
)

# Remove the FindGLEW.cmake that is distributed with VTK, since it does not
# detect the debug libraries correctly.
# The default file distributed with CMake should be superior by all means.
file(REMOVE ${SOURCE_PATH}/CMake/FindGLEW.cmake)

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
        # -DVTK_USE_SYSTEM_LIBHARU=ON
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

vcpkg_fixup_cmake_targets()

# For VTK vcpkg_fixup_cmake_targets is not enough:
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
)

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

# Move executable to tools directory
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/vtk)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vtkEncodeString-8.0.exe ${CURRENT_PACKAGES_DIR}/tools/vtk/vtkEncodeString-8.0.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vtkHashSource-8.0.exe ${CURRENT_PACKAGES_DIR}/tools/vtk/vtkHashSource-8.0.exe)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vtkEncodeString-8.0.exe)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vtkHashSource-8.0.exe)
else()
    # On static builds there should be no bin directory at all
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/vtk/Copyright.txt ${CURRENT_PACKAGES_DIR}/share/vtk/copyright)
