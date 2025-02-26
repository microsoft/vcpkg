set(base_url "https://developer.download.nvidia.com/compute/cuda/redist")
set(redistrib_json_url "${base_url}/redistrib_${VERSION}.json")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(target x86_64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" AND VCPKG_TARGET_IS_LINUX)
    set(target aarch64)
else()
    message(FATAL_ERROR "Unsupported architecture!")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    set(platform windows)
else()
    set(platform linux)
endif()

set(platform_key "${platform}-${target}")

set(update_opt "")
#set(cuda_updating 1)
if(cuda_updating)
    set(VCPKG_USE_HEAD_VERSION 1)
    set(update_opt SKIP_SHA512)
    message(STATUS "Running ${PORT} in update mode!")
else()
    include("${CURRENT_PORT_DIR}/hash-${platform}-${target}.cmake")
endif()

vcpkg_download_distfile(
    cuda_redist_json
    URLS "${redistrib_json_url}"
    FILENAME "cuda-redistrib-${VERSION}.json"
    SHA512 "${cuda-json_HASH}"
    ${update_opt}
)

if(cuda_updating)
    file(SHA512 "${cuda_redist_json}" hash)
    string(APPEND update_hash "set(cuda-json_HASH \"${hash}\")\n")
endif()

file(READ "${cuda_redist_json}" cuda_json)

set(install_folder "${CURRENT_PACKAGES_DIR}/compiler/cuda")
file(MAKE_DIRECTORY "${install_folder}")

string(JSON comp_json_length LENGTH "${cuda_json}")
math(EXPR comp_json_length "${comp_json_length} - 1")
set(licenses "")
foreach(index RANGE "${comp_json_length}")
    string(JSON comp MEMBER "${cuda_json}" "${index}")
    #message(STATUS "comp:${comp}")
    if(comp MATCHES "(^release_|documentation|_demo_|visual_studio_integration)")
        continue()
    endif()
    string(JSON comp_json GET "${cuda_json}" "${comp}")
    string(JSON lic_rel_url GET   "${comp_json}" "license_path")
    string(JSON comp_plat_json ERROR_VARIABLE comp_err GET "${comp_json}" "${platform_key}")
    if(comp_err)
        continue()
    endif()
    string(JSON comp_plat_rel_url GET "${comp_plat_json}" "relative_path")

    set(lic_url "${base_url}/${lic_rel_url}")
    set(comp_url "${base_url}/${comp_plat_rel_url}")

    vcpkg_download_distfile(
        "lic_${comp}"
        URLS "${lic_url}"
        FILENAME "${lic_rel_url}"
        SHA512 "${lic_${comp}_HASH}"
        ${update_opt}
    )
    list(APPEND licenses "${lic_${comp}}")
    if(cuda_updating)
        file(SHA512 "${lic_${comp}}" hash)
        string(APPEND update_hash "set(lic_${comp}_HASH \"${hash}\")\n")
    endif()

    cmake_path(GET comp_plat_rel_url FILENAME comp_filename)

    vcpkg_download_distfile(
        "${comp}"
        URLS "${comp_url}"
        FILENAME "${comp_filename}"
        SHA512 "${${comp}_HASH}"
        ${update_opt}
    )
    if(cuda_updating)
        file(SHA512 "${${comp}}" hash)
        string(APPEND update_hash "set(${comp}_HASH \"${hash}\")\n")
        continue()
    endif()

    vcpkg_extract_source_archive(
        comp-src
        ARCHIVE ${${comp}}
    )
    file(COPY "${comp-src}/" DESTINATION "${install_folder}")
endforeach()

if(cuda_updating)
    file(WRITE "${CURRENT_PORT_DIR}/new_hash-${platform}-${target}.cmake" "${update_hash}\n")
    message(FATAL_ERROR "New hashes obtained!")
endif()

vcpkg_install_copyright(FILE_LIST ${licenses})

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/CUDAToolkit/vcpkg-cmake-wrapper.cmake" @ONLY)
#configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg_find_cuda.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg_find_cuda.cmake" @ONLY)

configure_file("${CMAKE_CURRENT_LIST_DIR}/cuda-env.cmake" "${CURRENT_PACKAGES_DIR}/env-setup/cuda-env.cmake" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/cuda-env.ps1" "${CURRENT_PACKAGES_DIR}/env-setup/cuda-env.ps1" @ONLY)

vcpkg_fixup_pkgconfig()

set(VCPKG_POLICY_SKIP_DUMPBIN_CHECKS enabled)
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)
set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)
set(VCPKG_POLICY_ONLY_RELEASE_CRT enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_ALLOW_EMPTY_FOLDERS enabled)
