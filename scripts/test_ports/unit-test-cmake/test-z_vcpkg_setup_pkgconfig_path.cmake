# z_vcpkg_setup_pkgconfig_path(BASE_DIR <list>)
# z_vcpkg_restore_pkgconfig_path()

# These functions use vcpkg_backup/restore_env_variables which use scoped variables
# and cannot be called in unit_test_check_*.

set(ENV{PKG_CONFIG} "/a/pkgconf")
set(ENV{PKG_CONFIG_PATH} "1")
set(saved_path "$ENV{PATH}")

z_vcpkg_setup_pkgconfig_path(BASE_DIRS "/2")
unit_test_check_variable_equal([[]] ENV{PKG_CONFIG} [[/a/pkgconf]])
unit_test_check_variable_not_equal([[]] ENV{PKG_CONFIG_PATH} "1")

z_vcpkg_restore_pkgconfig_path()
unit_test_check_variable_equal([[]] ENV{PKG_CONFIG} [[/a/pkgconf]])
unit_test_check_variable_equal([[]] ENV{PKG_CONFIG_PATH} "1")

# z_vcpkg_setup_pkgconfig_path changes PATH but it is not restored.
# It is hard to see which side effects a restore would have, so
# this is expected behaviour for now.
unit_test_check_variable_not_equal([[]] ENV{PATH} "${saved_path}")
