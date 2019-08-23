include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lz4/lz4
    REF v1.9.2
    SHA512 ae714c61ec8e33ed91359b63f2896cfa102d66b730dce112b74696ec5850e59d88bd5527173e01e354a70fbe8f036557a47c767ee0766bc5f9c257978116c3c1
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

