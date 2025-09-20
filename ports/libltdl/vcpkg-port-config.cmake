# Provide variables to use lib ltldl with autoconf.
#
# - <PREFIX>_LIBTOOLIZE
#   A libtoolize (wrapper) which disables the check for  libltdl.la.
#   la files are removed from packages in vcpkg (and in most distros).
#   They add little value in modern environments, and they use absolute paths.
# - <PREFIX>_OPTIONS_RELEASE,
#   <PREFIX>_OPTIONS_DEBUG:
#   Options to pass to vcpkg_make_configure.
#
# Usage:
#   vcpkg_libltdl_get_vars(LIBLTDL)
#   set(ENV{LIBTOOLIZE} "${LIBLTDL_LIBTOOLIZE}")
#   
#   vcpkg_make_configure(
#       SOURCE_PATH "${SOURCE_PATH}"
#       AUTORECONF
#       OPTIONS_RELEASE
#           ${LIBLTDL_OPTIONS_RELEASE}
#       OPTIONS_DEBUG
#           ${LIBLTDL_OPTIONS_RELEASE}
#   )

function(vcpkg_libltdl_get_vars prefix)
    # Select host libtoolize: triplet, environment, PATH, plain name.
    if(NOT VCPKG_LIBLTDL_LIBTOOLIZE)
        set(VCPKG_LIBLTDL_LIBTOOLIZE "$ENV{LIBTOOLIZE}")
    endif()
    if(VCPKG_LIBLTDL_LIBTOOLIZE STREQUAL "")
        find_program(VCPKG_LIBLTDL_LIBTOOLIZE NAMES libtoolize glibtoolize)
    endif()
    if(VCPKG_LIBLTDL_LIBTOOLIZE)
        set(ENV{VCPKG_LIBLTDL_LIBTOOLIZE} "${VCPKG_LIBLTDL_LIBTOOLIZE}")
    endif()

    vcpkg_list(SET options_release
        "--with-included-ltdl=no"
        "--with-ltdl-include=${CURRENT_INSTALLED_DIR}/include"
        "--with-ltdl-lib=${CURRENT_INSTALLED_DIR}/lib"
    )
    vcpkg_list(SET options_debug
        "--with-included-ltdl=no"
        "--with-ltdl-include=${CURRENT_INSTALLED_DIR}/include"
        "--with-ltdl-lib=${CURRENT_INSTALLED_DIR}/debug/lib"
    )
    set("${prefix}_OPTIONS_RELEASE" "${options_release}" PARENT_SCOPE)
    set("${prefix}_OPTIONS_DEBUG" "${options_debug}" PARENT_SCOPE)
    set("${prefix}_LIBTOOLIZE" "${CURRENT_INSTALLED_DIR}/manual-tools/libltdl/libtoolize-ltdl-no-la" PARENT_SCOPE)
endfunction()
