# Test 1: Basic Transformation
set(all_libs_list "libexample.dll;libutil.a;libutil2.lib;libutil3.so")
set(expected "-llibexample.dll;-llibutil;-llibutil2;-llibutil3")
set(x_vcpkg_transform_libs ON)
set(VCPKG_TARGET_IS_WINDOWS FALSE)
set(VCPKG_TARGET_IS_MINGW FALSE)
set(VCPKG_LIBRARY_LINKAGE "static")

z_vcpkg_make_prepare_link_flags(
    IN_OUT_VAR all_libs_list 
    X_VCPKG_TRANSFORM_LIBS ${x_vcpkg_transform_libs} 
    VCPKG_TARGET_IS_WINDOWS ${VCPKG_TARGET_IS_WINDOWS} 
    VCPKG_TARGET_IS_MINGW ${VCPKG_TARGET_IS_MINGW} 
    VCPKG_LIBRARY_LINKAGE ${VCPKG_LIBRARY_LINKAGE})

if(NOT all_libs_list STREQUAL "${expected}")
    message(FATAL_ERROR "Test 1: z_vcpkg_make_prepare_link_flags failed: expected ${expected} ${all_libs_list}")
endif()

# Test 2: Remove uuid on Windows
set(all_libs_list "libexample.dll;uuid.lib")
set(expected "-llibexample.dll")
set(x_vcpkg_transform_libs ON)
set(VCPKG_TARGET_IS_WINDOWS TRUE)
set(VCPKG_TARGET_IS_MINGW FALSE)
set(VCPKG_LIBRARY_LINKAGE "static")

z_vcpkg_make_prepare_link_flags(
    IN_OUT_VAR all_libs_list 
    X_VCPKG_TRANSFORM_LIBS ${x_vcpkg_transform_libs} 
    VCPKG_TARGET_IS_WINDOWS ${VCPKG_TARGET_IS_WINDOWS} 
    VCPKG_TARGET_IS_MINGW ${VCPKG_TARGET_IS_MINGW} 
    VCPKG_LIBRARY_LINKAGE ${VCPKG_LIBRARY_LINKAGE})

if(NOT all_libs_list STREQUAL "${expected}")
    message(FATAL_ERROR "Test 2: z_vcpkg_make_prepare_link_flags failed: expected ${expected} vs ${all_libs_list}")
endif()

# Test 3: MinGW Dynamic Linkage Handling
set(all_libs_list "libexample.so;uuid.a")
set(expected "-llibexample;-Wl,-Bstatic,-luuid,-Bdynamic")
set(x_vcpkg_transform_libs ON)
set(VCPKG_TARGET_IS_WINDOWS FALSE)
set(VCPKG_TARGET_IS_MINGW TRUE)
set(VCPKG_LIBRARY_LINKAGE "dynamic")

z_vcpkg_make_prepare_link_flags(
    IN_OUT_VAR all_libs_list 
    X_VCPKG_TRANSFORM_LIBS ${x_vcpkg_transform_libs} 
    VCPKG_TARGET_IS_WINDOWS ${VCPKG_TARGET_IS_WINDOWS} 
    VCPKG_TARGET_IS_MINGW ${VCPKG_TARGET_IS_MINGW} 
    VCPKG_LIBRARY_LINKAGE ${VCPKG_LIBRARY_LINKAGE})

if (NOT all_libs_list STREQUAL "${expected}")
    message(FATAL_ERROR "Test 3: z_vcpkg_make_prepare_link_flags failed: expected ${expected} vs ${all_libs_list}")
endif()

# Test 4: No Transformation Flag
set(all_libs_list "libexample.dll;uuid.lib")
set(expected "libexample.dll;uuid.lib")
set(x_vcpkg_transform_libs OFF)
set(VCPKG_TARGET_IS_WINDOWS FALSE)
set(VCPKG_TARGET_IS_MINGW FALSE)
set(VCPKG_LIBRARY_LINKAGE "static")

z_vcpkg_make_prepare_link_flags(
    IN_OUT_VAR all_libs_list 
    X_VCPKG_TRANSFORM_LIBS ${x_vcpkg_transform_libs} 
    VCPKG_TARGET_IS_WINDOWS ${VCPKG_TARGET_IS_WINDOWS} 
    VCPKG_TARGET_IS_MINGW ${VCPKG_TARGET_IS_MINGW} 
    VCPKG_LIBRARY_LINKAGE ${VCPKG_LIBRARY_LINKAGE})

if (NOT all_libs_list STREQUAL "${expected}")
    message(FATAL_ERROR "Test 4: z_vcpkg_make_prepare_link_flags failed: expected ${expected} vs ${all_libs_list}")
endif()

message(STATUS "z_vcpkg_make_prepare_link_flags tests passed.")

