#pragma once

#include <algorithm>
#include <vector>

// Add more forwarding functions to the m_data std::vector as needed.
namespace vcpkg
{
    template<class T>
    class SortedVector
    {
    public:
        using size_type = typename std::vector<T>::size_type;
        using iterator = typename std::vector<T>::const_iterator;

        SortedVector() : m_data() { }

        explicit SortedVector(std::vector<T> v) : m_data(std::move(v))
        {
            if (!std::is_sorted(m_data.begin(), m_data.end()))
            {
                std::sort(m_data.begin(), m_data.end());
            }
        }

        template<class Compare>
        SortedVector(std::vector<T> v, Compare comp) : m_data(std::move(v))
        {
            if (!std::is_sorted(m_data.cbegin(), m_data.cend(), comp))
            {
                std::sort(m_data.begin(), m_data.end(), comp);
            }
        }

        iterator begin() const { return this->m_data.cbegin(); }

        iterator end() const { return this->m_data.cend(); }

        iterator cbegin() const { return this->m_data.cbegin(); }

        iterator cend() const { return this->m_data.cend(); }

        bool empty() const { return this->m_data.empty(); }

        size_type size() const { return this->m_data.size(); }

        const T& operator[](int i) const { return this->m_data[i]; }

    private:
        std::vector<T> m_data;
    };
}
