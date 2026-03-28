-- Drop tables in correct dependency order
DROP TABLE IF EXISTS Supplier_Shipment;
DROP TABLE IF EXISTS Shipment_PO;
DROP TABLE IF EXISTS Shipments;           -- DROP THIS FIRST (references Warehouses)
DROP TABLE IF EXISTS Ship_Item;
DROP TABLE IF EXISTS Order_Item;
DROP TABLE IF EXISTS Purchase_Order;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Shipment_Warehouse;     -- DROP THIS BEFORE Warehouses
DROP TABLE IF EXISTS Warehouses;          -- THEN DROP THIS
DROP TABLE IF EXISTS Items;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Clients;
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Purchase_Order_Client;


-- Create Item table
CREATE TABLE Items (
    Serial_No INT PRIMARY KEY,
    Product_ID INT REFERENCES Products(Product_ID),
);

-- Create Product table
CREATE TABLE Products (
    Product_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Brand VARCHAR(50),
    Cost DECIMAL(18, 2) NOT NULL,
    Category VARCHAR(50),
    Price DECIMAL(18, 2) NOT NULL,
    Length DECIMAL(10, 2),
    Width DECIMAL(10, 2),
    Height DECIMAL(10, 2),
    Handling_reuirements VARCHAR(255)
);


-- Create the Warehouse table
CREATE TABLE Warehouses (
    WarehouseID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    City VARCHAR(50),
    Country VARCHAR(50)
);


-- Create the Clients table
CREATE TABLE Clients (
    ClientID INT PRIMARY KEY,
    CompanyName VARCHAR(100) NOT NULL
);


-- Create the Purchase_Order Table
CREATE TABLE Purchase_Order (
    OrderID INT PRIMARY KEY,
    Status VARCHAR(20) NOT NULL,
    OrderDate DATE NOT NULL,
    Value DECIMAL(18, 2) NOT NULL
);

-- Create the Purchase_Order/Client Table
CREATE TABLE Purchase_Order_Client (
    OrderID INT REFERENCES Purchase_Order(OrderID),
    ClientID INT REFERENCES Clients(ClientID),
    PRIMARY KEY (OrderID, ClientID)
);

-- Create Order_Item Table
CREATE TABLE Order_Item (
    Serial_No INT NOT NULL,
    OrderID INT REFERENCES Purchase_Order(OrderID),
    ExpectedDeliveryDate DATE NOT NULL,
    Ordered_Qty INT NOT NULL,
    UnitPrice DECIMAL(18, 2) NOT NULL,
    PRIMARY KEY (Serial_No, OrderID)
);

-- Create Ship_Item Table
CREATE TABLE Ship_Item (
    Serial_No INT NOT NULL REFERENCES Items(Serial_No),
    OrderID INT REFERENCES Purchase_Order(OrderID),
    ActualDeliveryDate DATE NOT NULL,
    Delivered_Qty INT NOT NULL,
    PRIMARY KEY (Serial_No, OrderID)
);

-- Create Supplier Table
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Country VARCHAR(50),
    PaymentTerms VARCHAR(255),
    LeadTime INT -- in days
);

-- Create Supplier_Shipment Table
CREATE TABLE Supplier_Shipment (
    ShipmentID INT REFERENCES Shipments(ShipmentID),
    SupplierID INT REFERENCES Suppliers(SupplierID),
    PRIMARY KEY (ShipmentID, SupplierID)
);

-- Create Shipment table
CREATE TABLE Shipments (
    ShipmentID INT PRIMARY KEY,
    PurchaseOrderID INT REFERENCES Purchase_Order(OrderID),
    Ex_ArrivalDate DATE NOT NULL,
    Actual_ArrivalDate DATE,
    Ex_ShippedLocation VARCHAR(100),
    TrackingNumber VARCHAR(50),
    ShippedDate DATE
);

CREATE TABLE Shipment_Warehouse (
    ShipmentID INT REFERENCES Shipments(ShipmentID),
    WarehouseID INT REFERENCES Warehouses(WarehouseID),
    PRIMARY KEY (ShipmentID, WarehouseID)
);

-- Create Shipment_PO Table
CREATE TABLE Shipment_PO (
    ShipmentID INT REFERENCES Shipments(ShipmentID),
    OrderID INT REFERENCES Purchase_Order(OrderID),
    PRIMARY KEY (ShipmentID, OrderID)
);

-- Products
INSERT INTO Products (Product_ID, Name, Brand, Cost, Category, Price) VALUES 
(101, 'Laptop Pro', 'Tech', 800, 'Computing', 1200),
(102, 'Monitor 4K', 'View', 200, 'Display', 350),
(103, 'Phone X', 'Mobile', 500, 'Mobile', 900),
(104, 'Desk Chair', 'Ergo', 100, 'Furniture', 250);

