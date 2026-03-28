-- Question 1: Top 3 clients per warehouse (by total business value)
WITH ClientTotals AS (
    SELECT
        W.Name AS Warehouse,
        C.CompanyName AS Client,
        SUM(PO.Value) AS TotalBusinessValue,
        ROW_NUMBER() OVER(PARTITION BY W.WarehouseID ORDER BY SUM(PO.Value) DESC) AS Rank
    FROM Purchase_Order PO
    JOIN Purchase_Order_Client POC ON PO.OrderID = POC.OrderID
    JOIN Clients C ON POC.ClientID = C.ClientID
    JOIN Shipments S ON PO.OrderID = S.PurchaseOrderID
    JOIN Shipment_Warehouse SW ON S.ShipmentID = SW.ShipmentID
    JOIN Warehouses W ON SW.WarehouseID = W.WarehouseID
    GROUP BY W.WarehouseID, W.Name, C.ClientID, C.CompanyName
)
SELECT Warehouse, Client, TotalBusinessValue
FROM ClientTotals
WHERE Rank <= 3
ORDER BY Warehouse, Rank;


-- Question 2
SELECT 
    W.City, 
    SUM(PO.Value) AS Total_Business_Value
FROM Warehouses W
JOIN Shipment_Warehouse SW ON W.WarehouseID = SW.WarehouseID
JOIN Shipments S ON SW.ShipmentID = S.ShipmentID
JOIN Purchase_Order PO ON S.PurchaseOrderID = PO.OrderID
WHERE W.City IN ('Singapore', 'Los Angeles')
GROUP BY W.City;


-- Question 3
SELECT TOP 3 
    YEAR(OrderDate) AS OrderYear, 
    MONTH(OrderDate) AS OrderMonth,
    COUNT(OrderID) AS Total_Orders
FROM Purchase_Order
WHERE YEAR(OrderDate) IN (2024, 2025)
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Total_Orders DESC, OrderYear DESC;