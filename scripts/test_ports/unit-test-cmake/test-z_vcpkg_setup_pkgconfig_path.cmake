# z_vcpkg_setup_pkgconfig_path(BASE_DIR <list>)
# z_vcpkg_restore_pkgconfig_path()

# These functions use vcpkg_backup/restore_env_variables which use scoped variables
# and cannot be called in unit_test_check_*.

set(ENV{PKG_CONFIG} "/a/pkgconf")
set(ENV{PKG_CONFIG_PATH} "1")
set(saved_path "$ENV{PATH}")

block(SCOPE_FOR VARIABLES)

# mock packages and installed dir
set(CURRENT_PACKAGES_DIR "${CURRENT_BUILDTREES_DIR}/P")
set(CURRENT_INSTALLED_DIR "${CURRENT_BUILDTREES_DIR}/I")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}" "${CURRENT_INSTALLED_DIR}")
foreach(subdir IN ITEMS lib/pkgconfig debug/lib/pkgconfig share/pkgconfig)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/${subdir}")
    file(MAKE_DIRECTORY "${CURRENT_INSTALLED_DIR}/${subdir}")
endforeach()

z_vcpkg_setup_pkgconfig_path(CONFIG RELEASE)
unit_test_check_variable_equal([[]] ENV{PKG_CONFIG} [[/a/pkgconf]])
cmake_path(CONVERT "${CURRENT_PACKAGES_DIR}/lib/pkgconfig;${CURRENT_PACKAGES_DIR}/share/pkgconfig;${CURRENT_INSTALLED_DIR}/lib/pkgconfig;${CURRENT_INSTALLED_DIR}/share/pkgconfig;1" TO_NATIVE_PATH_LIST expected)
unit_test_check_variable_equal([[]] ENV{PKG_CONFIG_PATH} "${expected}")

z_vcpkg_restore_pkgconfig_path()
unit_test_check_variable_equal([[]] ENV{PKG_CONFIG} [[/a/pkgconf]])
unit_test_check_variable_equal([[]] ENV{PKG_CONFIG_PATH} "1")

z_vcpkg_setup_pkgconfig_path(CONFIG DEBUG)
unit_test_check_variable_equal([[]] ENV{PKG_CONFIG} [[/a/pkgconf]])
cmake_path(CONVERT "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig;${CURRENT_PACKAGES_DIR}/share/pkgconfig;${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig;${CURRENT_INSTALLED_DIR}/share/pkgconfig;1" TO_NATIVE_PATH_LIST expected)
unit_test_check_variable_equal([[]] ENV{PKG_CONFIG_PATH} "${expected}")

z_vcpkg_restore_pkgconfig_path()
unit_test_check_variable_equal([[]] ENV{PKG_CONFIG} [[/a/pkgconf]])
unit_test_check_variable_equal([[]] ENV{PKG_CONFIG_PATH} "1")

# Absent path <installed>/share/pkgconfig; empty PKG_CONFIG_PATH before.
file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/I/share/pkgconfig")
set(ENV{PKG_CONFIG_PATH} "")
z_vcpkg_setup_pkgconfig_path(CONFIG DEBUG)
cmake_path(CONVERT "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig;${CURRENT_PACKAGES_DIR}/share/pkgconfig;${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig" TO_NATIVE_PATH_LIST expected)
unit_test_check_variable_equal([[]] ENV{PKG_CONFIG_PATH} "${expected}")

# z_vcpkg_setup_pkgconfig_path changes PATH but it is not restored.
# It is hard to see which side effects a restore would have, so
# this is expected behaviour for now.
unit_test_check_variable_not_equal([[]] ENV{PATH} "${saved_path}")

unit_test_ensure_fatal_error([[ z_vcpkg_setup_pkgconfig_path() ]])
unit_test_ensure_fatal_error([[ z_vcpkg_setup_pkgconfig_path(CONFIG unknown) ]])

endblock()
