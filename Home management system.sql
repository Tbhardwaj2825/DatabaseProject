create database HomeRentDB;
use HomeRentDB;

--#table Home
create table Home(
House_no int,
primary key(House_no),
type varchar (40),
Location varchar(40),
No_of_rooms int,
rent int,
status varchar(30),
tenantName varchar(30),
OwnerName varchar(40),
);

Insert into Home (House_no,type,Location,No_of_rooms,rent,status,tenantName,OwnerName) values 
(8825,'Flat','Delhi',3,10000,'vacant',null, 'Yash Malik'),
(6654,'villa','Mumbai',5,70000,'Occupied','Aman Gupta','Karan Sharma'),
(8832,'Duplex','Chennai',6,90000,'Occupied','Piyush Bhardwaj','Mohit Jain'),
(9087,'Duplex','Delhi',6,85000,'Occupied','Anika Sharma','Amisha Seth'),
(2345,'Flat','Delhi',2,8000,'vacant',null,'Ayesha Saini'),
(9123,'Flat','Kolkata',3,12000,'Occupied','Priyanka Nagar','anket Chauhan'),
(5674,'villa','Delhi',4,95000,'Occupied','Rahul Mehra','Dhruv Verma'),
(1276,'Flat','Mumbai',1,6000,'Occupied','Rishabh kaushik','Ayush Tyagi'),
(4590,'villa','Delhi',4,95000,'Occupied','Neha Batra','Shweta Singh'),
(3609,'Duplex','Chennai',8,90000,'Occupied','Nishant Mishra','Sagar Mishra');

SELECT * FROM Home
ORDER BY House_no DESC;

---To split first and last name
SELECT
 left(tenantName, charindex(' ', tenantName) - 1) AS 'FirstName',
 REVERSE(SUBSTRING(REVERSE(tenantName), 1, CHARINDEX(' ', REVERSE(tenantName)) - 1))  AS 'LastName'
 FROM Home

 --creating index on type column
CREATE INDEX idx_type
ON Home (type);


-- #table tenant
create table tenant(
TenantID int identity(2022,5), primary key(TenantID),
govtID varchar(80) not null UNIQUE,
tenantName varchar(30),
PhoneNo varchar(15) Not null UNIQUE,
email varchar(30),
discount float,
House_no int ,
HomeState varchar(30),
Gender char,
Occupation varchar(40)
);

Select * from tenant

-- adding foreign key constraint as HomeID in table tenant
ALTER TABLE Tenant
ADD FOREIGN KEY (House_no) REFERENCES Home(House_no);

insert into tenant (govtID,tenantName,PhoneNo,email,discount,House_no,HomeState,gender,Occupation) values
('QW234','Rahul Mehra','987321','rahul@gmail.com','1.2','5674','Punjab','M','student'),
('AS324','Rishabh Kaushik','9873765','rishabh@gmail.com','0','1276','Uttarakhand','M','Developer'),
('JH098','Ankita Sharma','654987','ankita@gmail.com','2.1','9087','Rajasthan','F','Engineer'),
('NB876','Nishant Mishra','123098','nishant@gmail.com','0','3609','Punjab','M','Actor'),
('ML690','Neha Batra','891234','neha@gmail.com','1.8','4590','Rajasthan','F','student'),
('AQ642','Aman Gupta','093535','aman@gmail.com','2.5','6654','Uttar Pradesh','M','Developer'),
('PO981','Piyush Bhardwaj','928273','piyush@gmail.com','0','8832','Haryana','M','Professor'),
('HY851','Priyanka Nagar','781263','priyanka@gmail.com','0.5','9123','Haryana','F','Business Owner');

--to create index on phoneNo and name column
CREATE INDEX tenant_phone
ON tenant (tenantName, PhoneNO);

SELECT House_no
FROM tenant
ORDER BY House_no ASC;

--#table RentRecords
create table RentRecords(
RentID int identity(8765,7) Primary key,
House_No int FOREIGN KEY(House_No) REFERENCES Home(House_No),
TenantID int FOREIGN KEY(TenantID) REFERENCES Tenant(TenantID),
BookingDate Date not null,
PaymentMedium varchar(20),
amount int,
);

select * from RentRecords

Insert into RentRecords(House_No,TenantID,BookingDate,PaymentMedium,amount) values
(5674,2022,'2020-12-04','cheque',10000),
(1276,2027,'2021-09-04','cash',80000),
(9087,2032,'2022-03-04','online',60000),
(3609,2037,'2022-01-04','cheque',90000),
(4590,2042,'2020-04-04','online',50000),
(6654,2047,'2021-07-04','online',70000),
(8832,2052,'2021-08-04','online',85000),
(9123,2057,'2021-11-04','cheque',95000);

-- stored procedure
USE HomeRentDB
GO 
CREATE PROCEDURE Paymentamount @mode nvarchar(30), @amt int 
AS 
SELECT * FROM RentRecords WHERE PaymentMedium = @mode and amount = @amt 
GO


--#table owner
create table owner(
ownerID int identity(3000,3) PRIMARY KEY,
House_no int FOREIGN KEY(House_No) REFERENCES Home(House_No),
address varchar(50),
OwnerName varchar(40));

INSERT INTO owner (House_no,address,OwnerName) values
(1276,'A-district,Pune','Ayush Tyagi'),
(2345,'B-district,Jaipur','Ayesha Saini'),
(3609,'C-district,Hyderabad','Sagar Mishra'),
(4590,'A-district,Bangalore','Shweta Singh'),
(5674,'D-district,Delhi','Dhruv Verma'),
(6654,'B-district,Haryana','Karan Sharma'),
(8825,'G-district,Haryana','Yash Malik'),
(8832,'F-district,Delhi','Mohit Jain'),
(9087,'XY-district,Mumbai','Amisha Seth'),
(9123,'AB-district,Kerala','anket Chauhan');

select * from owner;

--To sort type with their house_no(left join)
SELECT Home.House_no, Home.type
FROM Home
 LEFT JOIN RentRecords ON Home.House_no = RentRecords.House_No
ORDER BY Home.type DESC;

--to list tenants who are from same homestate(self join)
SELECT A.TenantName AS TenantName1, B.TenantName AS TenantName2, A.HomeState
FROM tenant A, tenant B
WHERE A.TenantID <> B.TenantID
AND A.HomeState = B.HomeState
ORDER BY A.HomeState;


--to sort booking date with columns listed (bookingid, tenantid, tenantname) full join
SELECT RentRecords.BookingDate, RentRecords.PaymentMedium, RentRecords.TenantID, tenant.tenantName
FROM RentRecords
 JOIN tenant ON RentRecords.TenantID = tenant.TenantID
ORDER BY RentRecords.BookingDate DESC;

--calling stored procedure PaymentMode
EXEC Paymentamount @mode = 'cheque' , @amt = 10000;

CREATE TABLE updates  
(    
Id int IDENTITY,   
actions text   
); 

CREATE TRIGGER HomeNew   
ON Home  
FOR INSERT  
AS  
BEGIN  
  Declare @Id int  
  SELECT @Id = House_no from inserted  
  INSERT INTO updates  
  VALUES ('New House with Id = ' + CAST(@Id AS VARCHAR(10)) + ' is added at ' + CAST(Getdate() AS VARCHAR(22)))  
END 

Select * from updates

INSERT INTO Home VALUES(9982,'Duplex','Chennai',8,870000,'vacant','Deepak Aggarwal','Rashi Singh');












