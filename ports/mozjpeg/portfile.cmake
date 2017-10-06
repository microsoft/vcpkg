include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mozilla/mozjpeg
    REF v3.2
    SHA512 d14789827a9f4f78139a3945d3169d37eb891758b5ab40ef19e99ebebb2fb6d7c3a05495de245bba54cfd913b153af352159aa9fc0218127f97819137e0f1ab8
    HEAD_REF master
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${NASM_EXE_PATH}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(OPTIONS "-DENABLE_SHARED=FALSE")
else()
    set(OPTIONS "-DENABLE_STATIC=FALSE")
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" WITH_CRT_DLL)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${OPTIONS}
        -DWITH_CRT_DLL=${WITH_CRT_DLL}
)

vcpkg_install_cmake()

#remove extra debug files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)
file(GLOB DEBUGEXES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${DEBUGEXES})

#move exes to tools
file(GLOB EXES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/mozjpeg)
file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mozjpeg)
file(REMOVE ${EXES})

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/mozjpeg)

#remove empty folders after static build
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/mozjpeg RENAME copyright)
vcpkg_copy_pdbs()