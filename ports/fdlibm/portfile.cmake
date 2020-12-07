vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://android.googlesource.com/platform/external/fdlibm
    REF 59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac
    SHA512 954c75f9f7540f4efb21b1f8de296149c648c0ba10d5e9cc99a247164b9e99b6dc37349a9ddaa04ba93dc035562457665aacf7146926d716cd406b63b97c5d44
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libm5.def DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG 
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
configure_file(${SOURCE_PATH}/NOTICE ${CURRENT_PACKAGES_DIR}/share/fdlibm/copyright COPYONLY)
 
