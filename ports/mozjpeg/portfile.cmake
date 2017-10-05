include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mozjpeg-3.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mozilla/mozjpeg/archive/v3.2.zip"
    FILENAME "mozjpeg.zip"
    SHA512 a1ba53dea3e04add46616918b5e96f2c8102ef65856596f1794df29c8be27db3d9fb13e7ffc864d23626f98dff5a6b47315903cae9ae41f9905aef2cc91af0c5
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${NASM_EXE_PATH}")

vcpkg_extract_source_archive(${ARCHIVE})

if (${VCPKG_LIBRARY_LINKAGE} STREQUAL static)
    set(OPTIONS "-DENABLE_SHARED=FALSE")
else()
    set(OPTIONS "-DENABLE_STATIC=FALSE")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA 
    OPTIONS ${OPTIONS}
)

vcpkg_install_cmake()

#remove extra debug files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)
file(GLOB DEBUGEXES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${DEBUGEXES})

#move exes to tools
file(GLOB EXES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE ${EXES})

#remove empty fodlers after static build
if (${VCPKG_LIBRARY_LINKAGE} STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/mozjpeg RENAME copyright)
vcpkg_copy_pdbs()