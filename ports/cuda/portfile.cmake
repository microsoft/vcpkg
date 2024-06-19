set(base_url "https://developer.download.nvidia.com/compute/cuda/redist")

if(VCPKG_TARGET_IS_WINDOWS)
  set(VCPKG_CRT_LINKAGE "static")
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(target x86_64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" AND VCPKG_TARGET_IS_LINUX)
    set(target sbsa)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "ppc64" AND VCPKG_TARGET_IS_LINUX)
    set(target ppc64le)
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    set(platform windows)
else()
    set(platform linux)
endif()

set(components
        cccl # < contains cmake files
        compat
        cudart
        nvtx
        nvml_dev
        nvrtc
        #opencl # OpenCL port should probably own this. 
        profiler_api
        #sanitizer_api
)

set(libs
        libcublas
        libcufft
        libcurand
        libcusolver
        libcusparse
        libnpp
        libnvjitlink
        libnvjpeg
)

set(util
        #nsight_compute
        #nsight_systems
)

set(tools
        cuobjdump
        cupti
        cuxxfilt # has some extra API
        nvcc
        nvdisasm
        nvprof
        #nvprune
        #nvvp
)

if(VCPKG_TARGET_IS_WINDOWS)
    #list(APPEND util
        #nsight_vse
    #)
endif()

if(VCPKG_TARGET_IS_LINUX)
    list(APPEND libs 
            libcudla
            fabricmanager
            libnvidia_nscq
            #nvidia_driver
            libcufile
    )
    list(APPEND util
            nvidia_fs
    )
    list(APPEND util 
            cuda_gdb
    )
endif()

if(target STREQUAL "sbsa")
    list(REMOVE_ITEM components "opencl")
    list(REMOVE_ITEM tools "nvprof" "nvvp")
elseif(target STREQUAL "ppc64le")
    list(REMOVE_ITEM components "opencl")
    list(REMOVE_ITEM libs "fabricmanager" "libnvidia_nscq" "libcufile")
    list(REMOVE_ITEM util "nvidia_fs")
endif()

list(TRANSFORM components PREPEND "cuda_")
list(TRANSFORM tools PREPEND "cuda_")

set(update_opt "")
set(cuda_updating 1)
if(cuda_updating)
    set(VCPKG_USE_HEAD_VERSION 1)
    set(update_opt SKIP_SHA512)

    message(STATUS "Running ${PORT} in update mode!")
else()
    include("${CURRENT_PORT_DIR}/hash-${platform}-${target}.cmake")
endif()

vcpkg_download_distfile(
    cuda_redist_json
    URLS ${base_url}/redistrib_${VERSION}.json
    FILENAME cuda-${VERSION}.json
    SHA512 ${cuda-json_HASH}
    ${update_opt}
)

if(cuda_updating)
    file(SHA512 "${cuda_redist_json}" hash)
    string(APPEND update_hash "set(cuda-json_HASH \"${hash}\")\n")
endif()

file(READ "${cuda_redist_json}" cuda_json)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/cuda")

set(licenses "")
foreach(comp IN LISTS components libs util tools)
    string(JSON comp_json GET "${cuda_json}" "${comp}")
    string(JSON lic_rel_url GET   "${comp_json}" "license_path")
    string(JSON comp_plat_json GET "${comp_json}" "${platform}-${target}")
    string(JSON comp_plat_rel_url GET "${comp_plat_json}" "relative_path")

    set(lic_url "${base_url}/${lic_rel_url}")
    set(comp_url "${base_url}/${comp_plat_rel_url}")

    # vcpkg_download_distfile(
        # lic_${comp}
        # URLS ${lic_url}
        # FILENAME ${lic_rel_url}
        # SHA512 ${lic_${comp}_HASH}
        # ${update_opt}
    # )
    # list(APPEND licenses "${lic_${comp}}")
    # if(cuda_updating)
        # file(SHA512 "${lic_${comp}}" hash)
        # string(APPEND update_hash "set(lic_${comp}_HASH \"${hash}\")\n")
    # endif()

    cmake_path(GET comp_plat_rel_url FILENAME comp_filename)

    vcpkg_download_distfile(
        ${comp}
        URLS ${comp_url}
        FILENAME ${comp_filename}
        SHA512 ${${comp}_HASH}
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
        SOURCE_BASE "${comp}"
        WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools"
    )

    # The following code copies the extracted archives verbatim to tools/cuda.
    # The layout should match what CUDA normally installs minus stuff irrelevant
    # for vcpkg (examples/docs etc.). The layout needs to match due to implicit
    # search dirs of nvcc expecting stuff to in a defined layout.

    if("${comp}" IN_LIST components OR "${comp}" IN_LIST libs)
        # Also copy lb/dll/so files into lib/bin
        file(COPY "${comp-src}/" DESTINATION "${CURRENT_PACKAGES_DIR}"
             PATTERN "/bin/*.dll"
             PATTERN "/lib/*.lib"
             PATTERN "/lib/*.a"
             PATTERN "/lib/*.so"
             PATTERN "*docs*" EXCLUDE
             PATTERN "*doc*" EXCLUDE
             PATTERN "*samples*" EXCLUDE
             PATTERN "*example*" EXCLUDE
             PATTERN "src/*" EXCLUDE
             PATTERN "LICENSE" EXCLUDE
             PATTERN "kernel" EXCLUDE
             PATTERN "kernel-open" EXCLUDE
             PATTERN "lib32" EXCLUDE
             PATTERN "man" EXCLUDE
             PATTERN "sbin" EXCLUDE
             PATTERN "systemd" EXCLUDE
             PATTERN "tests" EXCLUDE
             PATTERN "wine" EXCLUDE
             PATTERN "firmware" EXCLUDE
             PATTERN "include" EXCLUDE
             PATTERN "share" EXCLUDE
        )
        # Need a duplicate since nvcc won't magically add new unknown search paths for stuff
        file(COPY "${comp-src}/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/cuda"
            PATTERN "*docs*" EXCLUDE
            PATTERN "*doc*" EXCLUDE
            PATTERN "*samples*" EXCLUDE
            PATTERN "*example*" EXCLUDE
            PATTERN "LICENSE" EXCLUDE
            PATTERN "tests" EXCLUDE
            PATTERN "wine" EXCLUDE
        )
    else()
        file(COPY "${comp-src}/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/cuda"
            PATTERN "*docs*" EXCLUDE
            PATTERN "*doc*" EXCLUDE
            PATTERN "*samples*" EXCLUDE
            PATTERN "*exsample*" EXCLUDE
            PATTERN "LICENSE" EXCLUDE
        )
    endif()
    #file(REMOVE_RECURSE "${comp-src}")
