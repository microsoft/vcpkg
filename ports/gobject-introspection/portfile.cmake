string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS
        "https://download.gnome.org/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "${PORT}-${VERSION}.tar.xz"
    SHA512 a9d2edbe1cea710e10ef1ea8059a45cf5689bace43b5d2a6861809e863a6de7114b4763db8df3916ad6202c9967f48f7997acd0810a86e5e88dea7e0be88b585
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        0001-g-ir-tool-template.in.patch
        gir-scanner-runtime.diff
)

include("${CURRENT_PORT_DIR}/vcpkg-port-config.cmake")
vcpkg_get_gobject_introspection_programs(PYTHON3)

set(additional_binaries "")
set(options "")
set(options_release "")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(STATUS "Static triplet. Not building introspection data.")
    list(APPEND options_release -Dbuild_introspection_data=false)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
list(APPEND additional_binaries
    "flex='${FLEX}'"
    "bison='${BISON}'"
)

if("cairo" IN_LIST FEATURES)
    list(APPEND options_release -Dcairo=enabled)
else()
    list(APPEND options_release -Dcairo=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Ddoctool=disabled
        -Dgtk_doc=false
        ${options}
    OPTIONS_DEBUG
        -Dbuild_introspection_data=false
        -Dcairo=disabled
    OPTIONS_RELEASE
        ${options_release}
    ADDITIONAL_BINARIES
        "python='${PYTHON3}'"
        ${additional_binaries}
)

set(ENV{PKG_CONFIG} "${PKGCONFIG}")
vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
# VCPKG_GI_... variables are used by, and scoped to, giscanner
set(ENV{VCPKG_GI_LIBDIR} "${CURRENT_INSTALLED_DIR}/lib")
set(ENV{VCPKG_GI_DATADIR} "${CURRENT_PACKAGES_DIR}/share")
file(MAKE_DIRECTORY "$ENV{VCPKG_GI_DATADIR}/gir-1.0")
if(VCPKG_TARGET_IS_WINDOWS)
    set(ENV{VCPKG_GI_LIBDIR_VAR} "LIB")
elseif(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(ENV{VCPKG_GI_LIBDIR_VAR} "DYLD_LIBRARY_PATH")
else()
    set(ENV{VCPKG_GI_LIBDIR_VAR} "LD_LIBRARY_PATH")
endif()
vcpkg_install_meson(ADD_BIN_TO_PATH)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Cf. https://gitlab.gnome.org/GNOME/gobject-introspection/-/issues/517
if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gir")
    foreach(lib IN ITEMS GLib-2.0 GObject-2.0 GModule-2.0 Gio-2.0)
        file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gir/${lib}.gir" DESTINATION "${CURRENT_PACKAGES_DIR}/share/gir-1.0")
        file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gir/${lib}.typelib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/girepository-1.0")
    endforeach()
endif()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
foreach(script IN ITEMS g-ir-annotation-tool g-ir-scanner)
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${script}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script}")
endforeach()
vcpkg_copy_tools(TOOL_NAMES g-ir-compiler g-ir-generate g-ir-inspect AUTO_CLEAN)

file(GLOB pcfiles "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc")
foreach(file IN LISTS pcfiles)
    vcpkg_replace_string("${file}" [[=${bindir}/g-ir-]] [[=${prefix}/tools/gobject-introspection/g-ir-]])
endforeach()
# No fixup for debug: Let it fail early as long as we lack debug builds for (windows) python.

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB _pyd_lib_files "${CURRENT_PACKAGES_DIR}/lib/gobject-introspection/giscanner/_giscanner.*.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/gobject-introspection/giscanner/_giscanner.*.lib")
    file(REMOVE ${_pyd_lib_files})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

file(COPY "${CURRENT_PORT_DIR}/vcpkg-port-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
