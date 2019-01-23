find_path(
    TENSORFLOW_CC_INCLUDE_DIR_
    NAMES client_session.h
    PATH_SUFFIXES include/tensorflow/cc/client
)

if (TENSORFLOW_CC_INCLUDE_DIR_)
    set(TENSORFLOW_CC_INCLUDE_DIR ${TENSORFLOW_CC_INCLUDE_DIR_}/../../../)
endif()

if (NOT TENSORFLOW_CC_LIBRARY)
    set(libraries
        libtensorflow_framework.so libtensorflow_cc.so)
    find_library(
        TENSORFLOW_LIBRARY_FRAMEWORK
        NAMES
            libtensorflow_framework.so
        PATH_SUFFIXES lib)
    find_library(
        TENSORFLOW_LIBRARY_CC
        NAMES
            libtensorflow_cc.so
        PATH_SUFFIXES lib)
    if (NOT TENSORFLOW_LIBRARY_CC OR NOT TENSORFLOW_LIBRARY_FRAMEWORK)
        message(FATAL_ERROR "Can't find ${libraries}")
    endif()

    set(TENSORFLOW_CC_LIBRARY_RELEASE
        ${TENSORFLOW_LIBRARY_CC}
        ${TENSORFLOW_LIBRARY_FRAMEWORK})

    set(TENSORFLOW_CC_LIBRARY
            optimized "${TENSORFLOW_CC_LIBRARY_RELEASE}")
endif()


mark_as_advanced(TENSORFLOW_CC_INCLUDE_DIR)

include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(
    TENSORFLOW_CC
        REQUIRED_VARS
        TENSORFLOW_CC_LIBRARY TENSORFLOW_CC_INCLUDE_DIR
        VERSION_VAR)

if (TENSORFLOW_CC_FOUND)
    set(TENSORFLOW_CC_INCLUDE_DIRS
        ${TENSORFLOW_CC_INCLUDE_DIR}
        ${TENSORFLOW_CC_INCLUDE_DIR}/external/com_google_absl
    )

    if (NOT TARGET tensorflow_cc::tensorflow_framework)
        add_library(tensorflow_cc::tensorflow_framework UNKNOWN IMPORTED)
        set_target_properties(tensorflow_cc::tensorflow_framework
            PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${TENSORFLOW_CC_INCLUDE_DIRS}")

        set_target_properties(tensorflow_cc::tensorflow_framework PROPERTIES
            IMPORTED_LOCATION_RELEASE ${TENSORFLOW_LIBRARY_FRAMEWORK})
        set_property(TARGET tensorflow_cc::tensorflow_framework APPEND PROPERTY
            IMPORTED_CONFIGURATIONS RELEASE)
    endif()

    if (NOT TARGET tensorflow_cc::tensorflow_cc)
        add_library(tensorflow_cc::tensorflow_cc UNKNOWN IMPORTED)
        set_target_properties(tensorflow_cc::tensorflow_cc
            PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${TENSORFLOW_CC_INCLUDE_DIRS}")

        set_target_properties(tensorflow_cc::tensorflow_cc PROPERTIES
            IMPORTED_LOCATION_RELEASE ${TENSORFLOW_LIBRARY_CC})
        set_property(TARGET tensorflow_cc::tensorflow_cc APPEND PROPERTY
            IMPORTED_CONFIGURATIONS RELEASE)
        set_property(TARGET tensorflow_cc::tensorflow_cc APPEND PROPERTY
            INTERFACE_LINK_LIBRARIES tensorflow_cc::tensorflow_framework)
    endif()
endif()
