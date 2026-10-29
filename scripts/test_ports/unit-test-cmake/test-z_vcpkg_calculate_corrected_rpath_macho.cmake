# z_vcpkg_calculate_corrected_macho_rpath_macho(...)

block(SCOPE_FOR VARIABLES)

set(CURRENT_PACKAGES_DIR "/P")
set(CURRENT_INSTALLED_DIR "/I")

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_macho_rpath(OUT_NEW_RPATH_VAR "out" MACHO_FILE_DIR "/P/lib")
]] out [[@loader_path]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_macho_rpath(OUT_NEW_RPATH_VAR "out" MACHO_FILE_DIR "/P/plugins/group")
]] out [[@loader_path/../../lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_macho_rpath(OUT_NEW_RPATH_VAR "out" MACHO_FILE_DIR "/P/debug/lib")
]] out [[@loader_path]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_macho_rpath(OUT_NEW_RPATH_VAR "out" MACHO_FILE_DIR "/P/debug/plugins/group")
]] out [[@loader_path/../../lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_macho_rpath(OUT_NEW_RPATH_VAR "out" MACHO_FILE_DIR "/P/tools/port")
]] out [[@loader_path/../../lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_macho_rpath(OUT_NEW_RPATH_VAR "out" MACHO_FILE_DIR "/P/tools/port/bin")
]] out [[@loader_path/../../../lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_macho_rpath(OUT_NEW_RPATH_VAR "out" MACHO_FILE_DIR "/P/tools/port/debug")
]] out [[@loader_path/../../../debug/lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_macho_rpath(OUT_NEW_RPATH_VAR "out" MACHO_FILE_DIR "/P/tools/port/debug/bin")
]] out [[@loader_path/../../../../debug/lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_macho_rpath(OUT_NEW_RPATH_VAR "out" MACHO_FILE_DIR "/P/manual-tools/port")
]] out [[@loader_path/../../lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_macho_rpath(OUT_NEW_RPATH_VAR "out" MACHO_FILE_DIR "/P/manual-tools/port/bin")
]] out [[@loader_path/../../../lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_macho_rpath(OUT_NEW_RPATH_VAR "out" MACHO_FILE_DIR "/P/manual-tools/port/debug")
]] out [[@loader_path/../../../debug/lib]])

unit_test_check_variable_equal([[
    z_vcpkg_calculate_corrected_macho_rpath(OUT_NEW_RPATH_VAR "out" MACHO_FILE_DIR "/P/manual-tools/port/debug/bin")
]] out [[@loader_path/../../../../debug/lib]])

endblock()
