file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
set(pc_file_release "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/unit-test-cmake.pc")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
set(pc_file_debug "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/unit-test-cmake.pc")
set(reload_pc_strings 0)

function(write_pkgconfig)
    file(WRITE "${pc_file_release}" ${ARGN})
    file(WRITE "${pc_file_debug}" ${ARGN})
    file(STRINGS "${pc_file_release}" pc_strings_input)
    set(pc_strings_INPUT "${pc_strings_input}" PARENT_SCOPE)
    set(reload_pc_strings 1 PARENT_SCOPE)
endfunction()

function(unit_test_pkgconfig_check_key build_types field value)
    if(NOT build_types)
        message(SEND_ERROR "The build_type parameter must be list of debug;release.")
    endif()
    if(reload_pc_strings)
        file(STRINGS "${pc_file_release}" pc_strings_release)
        file(STRINGS "${pc_file_debug}" pc_strings_debug)
        set(pc_strings_release "${pc_strings_release}" PARENT_SCOPE)
        set(pc_strings_debug "${pc_strings_debug}" PARENT_SCOPE)
        set(reload_pc_strings 0 PARENT_SCOPE)
    endif()
    foreach(build_type IN LISTS build_types)
        set(listname "pc_strings_${build_type}")
        set(expected "${field}${value}")
        list(FILTER ${listname} INCLUDE REGEX "^${field}")
        if(NOT "${${listname}}" STREQUAL "${expected}" AND NOT "${${listname}}_is_empty" STREQUAL "${value}_is_empty")
            message(SEND_ERROR "vcpkg_fixup_pkgconfig() resulted in a wrong value for ${build_type} builds;
    input:    [[${pc_strings_INPUT}]]
    expected: [[${expected}]]
    actual  : [[${${listname}}]]")
            set_has_error()
            return()
        endif()
    endforeach()
endfunction()

# "Libs:" only
write_pkgconfig([[
Libs: -L${prefix}/lib -l"aaa"
]])
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
unit_test_pkgconfig_check_key("debug;release" "Libs:" [[ "-L${prefix}/lib" -laaa]])

# "Libs:" and "Libs.private:"
write_pkgconfig([[
Libs: -L"${prefix}/lib" -l"aaa"
Libs.private: -l"bbb ccc"
]])
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    unit_test_pkgconfig_check_key("debug;release" "Libs:" [[ "-L${prefix}/lib" -laaa "-lbbb ccc"]])
    unit_test_pkgconfig_check_key("debug;release" "Libs.private:" "")
else()
    unit_test_pkgconfig_check_key("debug;release" "Libs:" [[ "-L${prefix}/lib" -laaa]])
endif()

# line continuations
write_pkgconfig([[
Libs.private: \
      -lbbb
Libs: -L"${prefix}/lib" \
      -l"aaa"
]])
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    unit_test_pkgconfig_check_key("debug;release" "Libs:" [[ "-L${prefix}/lib" -laaa -lbbb]])
    unit_test_pkgconfig_check_key("debug;release" "Libs.private:" "")
else()
    unit_test_pkgconfig_check_key("debug;release" "Libs:" [[ "-L${prefix}/lib" -laaa]])
endif()

# Replace ';' with ' '
write_pkgconfig([[
Libs: -L${prefix}/lib\;-l"aaa"
Libs.private: -lbbb\;-l"ccc"
]])
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    unit_test_pkgconfig_check_key("debug;release" "Libs:" [[ "-L${prefix}/lib" -laaa -lbbb -lccc]])
    unit_test_pkgconfig_check_key("debug;release" "Libs.private:" "")
else()
    unit_test_pkgconfig_check_key("debug;release" "Libs:" [[ "-L${prefix}/lib" -laaa]])
endif()

# invalid: ...-NOTFOUND
write_pkgconfig([[Libs: LIB-NOTFOUND]])
# Only warning: unit_test_ensure_fatal_error([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) # ...-NOTFOUND # ]])

# invalid: optimized/debug
write_pkgconfig([[Libs: -laaa -loptimized -lrel -ldebug -ldbg -lbbb]])
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
unit_test_pkgconfig_check_key("debug" "Libs:" [[ -laaa -ldbg -lbbb]])
unit_test_pkgconfig_check_key("release" "Libs:" [[ -laaa -lrel -lbbb]])

write_pkgconfig([[Libs: -laaa -Loptimized -Lrel -Ldebug -Ldbg -lbbb]])
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
unit_test_pkgconfig_check_key("debug" "Libs:" [[ -laaa -Ldbg -lbbb]])
unit_test_pkgconfig_check_key("release" "Libs:" [[ -laaa -Lrel -lbbb]])

write_pkgconfig([[Libs: optimized\;librel.a\;debug\;libdbg.a\;aaa.lib]])
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
unit_test_pkgconfig_check_key("debug" "Libs:" [[ libdbg.a aaa.lib]])
unit_test_pkgconfig_check_key("release" "Libs:" [[ librel.a aaa.lib]])

write_pkgconfig([[Libs: aaa.lib\;optimized\;librel.a\;debug\;libdbg.a]])
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
unit_test_pkgconfig_check_key("debug" "Libs:" [[ aaa.lib libdbg.a]])
unit_test_pkgconfig_check_key("release" "Libs:" [[ aaa.lib librel.a]])

write_pkgconfig([[Libs: aaa.lib optimized librel.a debug libdbg.a bbb.lib]])
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
unit_test_pkgconfig_check_key("debug" "Libs:" [[ aaa.lib libdbg.a bbb.lib]])
unit_test_pkgconfig_check_key("release" "Libs:" [[ aaa.lib librel.a bbb.lib]])

# invalid: namespaced targets
write_pkgconfig([[Libs: -lAAA::aaa]])
# Only warning: unit_test_ensure_fatal_error([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) # namespaced target # ]])

# prefix
write_pkgconfig(
"prefix=${CURRENT_PACKAGES_DIR}
execprefix=\${prefix}
libdir=${CURRENT_PACKAGES_DIR}/lib
includedir=${CURRENT_PACKAGES_DIR}/include
datarootdir=${CURRENT_PACKAGES_DIR}/share
datadir=\${datarootdir}/${PORT}
")
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
unit_test_pkgconfig_check_key("release" "prefix=" [[${pcfiledir}/../..]])
unit_test_pkgconfig_check_key("release" "execprefix=" [[${prefix}]])
unit_test_pkgconfig_check_key("release" "libdir=" [[${prefix}/lib]])
unit_test_pkgconfig_check_key("release" "includedir=" [[${prefix}/include]])
unit_test_pkgconfig_check_key("release" "datarootdir=" [[${prefix}/share]])
unit_test_pkgconfig_check_key("release" "datadir=" [[${datarootdir}/unit-test-cmake]])

write_pkgconfig(
"prefix=${CURRENT_PACKAGES_DIR}/debug
execprefix=\${prefix}
libdir=${CURRENT_PACKAGES_DIR}/debug/lib
includedir=${CURRENT_PACKAGES_DIR}/include
datarootdir=${CURRENT_PACKAGES_DIR}/share
datadir=\${datarootdir}/${PORT}
")
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
unit_test_pkgconfig_check_key("debug" "prefix=" [[${pcfiledir}/../..]])
unit_test_pkgconfig_check_key("debug" "execprefix=" [[${prefix}]])
unit_test_pkgconfig_check_key("debug" "libdir=" [[${prefix}/lib]])
unit_test_pkgconfig_check_key("debug" "includedir=" [[${prefix}/../include]])
unit_test_pkgconfig_check_key("debug" "datarootdir=" [[${prefix}/../share]])
unit_test_pkgconfig_check_key("debug" "datadir=" [[${datarootdir}/unit-test-cmake]])

# -I, -l or -L with ${blah} in variables
write_pkgconfig([[blah_libs=-L${blah}/lib64 -l${blah}/libblah.a -I${blah}/include]])
unit_test_ensure_success([[ vcpkg_fixup_pkgconfig(SKIP_CHECK) ]])
unit_test_pkgconfig_check_key("debug;release" "blah_libs=" [["-L${blah}/lib64" "-l${blah}/libblah.a" "-I${blah}/include"]])
