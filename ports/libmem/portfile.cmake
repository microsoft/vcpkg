vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdbo/libmem
    REF 5.0.2
    SHA512 d7c5a1a42d65a00ed3aa8ba8f6974650801d3436ae90e072fea29d4dcb32a3963e2610c89a16b87d94a9613c8f2f0e8deb83b673a1771a9cd1eb716a56106a16
    HEAD_REF master
)

set(VCPKG_LIBRARY_LINKAGE static)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE EQUAL "static") 
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /DLM_EXPORT")
endif()

if(EXISTS "${SOURCE_PATH}/PreLoad.cmake")
    message(WARNING "Removing PreLoad.cmake")
    file(REMOVE "${SOURCE_PATH}/PreLoad.cmake")
else()
    message(WARNING "PreLoad.cmake not found.")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
    DESTINATION "${SOURCE_PATH}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-libmem-config.cmake.in" 
    DESTINATION "${SOURCE_PATH}")

#if(VCPKG_TARGET_IS_WINDOWS)
#    vcpkg_cmake_configure(
#        SOURCE_PATH ${SOURCE_PATH}
#        GENERATOR "NMake Makefiles"
#        DISABLE_PARALLEL_CONFIGURE
#    )
#else()
#    vcpkg_cmake_configure(
#        SOURCE_PATH ${SOURCE_PATH}
#        GENERATOR "Unix Makefiles"
#        DISABLE_PARALLEL_CONFIGURE
#    )
#endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-libmem")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
