#pragma once

#include <type_traits>
#include <utility>

namespace vcpkg
{
    template<class T, class D>
    struct UniqueResource
    {
        static_assert(std::is_trivially_copyable<T>::value,
                      "The `T` in a UniqueResource<T> must be trivially copyable.");

        template<class D_>
        UniqueResource(T t, T invalid_value, D_&& d)
            : resource_(t), invalid_value_(invalid_value), destructor_(std::forward<D_>(d))
        {
        }

        UniqueResource(const UniqueResource&) = delete;
        UniqueResource& operator=(const UniqueResource&) = delete;

        UniqueResource(UniqueResource&& ur)
            : resource_(std::exchange(ur.resource_, ur.invalid_value_))
            , invalid_value_(ur.invalid_value_)
            , destructor_(std::move(ur.destructor_))
        {
        }

        UniqueResource& operator=(UniqueResource&& ur)
        {
            if (resource_ != invalid_value_)
            {
                destructor_(std::exchange(resource_, invalid_value_));
            }
            // this ordering prevents against throwing move assignment operators
            // if `destructor_ = std::move(ur.destructor_)` throws, then
            // `resource_` is still invalid, so we don't call the old dtor on the new resource
            destructor_ = std::move(ur.destructor_);
            resource_ = std::exchange(ur.resource_, ur.invalid_value_);

            return *this;
        }

        void reset()
        {
            if (resource_ != invalid_value_)
            {
                destructor_(std::exchange(resource_, invalid_value_));
            }
        }

        ~UniqueResource() { reset(); }

        explicit operator bool() const { return resource_ != invalid_value_; }

        T* get()
        {
            if (resource_ == invalid_value_)
            {
                return nullptr;
            }
            return &resource_;
        }
        const T* get() const
        {
            if (resource_ == invalid_value_)
            {
                return nullptr;
            }
            return &resource_;
        }

    private:
        T resource_;
        T invalid_value_;
        D destructor_;
    };

    template<class T, class F>
    auto make_unique_resource(T t, T invalid_value, F&& f) -> UniqueResource<T, std::remove_reference_t<F>>
    {
        return {t, invalid_value, std::forward<F>(f)};
    }
}
