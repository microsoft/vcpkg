x_vcpkg_find_fortran(OUT_OPTIONS Fortran_opts 
                     OUT_OPTIONS_RELEASE Fortran_opts_rel 
                     OUT_OPTIONS_DEBUG Fortran_opts_dbg)

if(Z_VCPKG_IS_INTERNAL_Fortran_INTEL)
    set(BASE_PATH "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/vcpkg-tool-ifort/Intel/Compiler/12.0/compiler/2022.0.3")
    set(IFORT_COMPILER_ROOT "${BASE_PATH}/windows")

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(subpath "ia32_win")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(subpath "intel64_win")
    endif()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(IFORT_BASEPATH_LIBS "${IFORT_COMPILER_ROOT}/compiler/lib/${subpath}/")
        file(COPY "${IFORT_BASEPATH_LIBS}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ifort/")
    endif()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(IFORT_BASEPATH_DLLS "${IFORT_COMPILER_ROOT}/redist/${subpath}/compiler/")
        set(IFORT_DLLS 
            cilkrts20.dll
            ifdlg100.dll
            libchkp.dll
            libicaf.dll
            libifportmd.dll
            libirngmd.dll
            svml_dispmd.dll
            libiomp5md.dll
            libiompstubs5md.dll
        )
        set(IFORT_DLLS_DEBUG
            libifcoremdd.dll
            libmmdd.dll
        )
        set(IFORT_DLLS_RELEASE
            libifcoremd.dll
            libmmd.dll
        )
        list(TRANSFORM IFORT_DLLS PREPEND "${IFORT_BASEPATH_DLLS}")
        list(TRANSFORM IFORT_DLLS_DEBUG PREPEND "${IFORT_BASEPATH_DLLS}")
        list(TRANSFORM IFORT_DLLS_RELEASE PREPEND "${IFORT_BASEPATH_DLLS}")

        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(COPY ${IFORT_DLLS} ${IFORT_DLLS_RELEASE} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(COPY ${IFORT_DLLS} ${IFORT_DLLS_DEBUG} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    file(INSTALL "${BASE_PATH}/licensing/fortran/third-party-programs.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
    set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled) # libs are at share/ifort and reflect how they are installed by the compiler instead of splitting them. 
    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
else()
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()