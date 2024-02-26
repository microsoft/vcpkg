cmake_minimum_required(VERSION 3.14)

project(gts VERSION "${VERSION}" LANGUAGES C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB2 glib-2.0 IMPORTED_TARGET)

if(WIN32)
    add_definitions(-DNATIVE_WIN32 -D_USE_MATH_DEFINES)
else()
    include(CheckIncludeFile)
    check_include_file("fpu_control.h" HAVE_FPU_CONTROL_H)
    if(HAVE_FPU_CONTROL_H)
        add_definitions(-DHAVE_FPU_CONTROL_H)
    endif()
endif()

add_definitions(
    -DGTS_COMPILATION
    -DGTS_MAJOR_VERSION=${PROJECT_VERSION_MAJOR}
    -DGTS_MINOR_VERSION=${PROJECT_VERSION_MINOR}
    -DGTS_MICRO_VERSION=${PROJECT_VERSION_PATCH}
    -DGTS_INTERFACE_AGE=1
    -DGTS_BINARY_AGE=1
    -DGTS_VERSION=${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}
)

file(GLOB src src/*.c src/gts.def)
list(FILTER src EXCLUDE REGEX ".*predicates_init\\.c$")
add_library(gts ${src})
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/config.h" "")
target_include_directories(gts PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(gts PUBLIC PkgConfig::GLIB2)

set(prefix ?)
set(exec_prefix \${prefix})
set(libdir \${prefix}/lib)
set(includedir \${prefix}/include)
configure_file(gts.pc.in gts.pc @ONLY)

install(FILES src/gts.h src/gtsconfig.h DESTINATION include)
install(TARGETS gts)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/gts.pc" DESTINATION lib/pkgconfig)
