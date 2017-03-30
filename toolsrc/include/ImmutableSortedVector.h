#pragma once

#include <vector>
#include <algorithm>

// Add more forwarding functions to the delegate std::vector as needed.
namespace vcpkg
{
    template <class T>
    class ImmutableSortedVector
    {
        typedef typename std::vector<T>::size_type size_type;

    public:
        static ImmutableSortedVector<T> create(std::vector<T> vector)
        {
            ImmutableSortedVector out;
            out.delegate = std::move(vector);
            if (!std::is_sorted(out.delegate.cbegin(), out.delegate.cend()))
            {
                std::sort(out.delegate.begin(), out.delegate.end());
            }

            return out;
        }

        template <class Compare>
        static ImmutableSortedVector<T> create(std::vector<T> vector, Compare comp)
        {
            ImmutableSortedVector<T> out;
            out.delegate = std::move(vector);
            if (!std::is_sorted(out.delegate.cbegin(), out.delegate.cend(), comp))
            {
                std::sort(out.delegate.begin(), out.delegate.end(), comp);
            }

            return out;
        }

        typename std::vector<T>::const_iterator begin() const
        {
            return this->delegate.cbegin();
        }

        typename std::vector<T>::const_iterator end() const
        {
            return this->delegate.cend();
        }

        typename std::vector<T>::const_iterator cbegin() const
        {
            return this->delegate.cbegin();
        }

        typename std::vector<T>::const_iterator cend() const
        {
            return this->delegate.cend();
        }

        bool empty() const
        {
            return this->delegate.empty();
        }

        size_type size() const
        {
            return this->delegate.size();
        }

    private:
        std::vector<T> delegate;
    };
}
