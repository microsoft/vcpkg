include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dreamworksanimation/openvdb
    REF v5.0.0
    SHA512 8916d54683d81144114e57f8332be43b7547e6da5d194f6147bcefd4ee9e8e7ec817f27b65adb129dfd149e6b308f4bab30591ee953ee2c319636491bf051a2b
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/UseGLEWOnWindowsForViewer.patch
    ${CMAKE_CURRENT_LIST_DIR}/AddLinkageAndToolsChoice.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(OPENVDB_STATIC ON)
    set(OPENVDB_SHARED OFF)
else()
    set(OPENVDB_STATIC OFF)
    set(OPENVDB_SHARED ON)
endif()

if ("tools" IN_LIST FEATURES)
    set(OPENVDB_BUILD_TOOLS ON)
    set(OPENVDB_SHARED ON) # tools require shared version of the library
else()
    set(OPENVDB_BUILD_TOOLS OFF)
endif()

file(TO_NATIVE_PATH "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}" INSTALL_LOCATION)

file(TO_NATIVE_PATH "${INSTALL_LOCATION}/include" INCLUDE_LOCATION)
file(TO_NATIVE_PATH "${INSTALL_LOCATION}/lib/" LIB_LOCATION)
file(TO_NATIVE_PATH "${INSTALL_LOCATION}/debug/lib/" LIB_LOCATION_DEBUG)

file(TO_NATIVE_PATH "${LIB_LOCATION}/zlib.lib" ZLIB_LIBRARY)
file(TO_NATIVE_PATH "${LIB_LOCATION}/tbb.lib" Tbb_TBB_LIBRARY)
file(TO_NATIVE_PATH "${LIB_LOCATION}/tbbmalloc.lib" Tbb_TBBMALLOC_LIBRARY)
file(TO_NATIVE_PATH "${LIB_LOCATION_DEBUG}/tbb_debug.lib" Tbb_TBB_LIBRARY_DEBUG)
file(TO_NATIVE_PATH "${LIB_LOCATION_DEBUG}/tbbmalloc_debug.lib" Tbb_TBBMALLOC_LIBRARY_DEBUG)

file(TO_NATIVE_PATH "${LIB_LOCATION}/Half.lib" Ilmbase_HALF_LIBRARY)
file(TO_NATIVE_PATH "${LIB_LOCATION}/Iex-2_2.lib" Ilmbase_IEX_LIBRARY)
file(TO_NATIVE_PATH "${LIB_LOCATION}/IlmThread-2_2.lib" Ilmbase_ILMTHREAD_LIBRARY)

if (OPENVDB_STATIC)
    file(TO_NATIVE_PATH "${LIB_LOCATION}/glfw3.lib" GLFW3_LIBRARY)
else()
    file(TO_NATIVE_PATH "${LIB_LOCATION}/glfw3dll.lib" GLFW3_LIBRARY)
endif()


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DOPENVDB_BUILD_UNITTESTS=OFF
            -DOPENVDB_BUILD_PYTHON_MODULE=OFF
            -DOPENVDB_ENABLE_3_ABI_COMPATIBLE=OFF
            -DUSE_GLFW3=ON
            -DGLFW3_USE_STATIC_LIBS=${OPENVDB_STATIC}
            -DBlosc_USE_STATIC_LIBS=${OPENVDB_STATIC}
            -DOpenexr_USE_STATIC_LIBS=${OPENVDB_STATIC}
            -DIlmbase_USE_STATIC_LIBS=${OPENVDB_STATIC}
            -DGLFW3_glfw_LIBRARY=${GLFW3_LIBRARY}

            -DIlmbase_HALF_LIBRARY=${Ilmbase_HALF_LIBRARY}
            -DIlmbase_IEX_LIBRARY=${Ilmbase_IEX_LIBRARY}
            -DIlmbase_ILMTHREAD_LIBRARY=${Ilmbase_ILMTHREAD_LIBRARY}

            -DOPENVDB_STATIC=${OPENVDB_STATIC}
            -DOPENVDB_SHARED=${OPENVDB_SHARED}
            -DOPENVDB_BUILD_TOOLS=${OPENVDB_BUILD_TOOLS}

            -DZLIB_INCLUDE_DIR=${INCLUDE_LOCATION}
            -DTBB_INCLUDE_DIR=${INCLUDE_LOCATION}
            -DZLIB_LIBRARY=${ZLIB_LIBRARY}

            -DGLFW3_LOCATION=${INSTALL_LOCATION}
            -DGLEW_LOCATION=${INSTALL_LOCATION}
            -DILMBASE_LOCATION=${INSTALL_LOCATION}
            -DOPENEXR_LOCATION=${INSTALL_LOCATION}
            -DTBB_LOCATION=${INSTALL_LOCATION}
            -DBLOSC_LOCATION=${INSTALL_LOCATION}
    OPTIONS_RELEASE
        -DTBB_LIBRARY_PATH=${LIB_LOCATION}
        -DTbb_TBB_LIBRARY=${Tbb_TBB_LIBRARY}
        -DTbb_TBBMALLOC_LIBRARY=${Tbb_TBBMALLOC_LIBRARY}
    OPTIONS_DEBUG
        -DTBB_LIBRARY_PATH=${LIB_LOCATION_DEBUG}
        -DTbb_TBB_LIBRARY=${Tbb_TBB_LIBRARY_DEBUG}
        -DTbb_TBBMALLOC_LIBRARY=${Tbb_TBBMALLOC_LIBRARY_DEBUG}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (OPENVDB_BUILD_TOOLS)
    # copy tools to tools/openvdb directory
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vdb_print.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/vdb_print.exe)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vdb_render.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/vdb_render.exe)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vdb_view.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/vdb_view.exe)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

    # remove debug versions of tools
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vdb_render.exe)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vdb_print.exe)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vdb_view.exe)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/openvdb/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/openvdb RENAME copyright)
