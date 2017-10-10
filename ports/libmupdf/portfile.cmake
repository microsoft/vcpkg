if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
    set(VCPKG_CRT_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)
vcpkg_download_distfile(ARCHIVE
    URLS "https://mupdf.com/downloads/mupdf-1.11-source.tar.gz"
    FILENAME "mupdf.tar.gz"
    SHA512 501670f540e298a8126806ebbd9db8b29866f663b7bbf26c9ade1933e42f0c00ad410b9d93f3ddbfb3e45c38722869095de28d832fe3fb3703c55cc9a01dbf63
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CURRENT_PORT_DIR}/libmupdf.vcxproj
    DESTINATION ${SOURCE_PATH}/mupdf-1.11-source/platform/win32)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/mupdf-1.11-source/platform/win32/libmupdf.vcxproj
    OPTIONS 
        /ignoreprojectextensions:.vcproj,.sln 
    OPTIONS_RELEASE /p:OutDir=${CURRENT_PACKAGES_DIR}/lib
    OPTIONS_DEBUG /p:OutDir=${CURRENT_PACKAGES_DIR}/debug/lib
)

#copy include files to package
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
set(CMD cmake -E copy_directory ${SOURCE_PATH}/mupdf-1.11-source/include/mupdf ${CURRENT_PACKAGES_DIR}/include)
execute_process(COMMAND ${CMD})

#copyright
file(COPY ${SOURCE_PATH}/mupdf-1.11-source/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYRIGHT)
vcpkg_copy_pdbs()