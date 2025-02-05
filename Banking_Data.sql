create database Banking_Data_Analysis;
Select * from accounts;
select * from branch;
select * from customers;
select * from employees;
select * from transactions;

# 1: Write a query to list all customers who haven't made any transactions in the last year. 

SELECT c.customer_id,CONCAT(c.first_name, ' ', c.last_name) AS full_name,c.email,c.phone,c.city,c.state
FROM Customers c
LEFT JOIN Accounts a ON c.customer_id = a.customer_id
LEFT JOIN Transactions t ON a.account_number = t.account_number
WHERE t.transaction_date < DATE_SUB(YEAR(transaction_date),INTERVAL 1 YEAR)OR t.transaction_date IS NULL;


# 2: Summarize the total transaction amount per account per month.

SELECT account_number, extract(month from transaction_date) AS transaction_month,
                         extract(year from transaction_date) AS transaction_year, 
                         SUM(amount) AS total_amount
FROM Transactions 
GROUP BY account_number, transaction_month, transaction_year
order by account_number,transaction_year,transaction_month;

# 3: Rank branches based on the total amount of deposits made in the last quarter.

SELECT b.branch_id, b.branch_name, SUM(t.amount) AS total_deposits, RANK() OVER (ORDER BY SUM(t.amount) DESC) AS branch_rank
FROM Branch b
JOIN Accounts a ON b.branch_id = a.branch_id
JOIN Transactions t ON a.account_number = t.account_number
WHERE t.transaction_type = 'Deposit' 
AND t.transaction_date >= DATE_sub(curdate(), interval quarter(curdate())-1 quarter)
GROUP BY b.branch_id, b.branch_name
order by total_deposits DESC;


# 4: Find the name of the customer who has deposited the highest amount.

SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS full_name, SUM(t.amount) AS total_deposit
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
JOIN Transactions t ON a.account_number = t.account_number
WHERE t.transaction_type = 'Deposit'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_deposit DESC limit 1;

# 5: Identify any accounts that have made more than two transactions in a single day, 
#     which could indicate fraudulent activity.

SELECT t.account_number, 
    CAST(t.transaction_date AS DATE) AS transaction_day, 
    COUNT(*) AS transaction_count
FROM Transactions t
GROUP BY t.account_number, CAST(t.transaction_date AS DATE)
HAVING COUNT(*) >2;

# 6: Calculate the average number of transactions per customer per account per month over the last year.
SELECT c.customer_id, t.account_number, 
	month(t.transaction_date) AS transaction_month, year(t.transaction_date) as transaction_year,
    COUNT(*) AS total_transactions,
    AVG(COUNT(*)) OVER (PARTITION BY c.customer_id, t.account_number) AS avg_transactions_per_month
FROM Customers c JOIN Accounts a ON c.customer_id = a.customer_id JOIN Transactions t ON a.account_number = t.account_number
WHERE t.transaction_date >= DATE_sub(curdate(), interval 1 year)
GROUP BY c.customer_id, t.account_number, transaction_month,transaction_year;

# 7: Write a query to find the daily transaction volume (total amount of all transactions) for the past month.

SELECT 
    CAST(transaction_date AS DATE) AS transaction_day, 
    SUM(amount) AS daily_volume
FROM Transactions
WHERE transaction_date >= DATE_sub(MONTH(transaction_date), interval 1 month)
GROUP BY transaction_day;


# 8: Calculate the total transaction amount performed by each age group in the past year. 
#     (Age groups: 0-17, 18-30, 31-60, 60+)

SELECT 
    CASE 
        WHEN YEAR(CURDATE()) - YEAR(c.date_of_birth) BETWEEN 0 AND 17 THEN '0-17'
        WHEN YEAR(CURDATE()) - YEAR(c.date_of_birth) BETWEEN 18 AND 30 THEN '18-30'
        WHEN YEAR(CURDATE()) - YEAR(c.date_of_birth) BETWEEN 31 AND 60 THEN '31-60'
        ELSE '60+'
    END AS age_group, SUM(t.amount) AS total_transaction_amount
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
JOIN Transactions t ON a.account_number = t.account_number
WHERE t.transaction_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY 
    CASE 
        WHEN YEAR(CURDATE()) - YEAR(c.date_of_birth) BETWEEN 0 AND 17 THEN '0-17'
        WHEN YEAR(CURDATE()) - YEAR(c.date_of_birth) BETWEEN 18 AND 30 THEN '18-30'
        WHEN YEAR(CURDATE()) - YEAR(c.date_of_birth) BETWEEN 31 AND 60 THEN '31-60'
        ELSE '60+'
    END;


# 9: Find the branch with the highest average account balance.

SELECT  
    b.branch_id, 
    b.branch_name, 
    AVG(a.balance) AS avg_balance
FROM Branch b
JOIN Accounts a ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY avg_balance DESC limit 1;



# 10: Calculate the average balance per customer at the end of each month in the last year.
SELECT 
    c.customer_id, 
    month(a.created_at) AS month, year(a.created_at) AS year,
    AVG(a.balance) AS avg_balance
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
WHERE a.created_at >= DATE_sub(curdate(), interval 1 year)
GROUP BY c.customer_id, month,year;






