-- Estimate Customer Lifetime Value (CLV) for each user
-- Assumption: 
-- CLV = (total_transactions / account_tenure_in_months) * 12 * 0.001 (profit per transaction)
-- Output: customer_id, full name, tenure in months, total transaction count, estimated CLV

SELECT
    -- Unique customer ID
    u.id AS customer_id,

    -- Full name constructed from first and last names
    CONCAT(u.first_name, ' ', u.last_name) AS name,

    -- Account tenure in months from signup date to today
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,

    -- Total number of transactions by this customer
    COUNT(s.id) AS total_transactions,

    -- Estimated CLV based on provided simplified formula
    ROUND(
        (
            COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)  -- Avoid division by zero
        ) * 12 * 0.001,  -- 0.1% profit per transaction, annualized
        2  -- Round to 2 decimal places
    ) AS estimated_clv

FROM users_customuser u
-- Join savings accounts based on ownership
LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id

-- Group by user to aggregate their transactions
GROUP BY u.id, name, tenure_months

-- Order by estimated CLV from highest to lowest
ORDER BY estimated_clv DESC;
