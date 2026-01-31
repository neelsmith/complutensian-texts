import marimo

__generated_with = "0.19.6"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Visualize graph
    """)
    return


@app.cell(hide_code=True)
def _(file_picker):
    file_picker
    return


@app.cell(hide_code=True)
def _(gk_lat_gr, mo):
    mo.md(f"""
    /// admonition | *Debugging*
    In Greek-Latin graph: **total nodes**: {gk_lat_gr.number_of_nodes()}, **total edges**: {gk_lat_gr.number_of_edges()}
    ///
    """)
    return


@app.cell
def _(threshold_slider):
    threshold_slider
    return


@app.cell(hide_code=True)
def _(mo, subgr_gk_lat, threshold_slider):
    mo.hstack([threshold_slider, mo.md(f"**Selected nodes**: {subgr_gk_lat.number_of_nodes()}, **Selected edges**: {subgr_gk_lat.number_of_edges()}")], justify="center")
    return


@app.cell(hide_code=True)
def _(fig):
    fig
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    # Computation
    """)
    return


@app.cell
def _(mo):
    threshold_slider = mo.ui.slider(start=0, stop=100, step=5, value=75, label="Weight percentile")
    return (threshold_slider,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Loading dataframe**
    """)
    return


@app.cell
def _(mo):
    file_picker = mo.ui.file(filetypes=[".csv", ".cex"], label="Choose delimited file")
    return (file_picker,)


@app.cell
def _(file_picker, io, pl):
    if file_picker.value:
        csv_content = file_picker.contents()
        df = pl.read_csv(io.BytesIO(csv_content), separator = "|",truncate_ragged_lines=True)
    else:
        df = None
    return (df,)


@app.cell
def _(co, df):
    if df is not None:
        gk_lat_clean = df.drop_nulls(subset=["greek_lemma", "latin_lemma"])
        gk_lat = co.score_pair_two_way(gk_lat_clean, "greek_lemma", "latin_lemma")
    else:
        gk_lat = None
    return (gk_lat,)


@app.cell
def _(df):
    df
    return


@app.cell
def _(mo):
    mo.md("""
    **Graph building**
    """)
    return


@app.cell
def _(nx):
    gk_lat_gr = nx.Graph()  # Undirected
    return (gk_lat_gr,)


@app.cell
def _(gk_lat, gk_lat_gr):
    if gk_lat is not None:
        gk_lat_gr.add_weighted_edges_from(gk_lat.select(["greek_lemma", "latin_lemma", "average_score"]).iter_rows())
    return


@app.cell
def _():
    return


@app.cell
def _(gk_lat_gr, mo):
    mo.md(f"In Greek-Latin graph: **total nodes**: {gk_lat_gr.number_of_nodes()}, **total edges**: {gk_lat_gr.number_of_edges()}")
    return


@app.cell
def _(threshold_slider):
    threshold_slider.value
    return


@app.cell
def _(get_significant_subgraph, gk_lat_gr, threshold_slider):
    subgr_gk_lat = get_significant_subgraph(gk_lat_gr, threshold_slider.value)
    return (subgr_gk_lat,)


@app.cell
def _(np, nx):
    def get_significant_subgraph(G, weight_percentile):
        # Calculate weight threshold
        weights = [d['weight'] for u, v, d in G.edges(data=True)]
        q = np.percentile(weights, weight_percentile)

        # Filter edges and the resulting induced nodes
        strong_edges = [(u, v, d) for u, v, d in G.edges(data=True) if d['weight'] >= q]

        H = nx.Graph()
        H.add_edges_from(strong_edges)

        # Optionally: Keep only the largest connected component to remove isolates
        if len(H) > 0:
            main_comp = max(nx.connected_components(H), key=len)
            H = H.subgraph(main_comp).copy()

        return H
    return (get_significant_subgraph,)


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Graph plotting**
    """)
    return


@app.cell
def _(nx, subgr_gk_lat):
    gk_lat_pos = nx.spring_layout(subgr_gk_lat)
    return (gk_lat_pos,)


@app.cell
def _():
    gl_edge_x, gl_edge_y = [], []
    return gl_edge_x, gl_edge_y


@app.cell
def _(gk_lat_pos, gl_edge_x, gl_edge_y, subgr_gk_lat):
    for u, v in subgr_gk_lat.edges():
        x0, y0 = gk_lat_pos[u]
        x1, y1 = gk_lat_pos[v]
        gl_edge_x.extend([x0, x1, None])
        gl_edge_y.extend([y0, y1, None])
    return


@app.cell
def _(gl_edge_x, gl_edge_y, go):
    gl_edge_trace = go.Scatter(x=gl_edge_x, y=gl_edge_y, line=dict(width=0.5, color='#888'), mode='lines')
    return (gl_edge_trace,)


@app.cell
def _(gk_lat_pos, go, subgr_gk_lat):
    gl_node_x = [gk_lat_pos[node][0] for node in subgr_gk_lat.nodes()]
    gl_node_y = [gk_lat_pos[node][1] for node in subgr_gk_lat.nodes()]
    gl_node_trace = go.Scatter(x=gl_node_x, y=gl_node_y, mode='markers', marker=dict(size=10, color='skyblue'))
    return (gl_node_trace,)


@app.cell
def _(gl_edge_trace, gl_node_trace, go):
    fig = go.Figure(data=[gl_edge_trace, gl_node_trace])
    return (fig,)


@app.cell
def _():
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md("""
    **Imports**
    """)
    return


@app.cell
def _():
    import marimo as mo
    import networkx as nx
    import polars as pl
    import io
    import complutensian as co
    import numpy as np
    import scipy as sp
    return co, io, mo, np, nx, pl


@app.cell
def _():
    import plotly.graph_objects as go
    return (go,)


if __name__ == "__main__":
    app.run()