-- Clients
INSERT INTO Clients VALUES (1, 'Alpha Corp'), (2, 'Beta Ltd'), (3, 'Gamma Inc'), (4, 'Delta Co');

-- Warehouses (Crucial for Query 2, 5, & 6)
INSERT INTO Warehouses VALUES 
(501, 'SG-Main', 'Singapore', 'Singapore'),
(502, 'LA-West', 'Los Angeles', 'USA'),
(503, 'BKK-Hub', 'Bangkok', 'Thailand');

-- Suppliers (Crucial for Query 5 & 6)
INSERT INTO Suppliers VALUES 
(901, 'SG-Direct', 'Singapore', 'Net 30', 5),     -- Only SG
(902, 'Thai-Export', 'Thailand', 'Prepaid', 10),   -- Thailand
(903, 'Global-Log', 'USA', 'Net 60', 15),         -- Multi-region
(904, 'LionCity-Supplies', 'Singapore', 'Net 30', 3); -- Only SG

-- Purchase Orders (Spanning 2024 - 2026)
-- Adding more orders to create monthly trends for 2024 and 2025
INSERT INTO Purchase_Order (OrderID, Status, OrderDate, Value) VALUES 
(2007, 'Completed', '2024-05-10', 1500.00),
(2008, 'Completed', '2024-05-22', 2100.00), -- May 2024 now has 2 orders
(2009, 'Completed', '2024-11-05', 4000.00), -- Nov 2024 now has 3 orders total
(2010, 'Completed', '2024-12-12', 5500.00),
(2011, 'Completed', '2025-05-15', 3200.00),
(2012, 'Completed', '2025-05-28', 1800.00), -- May 2025 now has 3 orders total
(2013, 'Completed', '2025-07-04', 900.00),
(2014, 'Completed', '2025-07-20', 1200.00),
(2015, 'Completed', '2025-08-15', 6000.00),
(2016, 'Completed', '2025-11-20', 2500.00), -- Nov 2025 now has 2 orders
(2017, 'Completed', '2025-11-25', 3000.00), -- Nov 2025 now has 3 orders
(2018, 'Completed', '2024-08-10', 1100.00);

-- Linking Clients to Orders (For Query 1)
INSERT INTO Purchase_Order_Client (OrderID, ClientID) VALUES 
(2007, 1), (2008, 2), (2009, 3), (2010, 4), 
(2011, 1), (2012, 2), (2013, 3), (2014, 4),
(2015, 1), (2016, 2), (2017, 3), (2018, 4);

-- Items (Required for FKs)
INSERT INTO Items VALUES (10001, 101), (10002, 102), (10003, 103), (10004, 104);

-- Shipments
-- Note: Shipment 3001 is DELAYED by > 6 months (May to Dec)
-- Format: ShipmentID, PO_ID, Ex_Arrival, Actual_Arrival, Location, Track#, ShippedDate
INSERT INTO Shipments VALUES 
(3005, 2007, '2024-06-10', '2024-06-12', 'Port A', 'TRK005', '2024-05-15'),
(3006, 2008, '2024-06-20', '2024-07-01', 'Port B', 'TRK006', '2024-06-01'),
(3007, 2009, '2024-12-05', '2024-12-10', 'Port C', 'TRK007', '2024-11-10'),
(3008, 2010, '2025-01-15', '2025-01-20', 'Port D', 'TRK008', '2024-12-20'),
(3009, 2011, '2025-06-15', '2025-06-18', 'Port E', 'TRK009', '2025-05-20'),
(3010, 2012, '2025-07-01', '2025-07-05', 'Port F', 'TRK010', '2025-06-05'),
(3011, 2015, '2025-09-15', '2025-10-15', 'Port G', 'TRK011', '2025-08-20'),
(3012, 2017, '2025-12-20', '2025-12-22', 'Port H', 'TRK012', '2025-12-01');
-- Linking Suppliers to Shipments
INSERT INTO Supplier_Shipment VALUES 
(3001, 901), -- SG Supplier
(3002, 903), -- Global Supplier
(3003, 904), -- SG Supplier
(3004, 902); -- Thai Supplier

INSERT INTO Shipment_Warehouse (ShipmentID, WarehouseID) VALUES 
(3005, 501), -- Singapore
(3006, 502), -- Los Angeles
(3007, 501), -- Singapore
(3008, 502), -- Los Angeles
(3009, 501), -- Singapore
(3010, 502), -- Los Angeles
(3011, 501), -- Singapore
(3012, 502); -- Los Angeles

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