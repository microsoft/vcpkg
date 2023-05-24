#ifndef B64_CONFIG_H
#define B64_CONFIG_H

#ifdef _WIN32
  #ifdef LIBB64_EXPORTS
    #define LIBB64 __declspec(dllexport)
  #else
    #define LIBB64 __declspec(dllimport)
  #endif
#else
#define LIBB64
#endif

#endif
