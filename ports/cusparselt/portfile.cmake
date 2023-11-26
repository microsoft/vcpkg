if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(target x86_64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" AND VCPKG_TARGET_IS_LINUX)
    set(target sbsa)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "ppc64" AND VCPKG_TARGET_IS_LINUX)
    set(target ppc64le)
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

set(ext ".tar.gz")
if(VCPKG_TARGET_IS_WINDOWS)
    set(platform windows)
    set(ext ".zip")
    
else()
    set(platform linux)
endif()

set(${PORT}-windows-x86_64_HASH 182de592b37fc38dfe51512165301779e3bd2a5fe0262b4784ac98a3a08fd0aee807a4f11f54701e2c951e8d4a7e8574582b6bf2755b9aca534b7a8a1359e40d)
set(${PORT}-linux-x86_64_HASH 0)

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
    file(COPY "${CURRENT_PACKAGES_DIR}/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(COPY "${CURRENT_PACKAGES_DIR}/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

