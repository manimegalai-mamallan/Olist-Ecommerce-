import os
import pandas as pd
import psycopg2
from psycopg2.extras import RealDictCursor
import streamlit as st
from datetime import date

# -----------------------------
# Streamlit page config
# -----------------------------
st.set_page_config(
    page_title="Olist Dashboard",
    layout="wide",
    initial_sidebar_state="expanded"
)

# -----------------------------
# Sidebar styling:
# Keep multipage navigation links, but hide only the small "app" header.
# -----------------------------
st.markdown(
    """
    <style>
      /* Hide the header area above the page links ("app"), but keep navigation links */
      [data-testid="stSidebarNav"] > div:first-child { display: none !important; }

      /* Optional: slightly tighter top padding */
      [data-testid="stSidebar"] > div:first-child { padding-top: 0.75rem; }
    </style>
    """,
    unsafe_allow_html=True
)

st.sidebar.header("Controls")

# -----------------------------
# DB connection + query helper
# -----------------------------
def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "postgres"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "ecommerce"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", "postgres"),
    )

def run_query(sql: str, params: dict | None = None) -> pd.DataFrame:
    conn = None
    try:
        conn = get_connection()
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(sql, params or {})
            rows = cur.fetchall()
        return pd.DataFrame(rows)
    finally:
        if conn:
            conn.close()

# ============================================================
# FIXED MODE (NO schema selector)
# Set ONE:
#   MODE = "OLTP"   -> normalized schema tables
#   MODE = "OLAP"   -> star schema tables
# ============================================================
MODE = "OLTP"  # change to "OLAP" if you want star schema only

# -----------------------------
# Sidebar filters (keep ONLY date + category)
# -----------------------------
def get_date_bounds():
    if MODE == "OLAP":
        sql = """
        SELECT MIN(full_date)::date AS min_date, MAX(full_date)::date AS max_date
        FROM dim_date;
        """
    else:
        sql = """
        SELECT MIN(order_purchase_timestamp)::date AS min_date,
               MAX(order_purchase_timestamp)::date AS max_date
        FROM orders;
        """
    df = run_query(sql)
    if df.empty or df.loc[0, "min_date"] is None:
        return date(2017, 1, 1), date.today()
    return df.loc[0, "min_date"], df.loc[0, "max_date"]

def get_categories() -> list[str]:
    if MODE == "OLAP":
        sql = """
        SELECT DISTINCT product_category_name_english AS category
        FROM dim_product
        WHERE product_category_name_english IS NOT NULL
        ORDER BY 1;
        """
    else:
        sql = """
        SELECT DISTINCT pc.product_category_name_english AS category
        FROM product_categories pc
        JOIN products p ON p.category_id = pc.category_id
        WHERE pc.product_category_name_english IS NOT NULL
        ORDER BY 1;
        """
    df = run_query(sql)
    cats = df["category"].dropna().tolist() if not df.empty else []
    return ["All"] + cats

min_d, max_d = get_date_bounds()
categories = get_categories()

date_range = st.sidebar.date_input(
    "Purchase Date Range",
    value=(min_d, max_d),
    min_value=min_d,
    max_value=max_d
)

# Normalize Streamlit date_input output
if isinstance(date_range, (tuple, list)) and len(date_range) == 2:
    start_date, end_date = date_range[0], date_range[1]
else:
    start_date, end_date = min_d, max_d

selected_category = st.sidebar.selectbox("Category (optional)", categories, index=0)

params = {"start_date": start_date, "end_date": end_date, "category": selected_category}

# -----------------------------
# Queries (fixed by MODE)
# -----------------------------
def kpis(params):
    if MODE == "OLAP":
        sql = """
        SELECT
          COALESCE(SUM(fs.price + fs.freight_value), 0) AS total_revenue,
          COUNT(DISTINCT fs.order_id) AS total_orders,
          COALESCE(AVG(fs.price + fs.freight_value), 0) AS avg_order_value,
          AVG(fs.review_score) AS avg_review_score
        FROM fact_sales fs
        JOIN dim_date d ON d.date_key = fs.order_date_key
        JOIN dim_product dp ON dp.product_key = fs.product_key
        WHERE d.full_date BETWEEN %(start_date)s AND %(end_date)s
          AND (%(category)s = 'All' OR dp.product_category_name_english = %(category)s);
        """
    else:
        sql = """
        WITH base AS (
          SELECT
            o.order_id,
            SUM(oi.price + oi.freight_value) AS order_gross,
            AVG(orv.review_score) AS avg_review
          FROM orders o
          JOIN order_items oi ON oi.order_id = o.order_id
          JOIN products p ON p.product_id = oi.product_id
          LEFT JOIN product_categories pc ON pc.category_id = p.category_id
          LEFT JOIN order_reviews orv ON orv.order_id = o.order_id
          WHERE o.order_purchase_timestamp::date BETWEEN %(start_date)s AND %(end_date)s
            AND (%(category)s = 'All' OR pc.product_category_name_english = %(category)s)
          GROUP BY o.order_id
        )
        SELECT
          COALESCE(SUM(order_gross), 0) AS total_revenue,
          COUNT(*) AS total_orders,
          COALESCE(AVG(order_gross), 0) AS avg_order_value,
          AVG(avg_review) AS avg_review_score
        FROM base;
        """
    return run_query(sql, params)

