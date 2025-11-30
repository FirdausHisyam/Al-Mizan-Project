import { onMount, createSignal, Show } from 'solid-js';
import cytoscape from 'cytoscape';

interface NodeData {
  id: string;
  label: string;
  type: 'verse' | 'abrogation';
  source?: string;
  target?: string;
}

export function Visualiser() {
  let containerRef: HTMLDivElement | undefined;
  const [selectedNode, setSelectedNode] = createSignal<NodeData | null>(null);

  onMount(() => {
    if (!containerRef) return;

    const cy = cytoscape({
      container: containerRef,
      elements: [
        // Mock Data for "Wow" Factor (will replace with API fetch later)
        { data: { id: 'v1', label: 'Al-Baqarah 2:106', type: 'verse' } },
        { data: { id: 'v2', label: 'Al-Anfal 8:65', type: 'verse' } },
        { data: { id: 'v3', label: 'Al-Anfal 8:66', type: 'verse' } },
        { data: { id: 'ab1', source: 'v1', target: 'v2', label: 'Abrogates', type: 'abrogation' } },
        { data: { id: 'ab2', source: 'v2', target: 'v3', label: 'Refined By', type: 'abrogation' } },
      ],
      style: [
        {
          selector: 'node',
          style: {
            'background-color': '#10b981', // Primary Emerald
            'label': 'data(label)',
            'color': '#e2e8f0',
            'font-family': 'Inter',
            'font-size': '12px',
            'text-valign': 'bottom',
            'text-margin-y': 8,
            'width': 40,
            'height': 40,
            'border-width': 2,
            'border-color': '#fff',
            'overlay-opacity': 0,
            'transition-property': 'background-color, border-color, width, height',
            'transition-duration': 300,
          }
        },
        {
          selector: 'node[type="verse"]',
          style: {
            'background-color': '#3b82f6', // Blue for Verses
            'shadow-blur': 15,
            'shadow-color': '#3b82f6',
            'shadow-opacity': 0.5,
          } as any
        },
        {
          selector: 'edge',
          style: {
            'width': 2,
            'line-color': '#64748b',
            'target-arrow-color': '#64748b',
            'target-arrow-shape': 'triangle',
            'curve-style': 'bezier',
            'arrow-scale': 1.5,
          } as any
        },
        {
          selector: ':selected',
          style: {
            'background-color': '#f59e0b', // Amber for selection
            'border-color': '#f59e0b',
            'border-width': 4,
            'width': 50,
            'height': 50,
            'shadow-blur': 25,
            'shadow-color': '#f59e0b',
            'shadow-opacity': 0.8,
            'line-color': '#f59e0b',
            'target-arrow-color': '#f59e0b',
            'source-arrow-color': '#f59e0b',
          } as any
        }
      ],
      layout: {
        name: 'grid', // Simple start, will upgrade to cose/force-directed
        rows: 2
      }
    });

    // Add interactivity
    cy.on('tap', 'node', (evt: cytoscape.EventObject) => {
      const node = evt.target;
      setSelectedNode(node.data());
    });

    cy.on('tap', (evt: cytoscape.EventObject) => {
      if (evt.target === cy) {
        setSelectedNode(null);
      }
    });

    // Initial Animation
    cy.nodes().forEach((node: cytoscape.NodeSingular, i: number) => {
      node.style('opacity', 0);
      setTimeout(() => {
        const anim = node.animation({
          style: { opacity: 1 },
          duration: 800
        } as any); // Cytoscape types are tricky here, keeping cast for safety but minimizing scope
        anim.play();
      }, i * 150);
    });
  });

  return (
    <div class="visualiser-wrapper">
      <div ref={containerRef} class="cy-container" />

      <Show when={selectedNode()}>
        <div class="details-panel glass-card">
          <h3>{selectedNode()?.label}</h3>
          <p><strong>Type:</strong> {selectedNode()?.type}</p>
          <p><strong>ID:</strong> {selectedNode()?.id}</p>
          <div class="actions">
            <button type="button" class="btn-primary">View Full Text</button>
          </div>
        </div>
      </Show>
    </div>
  );
}
