CREATE MATERIALIZED VIEW smart_sales AS
WITH total_sales AS (
    SELECT 
        EXTRACT(MONTH FROM date_sales) AS month_sales, 
        product_id, 
        shop_id, 
        SUM(sales_cnt) AS sales_fact
    FROM sales
    GROUP BY EXTRACT(MONTH FROM date_sales), product_id, shop_id
)
SELECT 
    EXTRACT(MONTH FROM plan.plan_date)  AS month_sales,
    shops.shop_name AS shop_name,
    pr.product_name AS product_name, 
    COALESCE(ms.sales_fact, 0) AS sales_fact, 
    plan.plan_cnt AS sales_plan,
    round(COALESCE(ms.sales_fact, 0) / plan.plan_cnt, 2) AS sales_fact_to_sales_plan,
    COALESCE(ms.sales_fact, 0) * pr.price as income_fact,
    plan.plan_cnt * pr.price as income_plan,
    (COALESCE(ms.sales_fact, 0.0) * pr.price) / (plan.plan_cnt * pr.price) as income_fact_to_income_plan
FROM plan 
JOIN products AS pr ON plan.product_id = pr.product_id
JOIN shops ON plan.shop_id = shops.shop_id
LEFT JOIN total_sales AS ms ON plan.product_id = ms.product_id AND
                              plan.shop_id = ms.shop_id AND 
                              EXTRACT(MONTH FROM plan.plan_date) = ms.month_sales
WITH DATA;