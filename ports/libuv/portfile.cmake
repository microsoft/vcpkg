include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src/libuv-1.10.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libuv/libuv/archive/v1.10.1.zip"
    FILENAME "libuv-v1.10.1.zip"
    SHA512 5a1e4b8e4584fccbc3df5bb46cf0efd7165169709d9b2a0e06fe534afbf7a262500cf665441ef64f8f7029b535f722119ab0faa4fb1367b05452d88a3e02bd2b
)

vcpkg_download_distfile(GYP
    URLS
        "https://github.com/adblockplus/gyp/archive/a7055b3989c1074adca03b4b4829e7f0e57f6efd.zip"
        "https://github.com/bnoordhuis/gyp/archive/a7055b3989c1074adca03b4b4829e7f0e57f6efd.zip"
    FILENAME "gyp-a7055b3989c1074adca03b4b4829e7f0e57f6efd.zip"
    SHA512 edf00b4a44de21e9d90288164c3b746a7628cc10f56c8b82031b1240db61d3e2c5a48fc4037d87411b740b29c2c6ec40d671f59241f276c6a091dd53ca58381e
)

if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src)
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src)
endif()

file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src)
vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src)

file(MAKE_DIRECTORY ${SOURCE_PATH}/build)
vcpkg_extract_source_archive(${GYP} ${SOURCE_PATH}/build)
file(RENAME ${SOURCE_PATH}/build/gyp-a7055b3989c1074adca03b4b4829e7f0e57f6efd ${SOURCE_PATH}/build/gyp)

vcpkg_find_acquire_program(PYTHON2)
set(ENV{PYTHON} ${PYTHON2})
set(ENV{GYP_MSVS_VERSION} 2015)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(LIBUV_LINKAGE shared_library)
else()
    set(LIBUV_LINKAGE static_library)
endif()

if(TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(GYP_ARCH ia32)
    set(MSBUILD_PLATFORM WIN32)
elseif(TRIPLET_SYSTEM_ARCH MATCHES "x64")
    set(GYP_ARCH x64)
    set(MSBUILD_PLATFORM x64)
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

message(STATUS "Generating solution")
vcpkg_execute_required_process(
    COMMAND "${PYTHON2}" gyp_uv.py -Dtarget_arch=${GYP_ARCH} -Duv_library=${LIBUV_LINKAGE}
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME ${TARGET_TRIPLET}-generate
)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/uv.sln
    PLATFORM ${MSBUILD_PLATFORM}
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY
    ${SOURCE_PATH}/include/tree.h
    ${SOURCE_PATH}/include/uv.h
    ${SOURCE_PATH}/include/uv-version.h
    ${SOURCE_PATH}/include/uv-errno.h
    ${SOURCE_PATH}/include/uv-threadpool.h
    ${SOURCE_PATH}/include/uv-win.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug/lib)
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY ${SOURCE_PATH}/Debug/libuv.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${SOURCE_PATH}/Release/libuv.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${SOURCE_PATH}/Debug/libuv.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY ${SOURCE_PATH}/Release/libuv.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
else()
    file(COPY ${SOURCE_PATH}/Debug/lib/libuv.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${SOURCE_PATH}/Release/lib/libuv.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endif()


file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/libuv)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libuv)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/libuv/LICENSE ${CURRENT_PACKAGES_DIR}/share/libuv/copyright)
vcpkg_copy_pdbs()
