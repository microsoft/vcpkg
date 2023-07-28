 list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS 
                    "-DVCPKG_USE_SANITIZERS:BOOL=TRUE"
            )
if(PORT MATCHES "(openssl|boost|libpq)" OR port_contents MATCHES "(vcpkg_configure_meson|_msbuild|_nmake)")
    list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS 
                "-DVCPKG_USE_COMPILER_FOR_LINKAGE:BOOL=FALSE"
        )
else()
    message(STATUS "Found unsupported portfile. Deactivating linkage via compiler")
endif()