cmake_minimum_required(VERSION 3.9)

# Create the soil2 project
project("soil2" LANGUAGES C)

find_package(OpenGL)

# Do we want to install the headers?
option(INSTALL_HEADERS "Install header files" ON)

# Set the install dir
set(INSTALL_CMAKE_DIR share/soil2)

# Set the source files to compile
set(SOIL2_SRC
    "src/SOIL2/image_DXT.c"
    "src/SOIL2/image_DXT.h"
    "src/SOIL2/image_helper.c"
    "src/SOIL2/image_helper.h"
    "src/SOIL2/jo_jpeg.h"
    "src/SOIL2/pkm_helper.h"
    "src/SOIL2/pvr_helper.h"
    "src/SOIL2/SOIL2.c"
    "src/SOIL2/SOIL2.h"
    "src/SOIL2/stbi_DDS.h"
    "src/SOIL2/stbi_DDS_c.h"
    "src/SOIL2/stbi_ext.h"
    "src/SOIL2/stbi_ext_c.h"
    "src/SOIL2/stbi_pkm.h"
    "src/SOIL2/stbi_pkm_c.h"
    "src/SOIL2/stbi_pvr.h"
    "src/SOIL2/stbi_pvr_c.h"
    "src/SOIL2/stb_image.h"
    "src/SOIL2/stb_image_write.h"
    "src/SOIL2/wfETC.c"
    "src/SOIL2/wfETC.h"
)

# Add the library as a static linkage
add_library(soil2 STATIC ${SOIL2_SRC})

# The include dir
target_include_directories(soil2 INTERFACE $<INSTALL_INTERFACE:include>)

# link opengl32
target_link_libraries(soil2 PRIVATE ${OPENGL_gl_LIBRARY})

# If its msvc mute the secure warnings
if(MSVC)
    target_compile_definitions(soil2 PRIVATE _CRT_SECURE_NO_WARNINGS)
endif(MSVC)

if(INSTALL_HEADERS)
    # Install the library object
    install(TARGETS soil2 EXPORT soil2Targets
            ARCHIVE DESTINATION lib
            LIBRARY DESTINATION lib
    )

    # Install the headers
    install(FILES "src/SOIL2/SOIL2.h" DESTINATION include/SOIL2/)

    # Export the stuff
    export(TARGETS soil2 FILE "${PROJECT_BINARY_DIR}/soil2Targets.cmake")
    export(PACKAGE soil2)

    # Create the soil2Config.cmake and soil2ConfigVersion.cmake
    configure_file(soil2Config.cmake.in        "${PROJECT_BINARY_DIR}/soil2Config.cmake"        @ONLY)

    # Install the soil2Config.cmake and soil2ConfigVersion.cmake
    install(FILES
            "${PROJECT_BINARY_DIR}/soil2Config.cmake"
            DESTINATION "${INSTALL_CMAKE_DIR}"
    )

    # Install the export set for use with the install-tree
    install(EXPORT soil2Targets DESTINATION "${INSTALL_CMAKE_DIR}")
else(INSTALL_HEADERS)
    # Install the library object
    install(TARGETS soil2 EXPORT soil2
            ARCHIVE DESTINATION lib
            LIBRARY DESTINATION lib
    )
endif(INSTALL_HEADERS)
