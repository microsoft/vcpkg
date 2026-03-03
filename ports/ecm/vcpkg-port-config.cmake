# share/ECM/kde-modules/KDEClangFormat.cmake might write to the
# source dir, breaking parallel configuration for release/debug.
# This variables disables the undesired behaviour.
set(ENV{VCPKG_DISABLE_KDE_CLANG_FORMAT} 1)
