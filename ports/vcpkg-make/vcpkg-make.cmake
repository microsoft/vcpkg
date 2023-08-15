# Be aware of https://github.com/microsoft/vcpkg/pull/31228

function(vcpkg_run_autoreconf)
# TODO:
# - Run autoreconf
# - Deal with tools like autopoint etc.
# does it make sense to parse configure.ac ?
endfunction()

function(vcpkg_run_bash)
# Prerun shell replacement
endfunction()

function(vcpkg_setup_win_msys)
# Get and put msys in the correct location in path
endfunction()

function(vcpkg_prepare_compile_flags)

endfunction()

function(vcpkg_prepare_compile_wrappers)
endfunction()


function(vcpkg_prepare_pkgconfig config)
# TODO
# Setup pkg-config paths
# Use cmake_language(DEFER to automatically call the restore command somehow ?
endfunction()

function(vcpkg_restore_pkgconfig)
# TODO
# restore variables
endfunction()

function(vcpkg_prepare_make_env config)
# TODO
# - Setup the environment variables for make giving <config>
endfunction()

function(vcpkg_restore_make_env)

endfunction()

function(vcpkg_make_configure) #
# Replacement for vcpkg_configure_make
# z_vcpkg_is_autoconf
# z_vcpkg_is_automake
endfunction()

function(vcpkg_make_install)
# Replacement for vcpkg_(install|build)_make
# Needs to know if vcpkg_make_configure is a autoconf project
endfunction()

# Make config dependent injections possible via cmake_language(CALL)
# z_vcpkg_make_prepare_<CONFIG>_commands
# z_vcpkg_make_restore_commands