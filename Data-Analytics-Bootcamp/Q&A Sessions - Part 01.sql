--Soru: Şehir bilgisi London veya Tacoma olan tüm personelin id , ad ve soyad bilgisini çekiniz
--Provide the id, first name and last name of all personnel whose city information is London or Tacoma.

SELECT EmployeeID, LastName, FirstName, City
FROM Employees
WHERE City = 'Tacoma' OR City = 'London'
 
--Soru: CategoryId adetlerini ayrı ayrı hesaplanyınız (ürünler)
--Calculate number of CategoryId quantities separately (products)

SELECT CategoryID,
COUNT (CategoryID) adet
FROM Products
GROUP BY CategoryID

--Soru: CategoryId bazında min , max ve ortalama birim fiyatlarını hesaplayınız (Max fiyatlara göre yüksek fiyattan düşük fiyata sıralanması)
--Calculate min, max and average unit prices based on CategoryId ((Sorting from high price to low price according to max prices)

SELECT CategoryID, MIN(UnitPrice) min_br_fyt, MAX(UnitPrice) max_br_fyt, AVG(UnitPrice) ort_br_fyt
FROM Products
GROUP BY CategoryID
ORDER BY MAX (UnitPrice) DESC

--Soru: Customer tablosunundan ContactName, Orders tablosundan OrderID’ı çekiniz
--Question: Provide ContactName from the Customer table and OrderID from the Orders table

SELECT C.ContactName, O.OrderID FROM Customers C
LEFT JOIN Orders O
ON C.CustomerID = O.CustomerID

--Soru: Orders tablosunundan OrderID ile Customers tablosundan ContactName’i birleşmiş bir tablodan çekiniz
--Question: Provide OrderID from the Orders table and ContactName from the Customers table with joined table

SELECT O.OrderID, C.ContactName, COUNT(*)
FROM Orders O
INNER JOIN Customers C
ON O.CustomerID = C.CustomerID   --GROUP BY  C.ContactName , OrderID having COUNT(*)>1   //// TO CHECK DUPLICATE or ERRORS

--Soru: Ürün ve Şirket adlarını listeleyin
--List for Products and Company names

SELECT P.ProductName UrunAdi, S.CompanyName SirketIsmi
FROM Products P 
LEFT JOIN Suppliers S 
ON P.SupplierID = S.SupplierID

--Soru: Ürün ve kategori adlarını listeleyin
--List for Products and Categories

SELECT P.ProductName, C.CategoryName
FROM Products P
LEFT JOIN Categories C
ON P.CategoryID = C.CategoryID

--BONUS :) CategoryNames starting with letter 'B'
 
SELECT * FROM
(SELECT P.ProductName, C.CategoryName
FROM Products P
LEFT JOIN Categories C
ON P.CategoryID = C.CategoryID) A
WHERE A.CategoryName LIKE 'B%'

--Soru: Ürün ve Şirket adlarını listeleyiniz ve adetlerini bulun
--List product and company names with their quantities

SELECT A.SirketIsmi, A.UrunAdi, COUNT(A.SirketIsmi) sirketsayisi, COUNT(A.UrunAdi) urunsayisi FROM
(SELECT P.ProductName UrunAdi, S.CompanyName SirketIsmi
FROM Products P 
LEFT JOIN Suppliers S 
ON P.SupplierID = S.SupplierID) A
GROUP BY A.SirketIsmi, A.UrunAdi

--ALTERNATIVE SOLUTION
SELECT P.ProductName UrunAdi, COUNT(ProductName), S.CompanyName SirketIsmi, COUNT(CompanyName)
FROM Products P 
LEFT JOIN Suppliers S 
ON P.SupplierID = S.SupplierID
GROUP BY ProductName, CompanyName

--Soru: Kategori bazında toplam fiyatın hesaplayınız ve toplam birim fiyatı 200'den düşük kategorilerin filtreleyiniz
--Calculate the total price for each category and filter out the categories that have a total unit price of less than $200.

SELECT * FROM
(SELECT CategoryID, SUM(UnitPrice) toplam_br_fyt
FROM Products
GROUP BY CategoryID) A 
WHERE toplam_br_fyt < 200

--ALTERNATIVE SOLUTION
 
SELECT CategoryID, SUM(UnitPrice) toplam_br_fyt
FROM Products
GROUP BY CategoryID
HAVING SUM(UnitPrice) < 200

--Soru: En ucuz 5 ürünün ortalama fiyatı nedir ?
--What is the average price of the 5 cheapest products?

SELECT AVG(UnitPrice) Ortalam_br_fyt FROM 
(SELECT TOP 5 ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice ASC) A 

--Soru: En pahalı ürününün adı nedir?
--What is the name of most expensive product?

SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM Products)

-- BONUS (EN PAHALI 2. ÜRÜN NEDİR)
-- What is the 2nd Most Expensive Product?

SELECT TOP 1 ProductName, UnitPrice
FROM Products
WHERE UnitPrice <> (SELECT MAX(UnitPrice) FROM Products)
ORDER BY UnitPrice DESC

--Soru: En pahalı ve en ucuz ürünü listeleyiniz. 
--List the most expensive and cheapest product

SELECT * FROM
(SELECT TOP 1 * FROM Products
ORDER BY UnitPrice DESC) A
UNION
SELECT * FROM
(SELECT TOP 1 * FROM Products
ORDER BY UnitPrice ASC) B

--Soru: Zamanında teslim edemediğim siparişlerim ID’leri nelerdir ve kaç gün geç gönderildi?
--What are the IDs of the orders that were not shipped on time and how many days late were they shipped?

SELECT OrderID, RequiredDate, ShippedDate, DATEDIFF(DAY, ShippedDate, RequiredDate) GecikmeSuresi
FROM Orders     
WHERE DATEDIFF(DAY, ShippedDate, RequiredDate) > 0 
ORDER BY GecikmeSuresi DESC

-- "Geciken Urunler"in ortalama Kac gun Geciktiğini bulan sorguyu yazınız.
-- Write the query that will find the average number of days that products are late for delivery.

SELECT OrderID, AVG(GecikmeSuresi) OrtalamaGecikmeSuresi FROM
(SELECT OrderID, RequiredDate, ShippedDate, DATEDIFF(DAY, ShippedDate, RequiredDate) GecikmeSuresi
FROM Orders     
WHERE DATEDIFF(DAY, ShippedDate, RequiredDate) > 0 ) A 
GROUP BY OrderID

-- "Erken Giden Urunlerin" ortalama kac gun erken gittiğini bulan sorguyu yazınız.
--Write the query that finds the average number of days early delivery of products.

SELECT OrderID, AVG(ErkenTeslimSuresi) OrtalamaErkenTeslimSuresi FROM
(SELECT OrderID, RequiredDate, ShippedDate, DATEDIFF(DAY, RequiredDate, ShippedDate) ErkenTeslimSuresi
FROM Orders     
WHERE DATEDIFF(DAY, RequiredDate, ShippedDate) > 0 ) B
GROUP BY OrderID
