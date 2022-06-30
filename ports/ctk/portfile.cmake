# Clone
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commontk/CTK
    REF ec816cbb77986f6ee28c41a495e82238dee0e2d3 # 2022.05.17
    SHA512 fc5044a6110304e47a24542cd34545bbe58e1e4c695c3cec7e3bed2230e3317a0823d25ab01216a884c0efa1146c5817782e20154d16999fc63fcb6192912ccd
    HEAD_REF master
)

# Configure and build
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCTK_QT_VERSION=5
        -DCTK_ENABLE_DICOM=ON
        -DCTK_ENABLE_Widgets=ON
        -DCTK_SUPERBUILD=OFF
)
vcpkg_cmake_install()

# VCPKG Fixup
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/ctk-0.1/CMake")
vcpkg_copy_pdbs()

# Remove debug built files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Move library dlls to bin
set (CTK_DLLS "CTKCore.dll;CTKDICOMCore.dll;CTKDICOMWidgets.dll;CTKDummyPlugin.dll;CTKWidgets.dll;designer/CTKDICOMWidgetsPlugins.dll;designer/CTKWidgetsPlugins.dll")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin/designer")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin/designer")

foreach (DLL_FILE ${CTK_DLLS})
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/ctk-0.1/${DLL_FILE}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/ctk-0.1/${DLL_FILE}" "${CURRENT_PACKAGES_DIR}/bin/${DLL_FILE}")
    endif()
endforeach()

foreach (DLL_FILE ${CTK_DLLS})
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/ctk-0.1/${DLL_FILE}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/ctk-0.1/${DLL_FILE}" "${CURRENT_PACKAGES_DIR}/debug/bin/${DLL_FILE}")
    endif()
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/ctk-0.1/designer" "${CURRENT_PACKAGES_DIR}/lib/ctk-0.1/designer")

# Copy usage and license
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
