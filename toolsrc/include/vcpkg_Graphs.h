#pragma once

#include <unordered_map>

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

    template <class V, class U>
    __interface AdjacencyProvider
    {
        std::vector<V> adjacency_list(const U& vertex) const;

        U load_vertex_data(const V& vertex) const;
    };

    template <class V, class U>
    static void topological_sort_internal(const V& vertex,
                                          const AdjacencyProvider<V, U>& f,
                                          std::unordered_map<V, ExplorationStatus>& exploration_status,
                                          std::vector<U>& sorted)
    {
        ExplorationStatus& status = exploration_status[vertex];
        switch (status)
        {
            case ExplorationStatus::FULLY_EXPLORED:
                return;
            case ExplorationStatus::PARTIALLY_EXPLORED:
                Checks::exit_with_message(VCPKG_LINE_INFO, "cycle in graph");
            case ExplorationStatus::NOT_EXPLORED:
                {
                    status = ExplorationStatus::PARTIALLY_EXPLORED;
                    const U& vertex_data = f.load_vertex_data(vertex);
                    for (const V& neighbour : f.adjacency_list(vertex_data))
                        topological_sort_internal(neighbour, f, exploration_status, sorted);

                    sorted.push_back(std::move(vertex_data));
                    status = ExplorationStatus::FULLY_EXPLORED;
                    return;
                }
            default:
                Checks::unreachable(VCPKG_LINE_INFO);
        }
    }

    template <class V, class U>
    std::vector<U> topological_sort(const std::vector<V>& starting_vertices, const AdjacencyProvider<V, U>& f)
    {
        std::vector<U> sorted;
        std::unordered_map<V, ExplorationStatus> exploration_status;

        for (auto& vertex : starting_vertices)
        {
            topological_sort_internal(vertex, f, exploration_status, sorted);
        }

        return sorted;
    }
}
