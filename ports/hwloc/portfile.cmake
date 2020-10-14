vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-mpi/hwloc
    REF 263908a2c1f21c0e221a8d1f6472daf3a1fc07b9 # hwloc-2.2.0
    SHA512 87f3d267781fd1f8907b0c080868b56943c7c2caecae5c0fbe9a55f8c5e9453bb6b7892834ba37696c1ebadd8d7bfdd5e513ea72a075211b808a1d5803ea4b8e
)

if (VCPKG_TARGET_IS_WINDOWS)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH} 
        PREFER_NINJA
    )
    
    vcpkg_install_cmake()
    
    file(READ ${CURRENT_PACKAGES_DIR}/include/hwloc/autogen/config.h PUBLIC_CONFIG_H)
    string(REPLACE "defined( DECLSPEC_EXPORTS )" "0" PUBLIC_CONFIG_H "${PUBLIC_CONFIG_H}")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        string(REPLACE "defined( _USRDLL )" "0" PUBLIC_CONFIG_H "${PUBLIC_CONFIG_H}")
    else()
        string(REPLACE "defined( _USRDLL )" "1" PUBLIC_CONFIG_H "${PUBLIC_CONFIG_H}")
    endif()
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/hwloc/autogen/config.h "${PUBLIC_CONFIG_H}")
    
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/tools)
else()
    message(WARNING "${PORT} currently requires the following tool from the system package manager:\n    libtool")

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
        OPTIONS
            --disable-libxml2
            --disable-opencl
    )
    
    vcpkg_install_make()
    
    file(GLOB HWLOC_EXEC ${CURRENT_PACKAGES_DIR}/bin)
    message("HWLOC_EXEC: ${HWLOC_EXEC}")
    if (HWLOC_EXEC)
        file(COPY ${HWLOC_EXEC} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
