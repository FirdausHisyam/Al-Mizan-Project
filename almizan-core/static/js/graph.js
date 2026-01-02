// Graph Visualization Logic - Fetches real data from API

document.addEventListener('DOMContentLoaded', async () => {
    const container = document.getElementById('graph-container');
    const width = container.clientWidth || 800;
    const height = container.clientHeight || 600;

    // Create SVG
    const svg = d3.select("#graph-container")
        .append("svg")
        .attr("width", width)
        .attr("height", height);

    // Add loading indicator
    const loadingText = svg.append("text")
        .attr("x", width / 2)
        .attr("y", height / 2)
        .attr("text-anchor", "middle")
        .attr("fill", "#D4AF37")
        .attr("font-size", "18px")
        .text("Loading Knowledge Graph...");

    // Fetch real data from API
    let graphData;
    try {
        const response = await fetch('/api/v1/graph');
        graphData = await response.json();
        
        // Transform API response (nodes are wrapped in { data: {} })
        const nodes = graphData.nodes.map(n => ({
            id: n.data.id,
            label: n.data.label,
            type: n.data.type,
            tier: n.data.type === 'verse' ? 'thabit' : 'context'
        }));
        
        const edges = graphData.edges.map(e => ({
            source: e.data.source,
            target: e.data.target
        }));

        // Remove loading text
        loadingText.remove();
        
        renderGraph(nodes, edges);
    } catch (error) {
        loadingText.text("Error loading graph. Using sample data.");
        console.error('Graph API error:', error);
        
        // Fallback to sample data
        setTimeout(() => {
            loadingText.remove();
            renderGraph([
                { id: "verse:1_1", label: "Al-Fatiha 1:1", type: "verse", tier: "thabit" },
                { id: "root:b-s-m", label: "ب-س-م", type: "root", tier: "context" },
                { id: "root:r-h-m", label: "ر-ح-م", type: "root", tier: "context" }
            ], [
                { source: "verse:1_1", target: "root:b-s-m" },
                { source: "verse:1_1", target: "root:r-h-m" }
            ]);
        }, 1000);
    }

    function renderGraph(nodes, links) {
        // Create simulation
        const simulation = d3.forceSimulation(nodes)
            .force("link", d3.forceLink(links).id(d => d.id).distance(80))
            .force("charge", d3.forceManyBody().strength(-200))
            .force("center", d3.forceCenter(width / 2, height / 2))
            .force("collision", d3.forceCollide().radius(30));

        // Draw links
        const link = svg.append("g")
            .selectAll("line")
            .data(links)
            .enter().append("line")
            .attr("stroke", "#555")
            .attr("stroke-width", 1.5)
            .attr("stroke-opacity", 0.6);

        // Draw nodes
        const node = svg.append("g")
            .selectAll("g")
            .data(nodes)
            .enter().append("g")
            .attr("class", "node")
            .call(d3.drag()
                .on("start", dragstarted)
                .on("drag", dragged)
                .on("end", dragended));

        // Node circles with colors by type
        node.append("circle")
            .attr("r", d => d.tier === 'thabit' ? 12 : 8)
            .attr("fill", d => {
                if (d.type === 'verse') return '#D4AF37';  // Gold for Quran
                if (d.type === 'root') return '#00CED1';   // Cyan for Roots
                if (d.type === 'hadith') return '#C0C0C0'; // Silver
                if (d.type === 'ruling') return '#DC143C'; // Crimson
                return '#4682B4';  // Blue default
            })
            .attr("stroke", "#fff")
            .attr("stroke-width", 2);

        // Labels
        node.append("text")
            .text(d => d.label)
            .attr("x", 15)
            .attr("y", 4)
            .attr("fill", "#fff")
            .attr("font-size", "14px")
            .attr("font-weight", "500")
            .style("text-shadow", "0 0 4px rgba(0,0,0,0.8)");

        // Tick handler
        simulation.on("tick", () => {
            link
                .attr("x1", d => d.source.x)
                .attr("y1", d => d.source.y)
                .attr("x2", d => d.target.x)
                .attr("y2", d => d.target.y);

            node.attr("transform", d => `translate(${d.x},${d.y})`);
        });

        function dragstarted(event, d) {
            if (!event.active) simulation.alphaTarget(0.3).restart();
            d.fx = d.x;
            d.fy = d.y;
        }

        function dragged(event, d) {
            d.fx = event.x;
            d.fy = event.y;
        }

        function dragended(event, d) {
            if (!event.active) simulation.alphaTarget(0);
            d.fx = null;
            d.fy = null;
        }
    }
});
