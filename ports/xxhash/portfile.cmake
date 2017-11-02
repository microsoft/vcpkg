include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cyan4973/xxHash
    REF v0.6.3
    SHA512 5b11009ecf142725c642be55e9072792709bd40d8674f30afdc13f9b9fd6936ea69e683c7b9df212b5126f9ba3925969fc0b65bb5518506b501bb339d3a29372
    HEAD_REF dev)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake_unofficial
    PREFER_NINJA
    OPTIONS
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(READ ${CURRENT_PACKAGES_DIR}/include/xxhash.h XXHASH_H)
    string(REPLACE "#  define XXH_PUBLIC_API   /* do nothing */" "#  define XXH_PUBLIC_API __declspec(dllimport)" XXHASH_H "${XXHASH_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/xxhash.h "${XXHASH_H}")

    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/xxhsum.exe ${CURRENT_PACKAGES_DIR}/debug/bin/xxhsum.exe)
else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)  
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xxhash)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xxhash/LICENSE ${CURRENT_PACKAGES_DIR}/share/xxhash/copyright)
