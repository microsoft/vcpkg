if(VCPKG_TARGET_IS_LINUX)
    message("${PORT} currently requires the following tools and libraries from the system package manager:\n    autoreconf\n    libudev\n\nThese can be installed on Ubuntu systems via apt-get install autoconf")
endif()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://gitlab.freedesktop.org/libbsd/libbsd
    REF 04a24db27ad1572f766bad772cdd9c146e6d9cf0
    FETCH_REF "0.12.2"
    HEAD_REF master
)

vcpkg_list(SET MAKE_OPTIONS)
vcpkg_list(SET LIBBSD_LINK_LIBRARIES)
vcpkg_execute_required_process(
        COMMAND "./autogen"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "autoconf-${TARGET_TRIPLET}"
)
vcpkg_execute_required_process(
        COMMAND "./configure"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "configure-${TARGET_TRIPLET}"
)
vcpkg_execute_required_process(
        COMMAND "make"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "make-${TARGET_TRIPLET}"
)
#vcpkg_configure_make(
#        SOURCE_PATH "${SOURCE_PATH}"
#        AUTOCONFIG
#        OPTIONS
#            ${MAKE_OPTIONS}
#)
vcpkg_install_make()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
