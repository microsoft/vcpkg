SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

 list(REMOVE_ITEM FEATURES platform-select)
 
list(LENGTH FEATURES NUMBER_ELEMS)
if(NUMBER_ELEMS GREATER 2)
    message(FATAL_ERROR "Cannot select more than one LAPACK implementation!")
    # Ports cannot depend on more than one LAPACK implementation. Always use Build-Depends: lapack-select[core]
endif()
if(NUMBER_ELEMS LESS 2)
    message(FATAL_ERROR "Need to select at least one LAPACK implementation! Only using feature [core] is not supported")
    # Ports should only depend on lapack-select[core] so that they don't implicitly depend on the selected default feature
endif()

# In the future this port might also be used to install a vcpkg-cmake-wrapper or 
# a FindLAPACK module to make sure all dependent ports use the same LAPACK implementation

IF("external" IN_LIST FEATURES)
    vcpkg_configure_cmake(SOURCE_PATH ${CURRENT_PORT_DIR})
endif()