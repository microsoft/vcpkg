include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/zstd
    REF v1.3.0
    SHA512 5eb9e001e14d3342e76eb57b672c636fd56839ba8fc0ba9a751484ea93389c72c494ad2125dc2f9be1f72481f3af34568477123f7e9d3c7504e061e4c083cb30
    HEAD_REF dev)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(ZSTD_STATIC 1)
    set(ZSTD_SHARED 0)
else()
    set(ZSTD_STATIC 0)
    set(ZSTD_SHARED 1)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/build/cmake
    PREFER_NINJA
    OPTIONS
        -DZSTD_BUILD_SHARED=${ZSTD_SHARED}
        -DZSTD_BUILD_STATIC=${ZSTD_STATIC}
        -DZSTD_LEGACY_SUPPORT=1
        -DZSTD_BUILD_PROGRAMS=0
        -DZSTD_BUILD_TESTS=0
        -DZSTD_BUILD_CONTRIB=0)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    foreach(HEADER zdict.h zstd.h zstd_errors.h)
        file(READ ${CURRENT_PACKAGES_DIR}/include/${HEADER} HEADER_CONTENTS)
        string(REPLACE "defined(ZSTD_DLL_IMPORT) && (ZSTD_DLL_IMPORT==1)" "1" HEADER_CONTENTS "${HEADER_CONTENTS}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/${HEADER} "${HEADER_CONTENTS}")
    endforeach()
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/zstd)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/zstd/LICENSE ${CURRENT_PACKAGES_DIR}/share/zstd/copyright)
