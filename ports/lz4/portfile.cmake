include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lz4/lz4
    REF v1.8.3
    SHA512 5d284f75a0c4ad11ebc4abb4394d98c863436da0718d62f648ef2e2cda8e5adf47617a4b43594375f7b0b673541a9ccfaf73880a55fd240986594558214dbf9f
    HEAD_REF dev
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()

file(GLOB_RECURSE LZ4_HEADERS "${SOURCE_PATH}/*.h")

foreach(FILE ${LZ4_HEADERS})
    file(READ ${FILE} LZ4_HEADER)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        string(REPLACE "defined(LZ4_DLL_IMPORT) && (LZ4_DLL_IMPORT==1)" "1" LZ4_HEADER "${LZ4_HEADER}")
    else()
        string(REPLACE "defined(LZ4_DLL_IMPORT) && (LZ4_DLL_IMPORT==1)" "0" LZ4_HEADER "${LZ4_HEADER}")
    endif()
    file(WRITE ${FILE} "${LZ4_HEADER}")
endforeach()

file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share/lz4/lz4Config-debug.cmake ${CURRENT_PACKAGES_DIR}/share/lz4/lz4Config-debug.cmake)
file(READ ${CURRENT_PACKAGES_DIR}/share/lz4/lz4Config-debug.cmake LZ4_TARGET_DEBUG)
string(REPLACE "/lib/"
               "/debug/lib/" LZ4_TARGET_DEBUG "${LZ4_TARGET_DEBUG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/lz4/lz4Config-debug.cmake "${LZ4_TARGET_DEBUG}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/lib/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/lz4)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/lz4/LICENSE ${CURRENT_PACKAGES_DIR}/share/lz4/copyright)
