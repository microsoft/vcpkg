if(NOT TARGET lcms::lcms)
    include(CMakeFindDependencyMacro)
    find_dependency(lcms2 CONFIG)

    # Create imported target lcms::lcms
    add_library(lcms::lcms INTERFACE IMPORTED)

    set_target_properties(lcms::lcms PROPERTIES
        INTERFACE_LINK_LIBRARIES "lcms2::lcms2"
    )
endif()