endforeach()

if(cuda_updating)
    file(WRITE "${CURRENT_PORT_DIR}/new_hash-${platform}-${target}.cmake" "${update_hash}\n")
    message(FATAL_ERROR "New hashes obtained!")
endif()

file(COPY "${CURRENT_PACKAGES_DIR}/tools/cuda/lib/cmake/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/"
    PATTERN "/share/cub/" EXCLUDE
)
#vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/cub/cub-header-search.cmake" "lib/cmake/cub" "share/cub")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/thrust/thrust-header-search.cmake" "lib/cmake/thrust" "share/thrust")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/thrust/thrust-header-search.cmake" "from_install_prefix}" "from_install_prefix}/tools/cuda/")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/libcudacxx/libcudacxx-header-search.cmake" "../../../" "../../tools/cuda")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake/")

if(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/Win32")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/x64/" "${CURRENT_PACKAGES_DIR}/lib-tmp/")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib-tmp" "${CURRENT_PACKAGES_DIR}/lib")
elseif(VCPKG_TARGET_IS_LINUX)
  # Don't really know why this renaming is required.
  file(RENAME "${CURRENT_PACKAGES_DIR}/tools/cuda/lib" "${CURRENT_PACKAGES_DIR}/tools/cuda/lib64")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/tools/cuda/pkg-config")
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
  file(RENAME "${CURRENT_PACKAGES_DIR}/pkg-config" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/cuda/pkg-config")
  file(GLOB pc_files "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc")
  foreach(pc_file IN LISTS pc_files)
    file(READ "${pc_file}" contents)
    string(REGEX REPLACE "cudaroot=[^\n]+" "cudaroot=\${prefix}/tools/cuda" contents "${contents}")
    #string(REGEX REPLACE "/targets/x86_64-linux" "" contents "${contents}")
    file(WRITE "${pc_file}" "${contents}")
  endforeach()
endif()



if(NOT VCPKG_BUILD_TYPE)
    file(COPY "${CURRENT_PACKAGES_DIR}/bin/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(COPY "${CURRENT_PACKAGES_DIR}/lib/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/src"
    "${CURRENT_PACKAGES_DIR}/nvml"
    "${CURRENT_PACKAGES_DIR}/tools/cuda/nvml"
    "${CURRENT_PACKAGES_DIR}/share/cub"
)

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/include"
    "${CURRENT_PACKAGES_DIR}/tools/cuda/include/cub/cmake"
    "${CURRENT_PACKAGES_DIR}/tools/cuda/include/thrust/cmake"
    "${CURRENT_PACKAGES_DIR}/MANIFEST"
    "${CURRENT_PACKAGES_DIR}/third-party-notices.txt"
    "${CURRENT_PACKAGES_DIR}/README"
    "${CURRENT_PACKAGES_DIR}/LICENSE"
    "${CURRENT_PACKAGES_DIR}/CHANGELOG"
)

vcpkg_install_copyright(FILE_LIST ${licenses})

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/cudatoolkit/vcpkg-cmake-wrapper.cmake" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg_find_cuda.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg_find_cuda.cmake" @ONLY)

vcpkg_fixup_pkgconfig()

set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)
set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)
set(VCPKG_POLICY_ONLY_RELEASE_CRT enabled)

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) # includes are located in a subfolder of tools/cuda
