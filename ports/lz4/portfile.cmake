include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lz4/lz4
    REF v1.9.0
    SHA512 f9e78df262818192800157d6ed64d42c06e918062afc93e3098d00f5f49fd3279b5709486a7d8841708a4ce1c539381225f0813e6a342f49d13b576eb61eb444
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
vcpkg_copy_pdbs()

foreach(FILE lz4.h lz4frame.h)
    file(READ ${CURRENT_PACKAGES_DIR}/include/${FILE} LZ4_HEADER)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        string(REPLACE "defined(LZ4_DLL_IMPORT) && (LZ4_DLL_IMPORT==1)" "1" LZ4_HEADER "${LZ4_HEADER}")
    else()
        string(REPLACE "defined(LZ4_DLL_IMPORT) && (LZ4_DLL_IMPORT==1)" "0" LZ4_HEADER "${LZ4_HEADER}")
    endif()
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/${FILE} "${LZ4_HEADER}")
endforeach()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/lib/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/lz4)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/lz4/LICENSE ${CURRENT_PACKAGES_DIR}/share/lz4/copyright)
