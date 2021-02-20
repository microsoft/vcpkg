#pragma once

#include <vcpkg/base/optional.h>

#include <memory>
#include <mutex>

namespace vcpkg
{
    // implements the equivalent of function static initialization for an object
    template<class T>
    struct DelayedInit
    {
        template<class F>
        const T& get(F&& f) const
        {
            std::call_once(underlying_->flag_, [&f, this]() { underlying_->storage_ = std::forward<F>(f)(); });
            return *underlying_->storage_.get();
        }

    private:
        struct Storage
        {
            std::once_flag flag_;
            Optional<T> storage_;
        };
        std::unique_ptr<Storage> underlying_ = std::make_unique<Storage>();
    };
}
