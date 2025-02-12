string(REGEX REPLACE "^([0-9]+[.][0-9]+).*\$" "\\1" GI_MAJOR_MINOR "${VERSION}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/gobject-introspection/${GI_MAJOR_MINOR}/gobject-introspection-${VERSION}.tar.xz"
    FILENAME "gobject-introspection-${VERSION}.tar.xz"
    SHA512 f45c2c1b105086488d974c6134db9910746df8edb187772f2ecd249656a1047c8ac88ba51f5bf7393c3d99c3ace143ecd09be256c2f4d0ceee110c9ad51a839a
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        0001-g-ir-tool-template.in.patch
        0002-cross-build.patch
        fix-pkgconfig.patch
)

vcpkg_find_acquire_program(PKGCONFIG)

set(additional_binaries "")
set(options "")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(STATUS "Static triplet. Not building introspection data.")
    list(APPEND options -Dbuild_introspection_data=false)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
elseif(VCPKG_CROSSCOMPILING)
    message(STATUS "Cross build. Building introspection data supported only if the host can execute target binaries.")
endif()

if("tools" IN_LIST FEATURES)
    vcpkg_get_vcpkg_installed_python(PYTHON3)
    vcpkg_find_acquire_program(FLEX)
    vcpkg_find_acquire_program(BISON)
    list(APPEND additional_binaries
        "flex='${FLEX}'"
        "bison='${BISON}'"
    )
elseif(VCPKG_CROSSCOMPILING)
    vcpkg_get_vcpkg_installed_python(PYTHON3 INTERPRETER)
    list(APPEND options -Dgi_cross_use_prebuilt_gi=true)
    list(APPEND additional_binaries
        "g-ir-compiler='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_HOST_EXECUTABLE_SUFFIX}'"
        "g-ir-scanner='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-scanner'"
    )
    file(COPY "${CURRENT_HOST_INSTALLED_DIR}/share/gobject-introspection-1.0/gdump.c" DESTINATION "${CURRENT_PACKAGES_DIR}/share/gobject-introspection-1.0")
    if(NOT VCPKG_BUILD_TYPE)
        file(COPY "${CURRENT_HOST_INSTALLED_DIR}/share/gobject-introspection-1.0/gdump.c" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share/gobject-introspection-1.0")
    endif()
endif()

if("cairo" IN_LIST FEATURES)
    list(APPEND options -Dcairo=enabled)
else()
    list(APPEND options -Dcairo=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Ddoctool=disabled
        -Dgtk_doc=false
        -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
        ${options}
    ADDITIONAL_BINARIES
        "python='${PYTHON3}'"
        ${additional_binaries}
)

set(ENV{PKG_CONFIG} "${PKGCONFIG}")
# VCPKG_GI_... variables are used by, and scoped to, giscanner
if(VCPKG_TARGET_IS_WINDOWS)
    set(ENV{VCPKG_GI_LIBDIR_VAR} "LIB")
elseif(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(ENV{VCPKG_GI_LIBDIR_VAR} "DYLD_LIBRARY_PATH")
else()
    set(ENV{VCPKG_GI_LIBDIR_VAR} "LD_LIBRARY_PATH")
endif()
set(subdir_debug "/debug")
set(subdir_release "")
set(short_debug "dbg")
set(short_release "rel")
foreach(buildtype IN ITEMS "debug" "release")
    if(DEFINED VCPKG_BUILD_TYPE AND NOT VCPKG_BUILD_TYPE STREQUAL buildtype)
        continue()
    endif()
    set(ENV{VCPKG_GI_LIBDIR} "${CURRENT_INSTALLED_DIR}${subdir_${buildtype}}/lib")
    set(ENV{VCPKG_GI_DATADIR} "${CURRENT_PACKAGES_DIR}${subdir_${buildtype}}/share")
    block(SCOPE_FOR VARIABLES)
        vcpkg_backup_env_variables(VARS PKG_CONFIG_PATH)
        vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "$ENV{VCPKG_GI_LIBDIR}/pkgconfig")
        file(MAKE_DIRECTORY "$ENV{VCPKG_GI_DATADIR}/gir-1.0")
        set(VCPKG_BUILD_TYPE "${buildtype}")
        vcpkg_install_meson(ADD_BIN_TO_PATH)
        vcpkg_restore_env_variables(VARS PKG_CONFIG_PATH)
    endblock()
    # Cf. https://gitlab.gnome.org/GNOME/gobject-introspection/-/issues/517
    if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_${buildtype}}/gir")
        foreach(lib IN ITEMS GLib-2.0 GObject-2.0 GModule-2.0 Gio-2.0)
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_${buildtype}}/gir/${lib}.gir" DESTINATION "${CURRENT_PACKAGES_DIR}${subdir_${buildtype}}/share/gir-1.0")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_${buildtype}}/gir/${lib}.typelib" DESTINATION "${CURRENT_PACKAGES_DIR}${subdir_${buildtype}}/lib/girepository-1.0")
        endforeach()
    endif()
endforeach()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
foreach(script IN ITEMS g-ir-annotation-tool g-ir-scanner)
    if(VCPKG_CROSSCOMPILING)
        # Host scripts, to run with host python.
        file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${script}")
        file(COPY "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/${script}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    else()
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${script}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}")
    endif()
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script}")
endforeach()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES g-ir-compiler g-ir-generate g-ir-inspect AUTO_CLEAN)
else()
    foreach(directory IN ITEMS "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(GLOB items "${directory}/*")
        if("${items}" STREQUAL "")
            file(REMOVE_RECURSE "${directory}")
        endif()
    endforeach()
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB _pyd_lib_files "${CURRENT_PACKAGES_DIR}/lib/gobject-introspection/giscanner/_giscanner.*.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/gobject-introspection/giscanner/_giscanner.*.lib")
    file(REMOVE ${_pyd_lib_files})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

file(COPY "${CURRENT_PORT_DIR}/vcpkg-port-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
