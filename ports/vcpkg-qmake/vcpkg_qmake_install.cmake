#[===[.md:
# vcpkg_qmake_install

Build and install a qmake project.

## Usage:
```cmake
vcpkg_qmake_install(...)
```

## Parameters:
See [`vcpkg_qmake_build()`](vcpkg_qmake_build.md).

## Notes:
This command transparently forwards to [`vcpkg_qmake_build()`](vcpkg_qmake_build.md).
and appends the 'install' target

#]===]

function(vcpkg_qmake_fix_prl PACKAGE_DIR PRL_FILES)
        file(TO_CMAKE_PATH "${PACKAGE_DIR}/lib" CMAKE_LIB_PATH)
        file(TO_CMAKE_PATH "${PACKAGE_DIR}/include/qt5" CMAKE_INCLUDE_PATH)
        file(TO_CMAKE_PATH "${PACKAGE_DIR}/include" CMAKE_INCLUDE_PATH2)
        file(TO_CMAKE_PATH "${CURRENT_INSTALLED_DIR}" CMAKE_INSTALLED_PREFIX)
        foreach(PRL_FILE IN LISTS PRL_FILES)
            file(READ "${PRL_FILE}" _contents)
            string(REPLACE "${CMAKE_LIB_PATH}" "\$\$[QT_INSTALL_LIBS]" _contents "${_contents}")
            string(REPLACE "${CMAKE_INCLUDE_PATH}" "\$\$[QT_INSTALL_HEADERS]" _contents "${_contents}")
            string(REPLACE "${CMAKE_INCLUDE_PATH2}" "\$\$[QT_INSTALL_HEADERS]/../" _contents "${_contents}")
            string(REPLACE "${CMAKE_INSTALLED_PREFIX}" "\$\$[QT_INSTALL_PREFIX]" _contents "${_contents}")
            string(REGEX REPLACE "QMAKE_PRL_BUILD_DIR[^\\\n]+" "QMAKE_PRL_BUILD_DIR =" _contents "${_contents}")
            #Note: This only works without an extra if case since QT_INSTALL_PREFIX is the same for debug and release
            file(WRITE "${PRL_FILE}" "${_contents}")
        endforeach()
endfunction()

function(vcpkg_qmake_install)
    z_vcpkg_function_arguments(args)
    vcpkg_qmake_build(${args})
    vcpkg_qmake_build(SKIP_MAKEFILES BUILD_LOGNAME "install" TARGETS "install")
    # Move dlls into bin
    file(GLOB_RECURSE release_dlls "${CURRENT_PACKAGES_DIR}/lib/*.dll")
    foreach(dll IN LISTS release_dlls)
        string(REPLACE "${CURRENT_PACKAGES_DIR}/lib/" "" dll_rel_path "${dll}")
        get_filename_component(dir_to_dll "${dll_rel_path}" DIRECTORY)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin/${dir_to_dll}")
        file(RENAME "${dll}" "${CURRENT_PACKAGES_DIR}/bin/${dll_rel_path}")
        string(REPLACE ".dll" ".pdb" pdb_rel_path "${dll_rel_path}")
        if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/${pdb_rel_path}")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/${pdb_rel_path}" "${CURRENT_PACKAGES_DIR}/bin/${pdb_rel_path}")
        endif()
    endforeach()
    if(NOT VCPKG_BUILD_TYPE)
        file(GLOB_RECURSE debug_dlls "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
        foreach(dll IN LISTS debug_dlls)
            string(REPLACE "${CURRENT_PACKAGES_DIR}/debug/lib/" "" dll_rel_path "${dll}")
            get_filename_component(dir_to_dll "${dll_rel_path}" DIRECTORY)
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin/${dir_to_dll}")
            file(RENAME "${dll}" "${CURRENT_PACKAGES_DIR}/debug/bin/${dll_rel_path}")
            string(REPLACE ".dll" ".pdb" pdb_rel_path "${dll_rel_path}")
            if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/${pdb_rel_path}")
                file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/${pdb_rel_path}" "${CURRENT_PACKAGES_DIR}/debug/bin/${pdb_rel_path}")
            endif()
        endforeach()
    endif()
    # Fix absolute paths in prl files
    file(GLOB_RECURSE prl_files "${CURRENT_PACKAGES_DIR}/**.prl")
    debug_message(STATUS "prl_files:${prl_files}")
    vcpkg_qmake_fix_prl("${CURRENT_PACKAGES_DIR}" "${prl_files}")
endfunction()
