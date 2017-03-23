include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src/libuv-1.10.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libuv/libuv/archive/v1.10.1.zip"
    FILENAME "libuv-v1.10.1.zip"
    SHA512 5a1e4b8e4584fccbc3df5bb46cf0efd7165169709d9b2a0e06fe534afbf7a262500cf665441ef64f8f7029b535f722119ab0faa4fb1367b05452d88a3e02bd2b
)

vcpkg_download_distfile(GYP
    URLS "https://chromium.googlesource.com/external/gyp/+archive/aae1e3efb50786df20e9572621fb746865f0df53.tar.gz"
    FILENAME "gyp-aae1e3efb50786df20e9572621fb746865f0df53.tar.gz"
    SHA512 ccabd8dc611fdb608dca460c14710089612034f6f8151ae41cf22397ac191110ddec8195a7c239096e517a5527cdabf9a1e6108d9aa8140efd09c5ffcce1a1e7
)

if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src)
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src)
endif()

file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src)
vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-src)

file(MAKE_DIRECTORY ${SOURCE_PATH}/build/gyp)
vcpkg_extract_source_archive(${GYP} ${SOURCE_PATH}/build/gyp)

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
