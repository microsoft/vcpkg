set(FONTCONFIG_VERSION 2.13.1)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fontconfig/fontconfig
    REF 844d8709a1f3ecab45015b24b72dd775c13b2421 #v2.13.1
    SHA512 fed0cf46f5dca9cb1e03475d7a8d7efdab06c7180fe0c922fb30cadfa91e1efe1f6a6e36d2fdb742a479cb09c05b0aefb5da5658bf2e01a32b7ac88ee8ff0b58
    HEAD_REF master # branch name
    PATCHES remove_tests.patch
            build.patch
            build2.patch
)

vcpkg_find_acquire_program(GPERF)
get_filename_component(GPERF_PATH ${GPERF} DIRECTORY)
vcpkg_add_to_path(${GPERF_PATH})

if(VCPKG_TARGET_IS_WINDOWS)
    set(OPT_DBG "LIBS='-L${CURRENT_INSTALLED_DIR}/debug/lib -lintl'")
    set(OPT_REL "LIBS='-L${CURRENT_INSTALLED_DIR}/lib -lintl'")
endif()
vcpkg_configure_make(
    AUTOCONFIG
    COPY_SOURCE
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --disable-docs
        ${OPTIONS}
        ac_cv_type_pid_t=yes
        --enable-iconv
        #--enable-expat
        "--with-expat=${CURRENT_INSTALLED_DIR}"
        "--with-expat-includes=${CURRENT_INSTALLED_DIR}/include"
        "--with-libiconv=${CURRENT_INSTALLED_DIR}"
        "--with-libiconv-includes=${CURRENT_INSTALLED_DIR}/include"
    OPTIONS_DEBUG
        "--with-expat-lib=${CURRENT_INSTALLED_DIR}/debug/lib"
        "--with-libiconv-lib=${CURRENT_INSTALLED_DIR}/debug/lib"
        ${OPT_DBG}
    OPTIONS_RELEASE
        "--with-expat-lib=${CURRENT_INSTALLED_DIR}/lib"
        "--with-libiconv-lib=${CURRENT_INSTALLED_DIR}/lib"
        ${OPT_REL}
    ADD_BIN_TO_PATH
)
        # [AC_HELP_STRING([--enable-libxml2],
        # [Use libxml2 instead of Expat])])

vcpkg_install_make(ADD_BIN_TO_PATH)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES uuid)

# Fix paths in debug pc file.
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/fontconfig.pc")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE "/etc" "/../etc" _contents "${_contents}")
    string(REPLACE "/var" "/../var" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()

# Make path to cache in fonts.conf relative
set(_file "${CURRENT_PACKAGES_DIR}/etc/fonts/fonts.conf")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE "${CURRENT_INSTALLED_DIR}/var/cache/fontconfig" "./../../var/cache/fontconfig" _contents "${_contents}")
    string(REPLACE "/var" "/../var" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/var"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/etc")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    foreach(HEADER fcfreetype.h fontconfig.h)
        file(READ ${CURRENT_PACKAGES_DIR}/include/fontconfig/${HEADER} FC_HEADER)
        if(VCPKG_TARGET_IS_WINDOWS)
            string(REPLACE "#define FcPublic" "#define FcPublic __declspec(dllimport)" FC_HEADER "${FC_HEADER}")
        else()
            string(REPLACE "#define FcPublic" "#define FcPublic __attribute__((visibility(\"default\")))" FC_HEADER "${FC_HEADER}")
        endif()
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/fontconfig/${HEADER} "${FC_HEADER}")
    endforeach()
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)


## Build the fontconfig cache
if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(ENV{FONTCONFIG_PATH} "${CURRENT_PACKAGES_DIR}/etc/fonts")
    set(ENV{FONTCONFIG_FILE} "${CURRENT_PACKAGES_DIR}/etc/fonts/fonts.conf")
    vcpkg_execute_required_process(COMMAND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/fc-cache${VCPKG_TARGET_EXECUTABLE_SUFFIX}" --verbose
                                   WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin"
                                   LOGNAME fc-cache-${TARGET_TRIPLET})
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    # Unnecessary make rule creating the fontconfig cache dir on windows. 
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}LOCAL_APPDATA_FONTCONFIG_CACHE")
endif()