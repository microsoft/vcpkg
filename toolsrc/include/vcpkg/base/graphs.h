#pragma once

#include <unordered_map>
#include <unordered_set>
#include <utility>

#include <vcpkg/base/checks.h>
#include <vcpkg/base/span.h>
#include <vcpkg/base/system.print.h>

namespace vcpkg::Graphs
{
    enum class ExplorationStatus
    {
        // We have not visited this vertex
        NOT_EXPLORED,

        // We have visited this vertex but haven't visited all vertices in its subtree
        PARTIALLY_EXPLORED,

        // We have visited this vertex and all vertices in its subtree
        FULLY_EXPLORED
    };

    template<class V, class U>
    struct AdjacencyProvider
    {
        virtual std::vector<V> adjacency_list(const U& vertex) const = 0;
        virtual std::string to_string(const V& vertex) const = 0;
        virtual U load_vertex_data(const V& vertex) const = 0;
    };

    struct Randomizer
    {
        virtual int random(int max_exclusive) = 0;

        struct NotRandom;

    protected:
        ~Randomizer() {}
    };

    struct Randomizer::NotRandom : Randomizer
    {
        virtual int random(int) override { return 0; }
    };

    namespace details
    {
        template<class Container>
        void shuffle(Container& c, Randomizer* r)
        {
            if (!r) return;
            for (auto i = c.size(); i > 1; --i)
            {
                std::size_t j = r->random(static_cast<int>(i));
                if (j != i - 1)
                {
                    std::swap(c[i - 1], c[j]);
                }
            }
        }

        template<class V, class U>
        void topological_sort_internal(const V& vertex,
                                       const AdjacencyProvider<V, U>& f,
                                       std::unordered_map<V, ExplorationStatus>& exploration_status,
                                       std::vector<U>& sorted,
                                       Randomizer* randomizer)
        {
            ExplorationStatus& status = exploration_status[vertex];
            switch (status)
            {
                case ExplorationStatus::FULLY_EXPLORED: return;
                case ExplorationStatus::PARTIALLY_EXPLORED:
                {
                    System::print2("Cycle detected within graph at ", f.to_string(vertex), ":\n");
                    for (auto&& node : exploration_status)
                    {
                        if (node.second == ExplorationStatus::PARTIALLY_EXPLORED)
                        {
                            System::print2("    ", f.to_string(node.first), '\n');
                        }
                    }
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }
                case ExplorationStatus::NOT_EXPLORED:
                {
                    status = ExplorationStatus::PARTIALLY_EXPLORED;
                    U vertex_data = f.load_vertex_data(vertex);
                    auto neighbours = f.adjacency_list(vertex_data);
                    details::shuffle(neighbours, randomizer);
                    for (const V& neighbour : neighbours)
                        topological_sort_internal(neighbour, f, exploration_status, sorted, randomizer);

                    sorted.push_back(std::move(vertex_data));
                    status = ExplorationStatus::FULLY_EXPLORED;
                    return;
                }
                default: Checks::unreachable(VCPKG_LINE_INFO);
            }
        }
    }

    template<class VertexContainer, class V, class U>
    std::vector<U> topological_sort(VertexContainer starting_vertices,
                                    const AdjacencyProvider<V, U>& f,
                                    Randomizer* randomizer)
    {
        std::vector<U> sorted;
        std::unordered_map<V, ExplorationStatus> exploration_status;

        details::shuffle(starting_vertices, randomizer);

        for (auto&& vertex : starting_vertices)
        {
            details::topological_sort_internal(vertex, f, exploration_status, sorted, randomizer);
        }

        return sorted;
    }

    template<class V, class U>
    struct TopoWalk : AdjacencyProvider<V, U>
    {
        Graphs::Randomizer* randomizer = nullptr;
        struct iterator
        {
            const U& operator*() const { return m_parent->m_stack.back().first; }
            TopoWalk* m_parent;
        };

    private:
        bool advance_into(V vertex)
        {
            ExplorationStatus& status = m_exploration_status[vertex];
            switch (status)
            {
                case ExplorationStatus::FULLY_EXPLORED: return false;
                case ExplorationStatus::PARTIALLY_EXPLORED:
                {
                    System::print2("Cycle detected within graph at ", this->to_string(vertex), ":\n");
                    for (auto&& node : m_exploration_status)
                    {
                        if (node.second == ExplorationStatus::PARTIALLY_EXPLORED)
                        {
                            System::print2("    ", this->to_string(node.first), '\n');
                        }
                    }
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }
                case ExplorationStatus::NOT_EXPLORED:
                {
                    status = ExplorationStatus::PARTIALLY_EXPLORED;
                    U vertex_data = this->load_vertex_data(vertex);
                    auto neighbours = this->adjacency_list(vertex_data);
                    details::shuffle(neighbours, randomizer);
                    m_stack.emplace_back(std::move(vertex_data), std::move(neighbours));
                    while (!m_stack.back().second.empty())
                    {
                        auto n = m_stack.back().second.back();
                        m_stack.back().second.pop_back();
                        if (this->advance_into(n)) return true;
                    }
                    status = ExplorationStatus::FULLY_EXPLORED;
                    // Visit this vertex
                    return true;
                }
                default: Checks::unreachable(VCPKG_LINE_INFO);
            }
        }
        bool advance()
        {
            while (!m_stack.empty())
            {
                auto&& top = m_stack.back();
                while (!top.second.empty())
                {
                    auto v = top.second.back();
                    top.second.pop_back();
                    if (advance_into(v)) return true;
                }
            }

            while (!m_roots.empty())
            {
                auto v = m_roots.back();
                m_roots.pop_back();
                if (advance_into(v)) return true;
            }
        }

        std::unordered_map<V, ExplorationStatus> m_exploration_status;
        std::vector<std::pair<U, std::vector<V>>> m_stack;
        std::vector<V> m_roots;
    };

    template<class V>
    struct Graph final : AdjacencyProvider<V, V>
    {
    public:
        bool add_vertex(const V& v)
        {
            return m_edges.emplace(std::piecewise_construct, std::forward_as_tuple(v), std::forward_as_tuple()).second;
        }

        bool add_edge(const V& u, const V& v)
        {
            auto vertex = m_edges.emplace(std::piecewise_construct, std::forward_as_tuple(v), std::forward_as_tuple());
            auto edge = m_edges[u].emplace(v);

            return vertex.second || edge.second;
        }

        std::vector<V> vertex_list() const
        {
            std::vector<V> vertex_list;
            for (auto&& vertex : this->m_edges)
                vertex_list.emplace_back(vertex.first);
            return vertex_list;
        }

        std::vector<V> adjacency_list(const V& vertex) const override
        {
            const std::unordered_set<V>& as_set = this->m_edges.at(vertex);
            return std::vector<V>(as_set.cbegin(), as_set.cend()); // TODO: Avoid redundant copy
        }

        V load_vertex_data(const V& vertex) const override { return vertex; }

        // Note: this function indicates how tied this template is to the exact type it will be templated upon.
        // Possible fix: This type shouldn't implement to_string() and should instead be derived from?
        std::string to_string(const V& spec) const override { return spec->m_spec.to_string(); }

    private:
        std::unordered_map<V, std::unordered_set<V>> m_edges;
    };
}
