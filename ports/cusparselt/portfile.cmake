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
  set(VCPKG_CRT_LINKAGE "static")
endif()

set(ext ".tar.xz")
if(VCPKG_TARGET_IS_WINDOWS)
    set(platform windows)
    set(ext ".zip")
    
else()
    set(platform linux)
endif()

set(${PORT}-windows-x86_64_HASH 182de592b37fc38dfe51512165301779e3bd2a5fe0262b4784ac98a3a08fd0aee807a4f11f54701e2c951e8d4a7e8574582b6bf2755b9aca534b7a8a1359e40d)
set(${PORT}-linux-x86_64_HASH 86cabe1e0ac33f9be93e263bfe0cc281688e711d5812cf64dc8c4b6f6fc167afa965121ede94d85383c88cce280b373d41299cd220a1f01421b976e04091105f)

vcpkg_download_distfile(
    ${PORT}
    URLS https://developer.download.nvidia.com/compute/cusparselt/redist/libcusparse_lt/${platform}-${target}/libcusparse_lt-${platform}-${target}-${VERSION}-archive${ext}
    FILENAME libcusparse_lt-${platform}-${target}-${VERSION}-archive${ext}
    SHA512 ${${PORT}-${platform}-${target}_HASH}
)

vcpkg_extract_source_archive(
    ${PORT}-src
    ARCHIVE ${${PORT}}
    SOURCE_BASE "${PORT}"
    #BASE_DIRECTORY "CUDA"
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}"
)

file(COPY "${${PORT}-src}/" DESTINATION "${CURRENT_PACKAGES_DIR}")
vcpkg_install_copyright(FILE_LIST "${${PORT}-src}/LICENSE")
file(REMOVE_RECURSE "${${PORT}-src}" "${CURRENT_PACKAGES_DIR}/LICENSE")

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB dll "${CURRENT_PACKAGES_DIR}/lib/*.dll")
    string(REPLACE "/lib/" "/bin/" new_dll "${dll}")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(RENAME "${dll}" "${new_dll}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE 
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/lib/cusparseLt.lib"
    )
else()
    file(GLOB static_libs "${CURRENT_PACKAGES_DIR}/lib/*_static*")
    file(REMOVE_RECURSE ${static_libs})
endif()

if(NOT VCPKG_BUILD_TYPE)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin")
      file(COPY "${CURRENT_PACKAGES_DIR}/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    file(COPY "${CURRENT_PACKAGES_DIR}/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

set(VCPKG_POLICY_SKIP_DUMPBIN_CHECKS enabled)
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)
set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)
set(VCPKG_POLICY_ONLY_RELEASE_CRT enabled)