def revenue_by_month(params):
    if MODE == "OLAP":
        sql = """
        SELECT
          DATE_TRUNC('month', d.full_date)::date AS month,
          SUM(fs.price + fs.freight_value) AS revenue
        FROM fact_sales fs
        JOIN dim_date d ON d.date_key = fs.order_date_key
        JOIN dim_product dp ON dp.product_key = fs.product_key
        WHERE d.full_date BETWEEN %(start_date)s AND %(end_date)s
          AND (%(category)s = 'All' OR dp.product_category_name_english = %(category)s)
        GROUP BY 1
        ORDER BY 1;
        """
    else:
        sql = """
        SELECT
          DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
          SUM(oi.price + oi.freight_value) AS revenue
        FROM orders o
        JOIN order_items oi ON oi.order_id = o.order_id
        JOIN products p ON p.product_id = oi.product_id
        LEFT JOIN product_categories pc ON pc.category_id = p.category_id
        WHERE o.order_purchase_timestamp::date BETWEEN %(start_date)s AND %(end_date)s
          AND (%(category)s = 'All' OR pc.product_category_name_english = %(category)s)
        GROUP BY 1
        ORDER BY 1;
        """
    return run_query(sql, params)

def top_categories(params):
    if MODE == "OLAP":
        sql = """
        SELECT
          COALESCE(dp.product_category_name_english, 'Unknown') AS category,
          SUM(fs.price + fs.freight_value) AS revenue
        FROM fact_sales fs
        JOIN dim_date d ON d.date_key = fs.order_date_key
        JOIN dim_product dp ON dp.product_key = fs.product_key
        WHERE d.full_date BETWEEN %(start_date)s AND %(end_date)s
        GROUP BY 1
        ORDER BY revenue DESC
        LIMIT 10;
        """
    else:
        sql = """
        SELECT
          COALESCE(pc.product_category_name_english, 'Unknown') AS category,
          SUM(oi.price + oi.freight_value) AS revenue
        FROM orders o
        JOIN order_items oi ON oi.order_id = o.order_id
        JOIN products p ON p.product_id = oi.product_id
        LEFT JOIN product_categories pc ON pc.category_id = p.category_id
        WHERE o.order_purchase_timestamp::date BETWEEN %(start_date)s AND %(end_date)s
        GROUP BY 1
        ORDER BY revenue DESC
        LIMIT 10;
        """
    return run_query(sql, params)

def recent_orders_table(params):
    if MODE == "OLAP":
        sql = """
        SELECT
          fs.order_id,
          d.full_date AS purchase_date,
          ROUND(SUM(fs.price + fs.freight_value)::numeric, 2) AS order_total,
          ROUND(AVG(fs.review_score)::numeric, 2) AS avg_review
        FROM fact_sales fs
        JOIN dim_date d ON d.date_key = fs.order_date_key
        JOIN dim_product dp ON dp.product_key = fs.product_key
        WHERE d.full_date BETWEEN %(start_date)s AND %(end_date)s
          AND (%(category)s = 'All' OR dp.product_category_name_english = %(category)s)
        GROUP BY fs.order_id, d.full_date
        ORDER BY d.full_date DESC
        LIMIT 15;
        """
    else:
        sql = """
        SELECT
          o.order_id,
          o.order_status,
          o.order_purchase_timestamp::date AS purchase_date,
          ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS order_total
        FROM orders o
        JOIN order_items oi ON oi.order_id = o.order_id
        JOIN products p ON p.product_id = oi.product_id
        LEFT JOIN product_categories pc ON pc.category_id = p.category_id
        WHERE o.order_purchase_timestamp::date BETWEEN %(start_date)s AND %(end_date)s
          AND (%(category)s = 'All' OR pc.product_category_name_english = %(category)s)
        GROUP BY o.order_id, o.order_status, purchase_date
        ORDER BY purchase_date DESC
        LIMIT 15;
        """
    return run_query(sql, params)

# -----------------------------
# Main UI
# -----------------------------
st.title("Olist E-commerce Dashboard (Docker + Streamlit)")
st.caption("Use the sidebar for date range and category filters. Use the left navigation for other pages.")

kpi_df = kpis(params)
if kpi_df.empty:
    st.warning("No data returned for the selected filters.")
    st.stop()

total_revenue = float(kpi_df.loc[0, "total_revenue"] or 0)
total_orders = int(kpi_df.loc[0, "total_orders"] or 0)
aov = float(kpi_df.loc[0, "avg_order_value"] or 0)
avg_review = kpi_df.loc[0, "avg_review_score"]

c1, c2, c3, c4 = st.columns(4)
c1.metric("Total Revenue", f"{total_revenue:,.2f}")
c2.metric("Total Orders", f"{total_orders:,}")
c3.metric("Avg Order Value", f"{aov:,.2f}")
c4.metric("Avg Review Score", "—" if avg_review is None else f"{float(avg_review):.2f}")

st.divider()

left, right = st.columns([2, 1])

with left:
    st.subheader("Revenue Trend (Monthly)")
    trend = revenue_by_month(params)
    if trend.empty:
        st.info("No trend data for selected filters.")
    else:
        trend = trend.sort_values("month").set_index("month")
        st.line_chart(trend["revenue"])

with right:
    st.subheader("Top 10 Categories (Revenue)")
    top = top_categories(params)
    if top.empty:
        st.info("No category data for selected filters.")
    else:
        top = top.set_index("category")
        st.bar_chart(top["revenue"])

st.divider()

st.subheader("Recent Orders Snapshot")
tbl = recent_orders_table(params)
st.dataframe(tbl, use_container_width=True)
