#include <iostream>

int main () {
    #ifdef PASS_THROUGH_MACRO2
        printf("VCPKG_CXX_FLAGS is defined");
    #else
        #error
        printf("VCPKG_CXX_FLAGS is not defined");
    #endif
    
    #if defined(PASS_THROUGH_MACRO5) || defined(PASS_THROUGH_MACRO7)
        printf("VCPKG_CXX_FLAGS_RELEASE or VCPKG_C_FLAGS_DEBUG is defined");
    #else
        #error
        printf("VCPKVCPKG_CXX_FLAGS_RELEASE or VCPKG_C_FLAGS_DEBUG is not defined");
    #endif
      /*
    #ifdef VCPKG_CXX_FLAGS_RELEASE
        printf("We are in release mode");
    #else
        printf("VCPKG_CXX_FLAGS_RELEASE is not defined");
    #endif
    #ifdef VCPKG_C_FLAGS_DEBUG
        printf("We are in debug mode");
    #else
        printf("VCPKG_C_FLAGS_DEBUG is not defined");
    #endif
    */

}