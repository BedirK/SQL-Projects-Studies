--Soru: Siparişler kaç günde teslim edildi?
--Question: In how many days were the orders delivered?

SELECT OrderID, DATEDIFF(DAY, OrderDate, ShippedDate) teslim_suresi 
FROM Orders
WHERE ShippedDate IS NOT NULL
ORDER BY teslim_suresi DESC

--Soru: Hangi kargo şirketine toplam 25000 birimden daha az ödeme yapılmıştır ?
--Question: Which shipping company was paid less than 25000 units in total?

SELECT S.CompanyName, SUM(O.Freight) payment
FROM Orders O 
LEFT JOIN Shippers S
ON O.ShipVia = S.ShipperID  
GROUP BY S.CompanyName
HAVING SUM(O.Freight) <= 25000     

--Soru: Çalışanlar ne kadarlık satış yapmıştır?
--Question: How much did the employees sell?

SELECT E.EmployeeID, E.LastName, E.FirstName, SUM(OD.UnitPrice * OD.Quantity) TotalSales
FROM Orders O 
INNER JOIN  Employees E ON O.EmployeeID = E.EmployeeID
INNER JOIN  [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY E.EmployeeID, E.LastName, E.FirstName

--ALTERNATIVE QUERY 

SELECT E.EmployeeID, (E.LastName + ' ' + E.FirstName) Salesman, SUM(OD.UnitPrice * OD.Quantity) TotalSales
FROM Orders O 
INNER JOIN  Employees E ON O.EmployeeID = E.EmployeeID
INNER JOIN  [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY E.EmployeeID, (E.LastName + ' ' + E.FirstName)

--Soru: 50 'den fazla satışı olan çalışanları bulunuz
--Question: Find employees with more than 50 sales


SELECT E.EmployeeID, (E.LastName + ' ' + E.FirstName) Salesman, COUNT(O.OrderID) CountSales
FROM Orders O 
INNER JOIN  Employees E ON O.EmployeeID = E.EmployeeID
GROUP BY E.EmployeeID, (E.LastName + ' ' + E.FirstName)
HAVING COUNT(O.OrderID) > 50

--Soru: Çalışanlar ürün bazında ne kadarlık satış yapmışlar?
--Question: How much did employees sell per product?

SELECT E.EmployeeID, (E.LastName + ' ' + E.FirstName) Salesman,P.ProductName, SUM(OD.Quantity) TotalSales, SUM(OD.UnitPrice * OD.Quantity) TotalSalesPrice
FROM Orders O 
INNER JOIN  Employees E ON O.EmployeeID = E.EmployeeID
INNER JOIN  [Order Details] OD ON O.OrderID = OD.OrderID
INNER JOIN  Products P ON P.ProductID = OD.ProductID
GROUP BY E.EmployeeID, (E.LastName + ' ' + E.FirstName), P.ProductName

--Soru: Toplam birim fiyatı 200'den düşük kategorilerin getiriniz.
--Question: Show categories with a total unit price less than 200.

SELECT C.CategoryName, SUM(P.UnitPrice) TotalUnitPrice
FROM Categories C 
INNER JOIN Products P ON P.CategoryID = C.CategoryID
GROUP BY C.CategoryName
HAVING SUM(P.UnitPrice) < 200

--Soru: En değerli müşterim hangisi? (en fazla satış yaptığım müşteri) (Gelir ve adet bazında)
--Question: Which is my most valuable customer (the customer I sell to the most) (based on revenue and quantity)?

SELECT TOP 1 C.CompanyName, SUM(OD.Quantity) TotalSales, SUM(OD.UnitPrice * OD.Quantity) TotalSalesPrice
FROM Orders O  
INNER JOIN Customers C ON C.CustomerID = O.CustomerID
INNER JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY C.CompanyName
ORDER BY TotalSalesPrice DESC

--Soru: Discount oranını da hesaba katarak en çok kazanç getiren 5 ürünü bulunuz.
  --Question: Find the 5 most profitable products, taking into account the discount rate.

SELECT * FROM (
SELECT *, ROW_NUMBER() OVER(ORDER BY Total_Amount DESC) AS RN
FROM ( SELECT ProductID, ROUND(sum(Amount),0) as Total_Amount
FROM (SELECT ProductID, UnitPrice * Quantity * (1- Discount) as Amount
FROM [Order Details] ) T1
GROUP BY ProductID) T2) T3
WHERE RN <= 5

--Soru: En yüksek ikinci unit_price değerini row_number kullanmadan bulunuz.
--Question: Find the second highest unit_price value without using "row_number" functions.


SELECT MAX(UnitPrice) UnitPriceValue FROM [Order Details]
WHERE UnitPrice <> (SELECT MAX(UnitPrice) 
FROM [Order Details])

-- same question (by using row number)
  
SELECT UnitPrice FROM 
(SELECT UnitPrice, ROW_NUMBER() OVER (ORDER BY UnitPrice DESC) AS RN 
FROM [Order Details]) A 
WHERE RN = 2

--Siparişin verildiği gün ile o ayın son günü arasındaki farkı bulunuz
--Find the difference between the day the order was placed and the last day of the related month.

SELECT OrderID, OrderDate, EOMONTH(OrderDate) EndOfMonth, DATEDIFF(DAY,OrderDate,EOMONTH(OrderDate)) DayDiff
FROM Orders

--Soru: 10’dan fazla sipariş veren müşterilerin ID ve sipariş sayılarını bulunuz.
--Question: Find the CustomerID and number of orders for customers with more than 10 orders.

SELECT CustomerID, COUNT(OrderID) CountOrder
FROM Orders
GROUP BY CustomerID
HAVING COUNT(DISTINCT OrderID) > 10

--Soru: Bir seferinde 100’den fazla quantitysi alınmış ürünlerden olup stocktaki unit sayısı 100 altında olan ürünlerin ID’lerini listeleyiniz.
--Question: List the IDs of the products that are purchased in quantities greater than 100 and the number of units in stock is less than 100.


SELECT DISTINCT ProductID, Quantity
FROM [Order Details]
WHERE quantity > 100
EXCEPT    -- MINUS
SELECT DISTINCT ProductID, UnitsInStock
FROM Products
WHERE UnitsInStock < 100;

--Soru: 1997 yılındaki her aya ait toplam harcamayı hesaplayıp mevcut ay, o aya ait toplam harcama, bir önceki ve bir sonra ki aya ait toplam harcama bilgilerini paylaşınız

SELECT *, 
LAG(total_amount) OVER (ORDER BY order_month DESC) AS NextQuota ,
LEAD(total_amount) OVER (ORDER BY order_month DESC) AS BeforeQuota 
FROM
(SELECT order_month, ROUND(SUM(Amount),0) total_amount FROM
(SELECT
UnitPrice * Quantity * (1- Discount) as Amount,
MONTH(o.OrderDate) as order_month
FROM [Order Details] od
INNER JOIN Orders o
ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = 1997) T
GROUP BY order_month) T2
ORDER BY order_month

--Soru: Orders tablosunda Ship Region’ı dolu olanların bilgisini tutan ama boş olanları Ship_City’nin ilk 3 harfini büyük harf ile gösterecek şekilde alan query’yi yazınız. 
  Not: COALESCE() fonksiyonu, bir ifade listesindeki ilk boş olmayan değeri döndürmek için kullanılır.

 SELECT ShipRegion, ShipCity,left(ShipCity,3) A, COALESCE (ShipRegion, left(ShipCity,3)) B
 FROM Orders;

 SELECT *, UPPER(COALESCE (ShipRegion, left(ShipCity,3)))
 FROM Orders;
