cmake_minimum_required(VERSION 3.8)

project(mongoose C)

include(GNUInstallDirs)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

option(MONGOOSE_INSTALL_HEADERS "Install header files" ON)

add_library(mongoose STATIC mongoose.c)

if(MONGOOSE_INSTALL_HEADERS)
    install(
        FILES ${CMAKE_CURRENT_LIST_DIR}/mongoose.h
        DESTINATION include
    )
endif()

install(
    TARGETS mongoose
    EXPORT unofficial-mongoose-config
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(
    EXPORT unofficial-mongoose-config
    FILE unofficial-mongoose-config.cmake
    NAMESPACE unofficial::mongoose::
    DESTINATION share/cmake/unofficial-mongoose
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
