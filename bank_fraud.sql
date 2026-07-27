CREATE DATABASE bank_fraud_detection_system;

USE bank_fraud_detection_system;

CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50),
    mobile_no char(10),
    email varchar(100)
);
	CREATE TABLE Accounts(
    account_id INT PRIMARY KEY,
    bank_name varchar(100),
	customer_id INT,
    balance DECIMAL(10,2),
    foreign key(customer_id) references customers(customer_id));
    
CREATE TABLE Transactions(
    txn_id INT PRIMARY KEY,
	account_id INT,
	amount DECIMAL(10,2),
    txn_type VARCHAR(10),
    location VARCHAR(50),
    txn_time DATETIME,
	foreign key(account_id) references Accounts(account_id)
);
CREATE TABLE Fraud_Alerts(
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    txn_id INT,
    reason VARCHAR(100),
    alert_time DATETIME,
    foreign key(txn_id) references transactions (txn_id)
);
INSERT INTO customers VALUES
(1,'raman','Chennai','9164590100','raman24@gmail.com'),
(2,'vijay','Madurai','6645768720','vijayakumar@gmail.com'),
(3,'bala','Coimbatore','9118878010','bala97@gmail.com'),
(4,'ashwath','Salem','9343637383','ashwath@gmail.com'),
(5,'dhanush','Trichy','7123456789','dhanush@gmail.com'),
(6,'nagaraj','Chennai','0808987868','nagaraj@gmail.com'),
(7,'vishnu','Madurai','2134094356','vishnu@gmail.com'),
(8,'deva','Coimbatore','8888786858','deva@gmail.com'),
(9,'karthik','Erode','7123456709','karthick@gmail.com'),
(10,'dinesh','Tirunelveli','6115674090','dinesh@gmail.com');
INSERT INTO Accounts VALUES
(101,'sbi',1,100000),
(102,'canara',2,50000),
(103,'union',3,75000),
(104,'indian',4,60000),
(105,'punjab',5,80000),
(106,'indian',6,90000),
(107,'iob',7,40000),
(108,'canara',8,70000),
(109,'indian',9,30000),
(110,'indian',10,65000);
INSERT INTO Transactions VALUES
(1,101,60000,'credit','Chennai','2026-01-05 07:05:33'),
(2,101,200,'credit','Madurai','2026-01-05 07:06:10'),
(3,101,300,'credit','Delhi','2026-01-05 07:06:59'),
(4,101,400,'credit','Mumbai','2026-01-05 07:08:22'),

(5,102,1000,'credit','Madurai','2026-01-13 09:23:33'),
(6,102,2000,'credit','Madurai','2026-01-21 18:05:43'),
(7,102,3000,'credit','Madurai','2026-01-22 17:35:38'),

(8,103,55000,'credit','Coimbatore','2026-01-24 15:22:40'),
(9,103,100,'credit','Chennai','2026-01-26 10:05:13'),

(10,104,45000,'credit','Salem','2026-01-21 12:57:58'),
(11,104,500,'credit','Salem','2026-01-25 17:05:33'),

(12,105,70000,'credit','Trichy','2026-01-15 07:05:33'),
(13,105,200,'credit','Chennai','2026-01-18 13:21:38'),

(14,106,85000,'credit','Chennai','2026-01-14 07:05:33'),
(15,106,100,'credit','Delhi','2026-01-14 09:18:55'),

(16,107,15000,'credit','Madurai','2026-01-27 16:43:28'),
(17,107,20000,'credit','Chennai','2026-01-29 21:22:13'),

(18,108,72000,'credit','Coimbatore','2026-01-18 13:55:32'),
(19,108,300,'credit','Bangalore','2026-01-18 17:18:46'),

(20,109,10000,'credit','Erode','2026-01-08 03:05:11');

-- 1. High Amount Fraud

select * from transactions where amount>=50000 order by amount desc;


-- 2.Total Transaction


SELECT name, city, mobile_no,
(
    SELECT COUNT(*)
    FROM Accounts a
    JOIN Transactions t ON a.account_id = t.account_id
    WHERE a.customer_id = c.customer_id
) AS total_transaction
FROM customers c;


-- 3. Multiple Transactions in Short Time

SELECT account_id, COUNT(*) as txn_count
FROM Transactions
WHERE txn_time >= "2026-01-01" - INTERVAL 5 MINUTE
GROUP BY account_id
HAVING COUNT(*) >= 3;

-- 4. Location-Based Fraud

SELECT account_id, COUNT(DISTINCT location) as locations
FROM Transactions
GROUP BY account_id
HAVING locations >= 2;

-- 5. Sudden Large Transaction (Balance-Based)

select * FROM Transactions t
JOIN Accounts a ON t.account_id = a.account_id
WHERE t.txn_type = 'credit'
AND t.amount > 0.7 * a.balance order by amount desc;  

-- 6. Auto Fraud Alert Insert

INSERT INTO Fraud_Alerts (txn_id, reason, alert_time) select txn_id,'High Amount Fraud', now() 
FROM Transactions
WHERE amount > 50000 ;

SELECT * FROM Fraud_Alerts;

-- 7. Reporting & Analysis

SELECT COUNT(*) as "total fraud" FROM Fraud_Alerts;

-- 8. Fraud Summary (Joins)

SELECT c.name,a.bank_name, COUNT(*) as fraud_count
FROM customers c
JOIN Accounts a ON c.customer_id = a.customer_id
JOIN Transactions t ON a.account_id = t.account_id
JOIN Fraud_Alerts f ON t.txn_id = f.txn_id
GROUP BY c.name,a.bank_name;

-- 9. Risk Classification

SELECT txn_id, amount,
CASE
 WHEN amount > 50000 THEN 'HIGH'
 WHEN amount >= 20000 THEN 'MEDIUM'
 ELSE 'LOW'
END AS risk
FROM Transactions order by amount desc; 

-- 10. View Creation

CREATE VIEW fraud_summary AS
SELECT 
    t.txn_id,
    c.name,
    t.amount,
    t.location,
    f.reason
FROM Fraud_Alerts f
JOIN Transactions t ON f.txn_id = t.txn_id
JOIN Accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id;

select * from fraud_summary;


