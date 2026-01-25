import marimo

__generated_with = "0.19.6"
app = marimo.App(width="medium")


@app.cell
def _(fig, mo):
    mo.ui.plotly(fig)
    return


@app.cell
def _(ab_weight_slider):
    ab_weight_slider
    return


@app.cell(hide_code=True)
def _(ab_weight_slider, mo):
    mo.md(f"""
    A→B Edge Weight: {ab_weight_slider.value:.1f}
    """)
    return


@app.cell
def _(mo):
    ab_weight_slider = mo.ui.slider(start=0, stop=1.0, step=0.1, label="A→B Weight")
    return (ab_weight_slider,)


@app.cell
def _():
    import marimo as mo
    import networkx as nx
    import plotly.graph_objects as go
    return go, mo, nx


@app.cell
def _(ab_weight_slider, nx):
    # 1. Create a directed graph
    G = nx.DiGraph()
    G.add_weighted_edges_from([("A", "B", ab_weight_slider.value), ("B", "C", 0.5), ("C", "A", 0.75), ("D", "C", 0.5), ("B", "D", 1.0)])
    # Add class attributes to nodes
    G.nodes["A"]["class"] = "class1"
    G.nodes["B"]["class"] = "class1"
    G.nodes["C"]["class"] = "class2"
    G.nodes["D"]["class"] = "class2"
    return (G,)


@app.cell
def _(G, nx):
    # 2. Compute force-directed layout positions (spring layout)
    # Higher weights create stronger attraction between nodes
    # Use seed for reproducibility and more iterations for convergence
    pos = nx.spring_layout(G, weight='weight', k=0.5, iterations=200, seed=42)
    return (pos,)


@app.cell
def _(G, pos):
    # 3. Prepare data for Plotly
    edge_x = []
    edge_y = []
    edge_text = []
    edge_label_x = []
    edge_label_y = []
    edge_labels = []
    
    for edge in G.edges():
        x0, y0 = pos[edge[0]]
        x1, y1 = pos[edge[1]]
        edge_x.extend([x0, x1, None])
        edge_y.extend([y0, y1, None])
        weight = G[edge[0]][edge[1]].get('weight', 1.0)
        label = f"{edge[0]}→{edge[1]}: {weight:.2f}"
        edge_text.extend([label, label, None])
        
        # Add midpoint for edge labels
        edge_label_x.append((x0 + x1) / 2)
        edge_label_y.append((y0 + y1) / 2)
        edge_labels.append(f"{weight:.2f}")
    
    return edge_x, edge_y, edge_text, edge_label_x, edge_label_y, edge_labels


@app.cell
def _(G, edge_label_x, edge_label_y, edge_labels, edge_x, edge_y, edge_text, go, pos):
    edge_trace = go.Scatter(
        x=edge_x, y=edge_y,
        line=dict(width=1, color='#888'),
        hoverinfo='text',
        hovertext=edge_text,
        mode='lines')
    
    # Add edge labels as text
    edge_label_trace = go.Scatter(
        x=edge_label_x, y=edge_label_y,
        mode='text',
        text=edge_labels,
        textposition='middle center',
        textfont=dict(size=10, color='#888'),
        hoverinfo='skip',
        showlegend=False
    )

    node_x = [pos[node][0] for node in G.nodes()]
    node_y = [pos[node][1] for node in G.nodes()]
    node_classes = [G.nodes[node].get("class", "default") for node in G.nodes()]

    # Define colors for each class
    color_map = {"class1": "skyblue", "class2": "lightcoral", "default": "lightgray"}
    node_colors = [color_map.get(nc, "lightgray") for nc in node_classes]

    node_trace = go.Scatter(
        x=node_x, y=node_y,
        mode='markers+text',
        text=list(G.nodes()),
        textposition="top center",
        marker=dict(size=20, color=node_colors)
    )
    return edge_trace, edge_label_trace, node_trace


@app.cell
def _(edge_label_trace, edge_trace, go, node_trace):
    # 4. Create and display the plot
    fig = go.Figure(data=[edge_trace, edge_label_trace, node_trace],
                 layout=go.Layout(showlegend=False, hovermode='closest'))
    return (fig,)


if __name__ == "__main__":
    app.run()
