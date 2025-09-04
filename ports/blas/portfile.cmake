SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# Due to the interaction between BLAS and LAPACK, we need to choose implementations consistent with
# each other.
#
# First, if we are on Apple, we use the Accelerate framework.
#
# Then, we prefer to use openblas and lapack-reference for blas and lapack, respectively, but
# sometimes are unable.
#
# If we are on Windows and arm or uwp, that we use gfortran as our fortran compiler creates an issue
# because there is no available libgfortran. This means we can't use lapack-reference at all.
#
# If we are on Windows and static, there is a linking problem caused by static gfortran in the same
# link as openblas, so we have to use the blas implementation from lapack-reference.
#
# That results in roughly the following decision tree:
#
# no_libgfortran = (uwp || (windows && arm))
# can_link_mixed_static_libgfortran = !windows || !static
#
# if (no_libgfortran) {
#    return {
#        "blas": "openblas",
#        "lapack": "clapack"
#     };
# } else if (can_link_mixed_static_libgfortran) {
#     return {
#         "blas": "openblas",
#         "lapack": "lapack-reference[noblas]"
#     };
# } else {
#     return {
#         "blas": "lapack-reference[blas]",
#         "lapack": "lapack-reference[blas]"
#     };
# }
#
# Scoping this to just the 'can use openblas' question, we get:
# uwp || (windows && arm) || !windows || !static
# and for lapack-reference[blas], the DeMorgan'd inverse of that:
# !uwp && !(windows && arm) && windows && static

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    # Use Apple's accelerate framework where available
    set(BLA_VENDOR Apple)
    set(requires "")
    set(libs "-framework Accelerate")
    set(cflags "-framework Accelerate")
else()
    set(BLA_VENDOR OpenBLAS)
    set(requires openblas)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/blas.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/blas.pc" @ONLY)
if(NOT VCPKG_BUILD_TYPE)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/blas.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/blas.pc" @ONLY)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BLA_STATIC ON)
else()
    set(BLA_STATIC OFF)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/blas/vcpkg-cmake-wrapper.cmake" @ONLY)
