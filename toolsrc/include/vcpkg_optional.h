#pragma once
#include <memory>

template<class T>
using optional = std::unique_ptr<T>;
