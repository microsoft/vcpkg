include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lz4/lz4
    REF v1.8.1.2
    SHA512 f4ed450bc05477cc6c2b42e6fe1fbb1fb0907f1d05b68b1d69d975b555ddb385550f204258e6d91642e14ce373815141dc218cda03b711793935d5458bc45c7f
    HEAD_REF dev)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DLZ4_SKIP_INCLUDES=ON)

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

file(COPY ${SOURCE_PATH}/lib/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/lz4)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/lz4/LICENSE ${CURRENT_PACKAGES_DIR}/share/lz4/copyright)
