#deprecated port. -> new port "vcpkg-tool-meson" for better grouping with other vcpkg tools 
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
vcpkg_find_acquire_program(MESON)
message(STATUS "Using meson: ${MESON}")