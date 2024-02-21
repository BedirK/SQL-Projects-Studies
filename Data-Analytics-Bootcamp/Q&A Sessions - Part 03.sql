--Soru: "Orders" tablosunu kullanarak, siparişlerin hangi aylarda yapıldığını ve her ay kaç sipariş olduğunu bulan bir SQL sorgusu oluşturunuz.
--Question: Using the "Orders" table, write a SQL query that finds the months in which orders were made and how many orders there were in each month.

SELECT
    DATEPART(month, o.OrderDate) AS OrderMonth,
    COUNT(*) AS OrderCount
FROM Orders o
GROUP BY DATEPART(month, o.OrderDate)
ORDER BY OrderMonth

--Soru: Ürünleri fiyatlarına göre sıralayarak her ürünün fiyat sıralama numarasını bulun.
--Question: Sort the products by price and find the price ranking number of each product.

SELECT ProductName,
       UnitPrice,
       RANK() OVER (ORDER BY UnitPrice) AS PriceRank
FROM    Products
ORDER BY  UnitPrice;

--Soru: Siparişleri sipariş tutarına göre eşit parçalara bölün (dörtte birlik dilimlere ayırın).
--Question: Divide orders into equal parts (quartiles) according to the order amount.

SELECT  OrderID,
        CustomerID,
        OrderDate,
        Freight,
NTILE(4) OVER (ORDER BY Freight) AS FreightQuartile
FROM Orders
ORDER BY Freight

--Soru: Siparişleri sipariş tutarına göre eşit parçalara bölün (dörtte birlik dilimlere ayırın) ve 4 segment oluşturun. (Dusuk, Orta, Yuksek, Cok Yuksek)
--Question: Divide orders into equal parts (quartiles) based on order amount and 4 segments (Low, Medium, High, Very High)

SELECT  OrderID,
        CustomerID,
        OrderDate,
        Freight,
CASE
    WHEN NTILE(4) OVER (ORDER BY Freight) = 1 THEN 'LOW'
    WHEN NTILE(4) OVER (ORDER BY Freight) = 2 THEN 'MEDIUM'
    WHEN NTILE(4) OVER (ORDER BY Freight) = 3 THEN 'HIGH'
    WHEN NTILE(4) OVER (ORDER BY Freight) = 4 THEN 'VERY HIGH'
END AS FreightQuartile
FROM Orders
ORDER BY Freight

--Soru: Ürünleri birim fiyatlarına göre ucuz (<10), orta fiyatlı ve pahalı (>50) olarak sınıflandırın.
--Question: Categorize products according to their unit price as cheaper (<10), medium priced and expensive (>50).

SELECT  ProductName,
        UnitPrice,
CASE
    WHEN UnitPrice < 10 THEN 'Cheaper'
    WHEN UnitPrice BETWEEN 10 AND 50 THEN 'Medium Priced'
    WHEN UnitPrice > 50 THEN 'High Priced'
END AS PriceCategory
FROM Products

--Soru: Müşterilerin iletişim adreslerinin başına Adres: ekleyiniz.
--Question: Add "Address:" at the beginning of the customers' contact addresses.

SELECT  ContactName,
        Address,
        STUFF(Address, 1, 0, 'Adres: ') AS ModifiedAddress
FROM    Customers

---CTE (COMMON TABLE EXPRESSIONS)

-- Soru: Aşağıdaki kodu Common Table Expression örneği ile yazınız.
-- Question: Write the following code by using Common Table Expression

SELECT EmployeeID CALISAN, YEAR(OrderDate) AS YIL,SUM(Freight) AS YIL_CIRO FROM Orders
GROUP BY EmployeeID, YEAR(OrderDate)
SELECT CALISAN, CONVERT(INT,SUM(YIL_CIRO)) AS CIRO FROM
(SELECT EmployeeID CALISAN, YEAR(OrderDate) AS YIL,SUM(Freight) AS YIL_CIRO FROM Orders
GROUP BY EmployeeID, YEAR(OrderDate) ) T
GROUP BY CALISAN
ORDER BY CIRO DESC

--CTE -- -- -- -- -- -- -- -- -- -- -- --

WITH EmployeeCTE AS (
    SELECT EmployeeID, YEAR(OrderDate) AS OrderYear, SUM(Freight) AS TurnOver
    FROM Orders
    GROUP BY EmployeeID, YEAR(OrderDate)
)

SELECT EmployeeID, CONVERT(INT, SUM(TurnOver)) AS CIRO 
FROM EmployeeCTE
GROUP BY EmployeeID 
ORDER BY CIRO DESC;


--VIEW
--Soru: Bu tabloyu VIEW olarak oluşturunuz. Sonra siliniz
--Question: Create below table as VIEW, then delete it.

CREATE VIEW VIEW_CustomerOrders_BK AS
SELECT
c.CustomerID,
c.ContactName,
o.OrderID,
o.OrderDate
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID

SELECT * FROM VIEW_CustomerOrders_BK

DROP VIEW VIEW_CustomerOrders_BK;
