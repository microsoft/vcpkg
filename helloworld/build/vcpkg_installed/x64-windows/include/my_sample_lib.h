#pragma once

#include <string>

#if MYLIB_EXPORTS
__declspec(dllexport)
#endif
void greet(const std::string& name);
