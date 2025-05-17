-- This query retrieves savings plans with their last successful inflow transaction,
-- calculates how many days have passed since that transaction,
-- and formats the output exactly like your expected result table.

SELECT
    s.plan_id,                             -- ID of the savings plan
    s.owner_id,                            -- ID of the user who owns the plan
    'Savings' AS type,                     -- Static value for type column as shown in output
    MAX(s.transaction_date) AS last_transaction_date,  -- Most recent successful inflow date
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days  -- Days since last transaction
FROM savings_savingsaccount s

-- Join with plans table to filter by valid plan attributes
LEFT JOIN plans_plan p ON s.plan_id = p.id

WHERE
    -- Include only successful transactions
    s.transaction_status = 'successful'

    -- Only include inflow transactions (e.g., deposits, interest)
    -- Replace 1 and 2 with actual inflow type IDs in your system
    AND s.transaction_type_id IN (1, 2)

    -- Ensure the transaction has a valid date
    AND s.transaction_date IS NOT NULL

    -- Plan must not be deleted
    AND (p.is_deleted = 0 OR p.is_deleted IS NULL)

    -- Plan must not be archived
    AND (p.is_archived = 0 OR p.is_archived IS NULL)

    -- Plan must be one of the supported types
    AND (
        p.is_a_wallet = 1 OR
        p.is_regular_savings = 1 OR
        p.is_fixed_investment = 1
    )

-- Group by plan and owner to get last transaction per user-plan combo
GROUP BY s.plan_id, s.owner_id

-- Optional: show users with longest inactivity first
ORDER BY inactivity_days DESC;
