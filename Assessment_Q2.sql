SELECT 
  frequency_category AS frequency_category,
  COUNT(*) AS customer_count,
  FORMAT(AVG(monthly_txn), 1) AS avg_transactions_per_month
FROM (
    SELECT 
      u.id AS user_id,
      COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)), 0) AS monthly_txn,
      CASE
        WHEN COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)), 0) >= 10 THEN 'High Frequency'
        WHEN COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)), 0) BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
      END AS frequency_category
    FROM users_customuser u
    JOIN savings_savingsaccount s ON u.id = s.owner_id
    WHERE s.transaction_status = 'successful'
      AND s.transaction_date IS NOT NULL
    GROUP BY u.id
    HAVING monthly_txn IS NOT NULL
) AS categorized_users
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
