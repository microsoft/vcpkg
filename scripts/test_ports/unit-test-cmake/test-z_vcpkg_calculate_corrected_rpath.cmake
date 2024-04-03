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

endblock()
