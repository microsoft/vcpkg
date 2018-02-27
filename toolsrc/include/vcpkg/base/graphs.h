#pragma once

#include <unordered_map>
#include <unordered_set>

#include <vcpkg/base/checks.h>
#include <vcpkg/base/span.h>
#include <vcpkg/base/system.h>

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

    namespace details
    {
        template<class V, class U>
        void topological_sort_internal(const V& vertex,
                                       const AdjacencyProvider<V, U>& f,
                                       std::unordered_map<V, ExplorationStatus>& exploration_status,
                                       std::vector<U>& sorted)
        {
            ExplorationStatus& status = exploration_status[vertex];
            switch (status)
            {
                case ExplorationStatus::FULLY_EXPLORED: return;
                case ExplorationStatus::PARTIALLY_EXPLORED:
                {
                    System::println("Cycle detected within graph:");
                    for (auto&& node : exploration_status)
                    {
                        if (node.second == ExplorationStatus::PARTIALLY_EXPLORED)
                        {
                            System::println("    %s", f.to_string(node.first));
                        }
                    }
                    Checks::exit_fail(VCPKG_LINE_INFO);
                }
                case ExplorationStatus::NOT_EXPLORED:
                {
                    status = ExplorationStatus::PARTIALLY_EXPLORED;
                    U vertex_data = f.load_vertex_data(vertex);
                    for (const V& neighbour : f.adjacency_list(vertex_data))
                        topological_sort_internal(neighbour, f, exploration_status, sorted);

                    sorted.push_back(std::move(vertex_data));
                    status = ExplorationStatus::FULLY_EXPLORED;
                    return;
                }
                default: Checks::unreachable(VCPKG_LINE_INFO);
            }
        }
    }

    template<class VertexRange, class V, class U>
    std::vector<U> topological_sort(const VertexRange& starting_vertices, const AdjacencyProvider<V, U>& f)
    {
        std::vector<U> sorted;
        std::unordered_map<V, ExplorationStatus> exploration_status;

        for (auto&& vertex : starting_vertices)
        {
            details::topological_sort_internal(vertex, f, exploration_status, sorted);
        }

        return sorted;
    }

    template<class V>
    struct Graph final : AdjacencyProvider<V, V>
    {
    public:
        void add_vertex(const V& v) { this->m_edges[v]; }

        void add_edge(const V& u, const V& v)
        {
            this->m_edges[v];
            this->m_edges[u].insert(v);
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
        std::string to_string(const V& spec) const override { return spec->spec.to_string(); }

    private:
        std::unordered_map<V, std::unordered_set<V>> m_edges;
    };
}
