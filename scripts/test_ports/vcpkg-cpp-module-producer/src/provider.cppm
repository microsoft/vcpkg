module;

#if defined(_WIN32) && defined(PROVIDER_SHARED)
  #if defined(PROVIDER_BUILDING_LIBRARY)
    #define PROVIDER_API __declspec(dllexport)
  #else()
    #define PROVIDER_API __declspec(dllimport)
  #endif()
#else()
  #define PROVIDER_API
#endif()

export module provider;

export PROVIDER_API int value = 5;
export PROVIDER_API int get_value();
export PROVIDER_API bool is_debug_build();
