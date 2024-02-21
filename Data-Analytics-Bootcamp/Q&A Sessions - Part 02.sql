--Soru: Siparişler kaç günde teslim edildi?
--Question: In how many days were the orders delivered?

SELECT OrderID, OrderDate, ShippedDate, DATEDIFF(DAY, OrderDate, ShippedDate) AS delivery_time 
FROM Orders
WHERE ShippedDate IS NOT NULL
ORDER BY delivery_time DESC

--Soru: Hangi kargo şirketine toplam 25000 birimden daha az ödeme yapılmıştır ?
--Question: Which shipping company was paid less than 25000 units in total?

SELECT S.CompanyName, SUM(O.Freight) AS Payment
FROM Orders O 
LEFT JOIN Shippers S
ON O.ShipVia = S.ShipperID  
GROUP BY S.CompanyName
HAVING SUM(O.Freight) <= 25000   

--Soru: Çalışanlar ne kadarlık satış yapmıştır?
--Question: How much did the employees sell?

SELECT E.EmployeeID, E.LastName, E.FirstName, SUM(OD.UnitPrice * OD.Quantity) AS TotalSales
FROM Orders O 
INNER JOIN  Employees E ON O.EmployeeID = E.EmployeeID
INNER JOIN  [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY E.EmployeeID, E.LastName, E.FirstName

--ALTERNATIVE QUERY 

SELECT E.EmployeeID, (E.LastName + ' ' + E.FirstName) AS Salesman, SUM(OD.UnitPrice * OD.Quantity) AS TotalSales
FROM Orders O 
INNER JOIN  Employees E ON O.EmployeeID = E.EmployeeID
INNER JOIN  [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY E.EmployeeID, (E.LastName + ' ' + E.FirstName)

--Soru: 50 'den fazla satışı olan çalışanları bulunuz
--Question: Find employees with more than 50 sales

SELECT E.EmployeeID, (E.LastName + ' ' + E.FirstName) AS Salesman, COUNT(O.OrderID) AS CountSales
FROM Orders O 
INNER JOIN  Employees E ON O.EmployeeID = E.EmployeeID
GROUP BY E.EmployeeID, (E.LastName + ' ' + E.FirstName)
HAVING COUNT(O.OrderID) > 50

--Soru: Çalışanlar ürün bazında ne kadarlık satış yapmışlar?
--Question: How much did employees sell per product?

SELECT  E.EmployeeID, (E.LastName + ' ' + E.FirstName) AS Salesman,
        P.ProductName, 
        SUM(OD.Quantity) AS TotalSales, 
        SUM(OD.UnitPrice * OD.Quantity) AS TotalSalesPrice
FROM Orders O 
INNER JOIN  Employees E ON O.EmployeeID = E.EmployeeID
INNER JOIN  [Order Details] OD ON O.OrderID = OD.OrderID
INNER JOIN  Products P ON P.ProductID = OD.ProductID
GROUP BY E.EmployeeID, (E.LastName + ' ' + E.FirstName), P.ProductName

--Soru: Toplam birim fiyatı 200'den düşük kategorilerin getiriniz.
--Question: Show categories with a total unit price less than 200.

SELECT C.CategoryName, SUM(P.UnitPrice) AS TotalUnitPrice
FROM Categories C 
INNER JOIN Products P ON P.CategoryID = C.CategoryID
GROUP BY C.CategoryName
HAVING SUM(P.UnitPrice) < 200

--Soru: En değerli müşterim hangisi? (en fazla satış yaptığım müşteri) (Gelir ve adet bazında)
--Question: Which is my most valuable customer (the customer I sell to the most) (based on revenue and quantity)

SELECT TOP 1 C.CompanyName, SUM(OD.Quantity) AS TotalSalesCount, SUM(OD.UnitPrice * OD.Quantity) TotalSalesPrice
FROM Orders O  
INNER JOIN Customers C ON C.CustomerID = O.CustomerID
INNER JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY C.CompanyName
ORDER BY TotalSalesPrice DESC

--Soru: Discount oranını da hesaba katarak en çok kazanç getiren 5 ürünü bulunuz.
--Question: Find the 5 most profitable products, taking into account the discount rate.

SELECT ProductID, ROUND(TotalAmount,0) AS TotalAmount_Rounded
FROM (
    SELECT 
        ProductID, 
        SUM(UnitPrice * Quantity * (1 - Discount)) AS TotalAmount,
        ROW_NUMBER() OVER (ORDER BY SUM(UnitPrice * Quantity * (1 - Discount)) DESC) AS RN
    FROM 
        [Order Details]
    GROUP BY 
        ProductID
) AS T1
WHERE RN <= 5;

--Soru: En yüksek ikinci unit_price değerini row_number kullanmadan bulunuz.
--Question: Find the second highest unit_price value without using "row_number" functions.


SELECT MAX(UnitPrice) AS UnitPriceValue 
FROM [Order Details]
WHERE UnitPrice <> (SELECT MAX(UnitPrice) FROM [Order Details])

-- same question (by using row number)
  
SELECT UnitPrice FROM 
(SELECT UnitPrice, ROW_NUMBER() OVER (ORDER BY UnitPrice DESC) AS RN 
FROM [Order Details]) A 
WHERE RN = 2

--Siparişin verildiği gün ile o ayın son günü arasındaki farkı bulunuz
--Find the difference between the day the order was placed and the last day of the related month.

SELECT OrderID, 
       OrderDate, 
       EOMONTH(OrderDate) AS EndOfMonth, 
       DATEDIFF(DAY,OrderDate,EOMONTH(OrderDate)) AS DayDiff
FROM Orders

--Soru: 10’dan fazla sipariş veren müşterilerin ID ve sipariş sayılarını bulunuz.
--Question: Find the CustomerID and number of orders for customers with more than 10 orders.

SELECT CustomerID, COUNT(OrderID) AS CountOrder
FROM Orders
GROUP BY CustomerID
HAVING COUNT(DISTINCT OrderID) > 10

--Soru: Bir seferinde 100 adetten fazla alınmış ürünlerden olup stoktaki sayısı 100 altında olan ürünlerin ID’lerini listeleyiniz.
--Question: List the IDs of the products that are purchased more than 100 times and number of units in stock is less than 100.

SELECT DISTINCT ProductID, Quantity
FROM [Order Details]
WHERE quantity > 100

EXCEPT    -- MINUS

SELECT DISTINCT ProductID, UnitsInStock
FROM Products
WHERE UnitsInStock < 100;

--Soru: 1997 yılındaki her aya ait toplam harcamayı hesaplayıp mevcut ay, o aya ait toplam harcama, bir önceki ve bir sonra ki aya ait toplam harcama bilgilerini paylaşınız
--Question: Calculate and List the total expenditure for each month in 1997 and provide the total expenditure for the current month, the previous month, and the next month:

SELECT *,
    LAG(total_amount) OVER (ORDER BY order_month) AS PreviousMonthExpenditure,
    LEAD(total_amount) OVER (ORDER BY order_month) AS NextMonthExpenditure
FROM (
    SELECT 
        order_month, 
        ROUND(SUM(Amount), 0) AS total_amount 
    FROM (
        SELECT
            UnitPrice * Quantity * (1 - Discount) AS Amount,
            MONTH(o.OrderDate) AS order_month
        FROM [Order Details] od
        INNER JOIN Orders o ON o.OrderID = od.OrderID
        WHERE YEAR(o.OrderDate) = 1997
    ) AS T
    GROUP BY order_month
) AS T2
ORDER BY order_month;
