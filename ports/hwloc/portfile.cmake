vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-mpi/hwloc
    REF hwloc-1.11.7
    SHA512 bc3a74c60bfbed1e860c2fe2b5b49956eca5cfd9c00a262f6cd3026a42ae8b5411fa296e471a95cba657d943b8853675442e796e648034398af3015e5f59476e
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
