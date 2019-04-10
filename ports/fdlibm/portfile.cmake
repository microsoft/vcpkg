include(vcpkg_common_functions)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://android.googlesource.com/platform/external/fdlibm
    REF 59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac
    SHA512 75c49ba2875b73e0bfe3a4595be1478ce6041236653b803b02ba00997652c969c351c9647923692af0799149da86c737467ab2954bd8845a2f75b14fde71ac29
	#bc788c840a57716f996513980d31b203bd86ce9af1ac3656a187266bfdc2fbb22a9ddf88f79ffc91dd75f3f1f1e4fd3449a42b566ffe5e49e9384efd91a68613
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
