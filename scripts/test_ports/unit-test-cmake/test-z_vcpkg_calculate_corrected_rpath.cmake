# z_vcpkg_calculate_corrected_rpath(...)

block(SCOPE_FOR VARIABLES)

set(CURRENT_PACKAGES_DIR "/P")
set(CURRENT_INSTALLED_DIR "/I")

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "" ELF_FILE_DIR "/P/lib")
]] out [[$ORIGIN]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "" ELF_FILE_DIR "/P/plugins/group")
]] out [[$ORIGIN:$ORIGIN/../../lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "" ELF_FILE_DIR "/P/debug/lib")
]] out [[$ORIGIN]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "" ELF_FILE_DIR "/P/debug/plugins/group")
]] out [[$ORIGIN:$ORIGIN/../../lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "" ELF_FILE_DIR "/P/tools/port")
]] out [[$ORIGIN:$ORIGIN/../../lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "" ELF_FILE_DIR "/P/tools/port/bin")
]] out [[$ORIGIN:$ORIGIN/../../../lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "" ELF_FILE_DIR "/P/tools/port/debug")
]] out [[$ORIGIN:$ORIGIN/../../../debug/lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "" ELF_FILE_DIR "/P/tools/port/debug/bin")
]] out [[$ORIGIN:$ORIGIN/../../../../debug/lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "" ELF_FILE_DIR "/P/manual-tools/port")
]] out [[$ORIGIN:$ORIGIN/../../lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "" ELF_FILE_DIR "/P/manual-tools/port/bin")
]] out [[$ORIGIN:$ORIGIN/../../../lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "" ELF_FILE_DIR "/P/manual-tools/port/debug")
]] out [[$ORIGIN:$ORIGIN/../../../debug/lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "" ELF_FILE_DIR "/P/manual-tools/port/debug/bin")
]] out [[$ORIGIN:$ORIGIN/../../../../debug/lib]])

# ORG_RPATH
set(X_VCPKG_RPATH_KEEP_SYSTEM_PATHS 1)
set(CURRENT_PACKAGES_DIR "/cxx/P")
set(CURRENT_INSTALLED_DIR "/cxx/I")

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "/opt/lib:/usr/local/lib" ELF_FILE_DIR "/cxx/P/lib")
]] out [[$ORIGIN:/opt/lib:/usr/local/lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "/cxx/I/lib" ELF_FILE_DIR "/cxx/P/lib")
]] out [[$ORIGIN]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "/cxx/P/lib" ELF_FILE_DIR "/cxx/P/lib")
]] out [[$ORIGIN]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "/cxx/I/foo/lib/pkgconfig/../../bar" ELF_FILE_DIR "/cxx/P/lib")
]] out [[$ORIGIN:$ORIGIN/../foo/bar]])

set(X_VCPKG_RPATH_KEEP_SYSTEM_PATHS 0)
set(CURRENT_PACKAGES_DIR "/cxx/P")
set(CURRENT_INSTALLED_DIR "/cxx/I")

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "/opt/lib:/usr/local/lib" ELF_FILE_DIR "/cxx/P/lib")
]] out [[$ORIGIN]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "/cxx/I/foo/bar" ELF_FILE_DIR "/cxx/P/lib")
]] out [[$ORIGIN:$ORIGIN/../foo/bar]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "/cxx/P/foo/bar" ELF_FILE_DIR "/cxx/P/lib")
]] out [[$ORIGIN:$ORIGIN/../foo/bar]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "/cxx/I/foo/lib/pkgconfig/../../bar" ELF_FILE_DIR "/cxx/P/lib")
]] out [[$ORIGIN:$ORIGIN/../foo/bar]])

# https://github.com/microsoft/vcpkg/issues/37984
set(CURRENT_PACKAGES_DIR "/c++/P")
set(CURRENT_INSTALLED_DIR "/c++/I")

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "/c++/I/foo/bar" ELF_FILE_DIR "/c++/P/lib")
]] out [[$ORIGIN:$ORIGIN/../foo/bar]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "/c++/P/foo/bar" ELF_FILE_DIR "/c++/P/lib")
]] out [[$ORIGIN:$ORIGIN/../foo/bar]])

set(CURRENT_PACKAGES_DIR "/(c)/P")
set(CURRENT_INSTALLED_DIR "/(c)/I")

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "/(c)/I/foo/bar" ELF_FILE_DIR "/(c)/P/lib")
]] out [[$ORIGIN:$ORIGIN/../foo/bar]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_rpath(OUT_NEW_RPATH_VAR "out" ORG_RPATH "/(c)/P/foo/bar" ELF_FILE_DIR "/(c)/P/lib")
]] out [[$ORIGIN:$ORIGIN/../foo/bar]])


endblock()
