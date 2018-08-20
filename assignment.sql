
-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
SET SCHEMA 'chinook';
SELECT * FROM employee;
-- Task – Select all records from the Employee table where last name is King.
SELECT * FROM employee WHERE lastname = 'King';
-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM employee WHERE firstname = 'Andrew' and reportsto IS NULL;
-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM album ORDER BY title DESC;
-- Task – Select first name from Customer and sort result set in ascending order by city
SELECT firstname FROM customer ORDER BY city ASC;
-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
INSERT INTO genre (genreid, name) VALUES (26, 'Dubstep');
INSERT INTO genre (genreid, name) VALUES (27, 'Artcore');
-- Task – Insert two new records into Employee table
INSERT INTO employee (employeeid, lastname, firstname,title) VALUES (9, 'Drew', 'K', 'Receptionist');
INSERT INTO employee (employeeid, lastname, firstname,title) VALUES (10, 'Freeman', 'Morgan', 'Janitor');
-- Task – Insert two new records into Customer table
INSERT INTO customer (customerid, firstname, lastname, company, email) VALUES (60, 'Xerxes', 'Soul', 'Staggering Gains', 'bloop');
INSERT INTO customer (customerid, firstname, lastname, company, email) VALUES (61, 'Finextian', 'Simply', 'Staggering Gains', 'blep');
-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
​UPDATE customer SET firstname = 'Robert', lastname = 'Walter' WHERE customerid = 32;
-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE artist SET name = 'CCR' WHERE artistid = 76;

-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
SELECT * FROM invoice WHERE billingaddress like 'T%';
-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
SELECT * FROM invoice WHERE total between 15 AND 50;
-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM employee WHERE hiredate between '2003-06-1' AND '2004-03-1';
-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
DELETE * FROM invoiceline 
	WHERE invoiceid IN (
		SELECT invoiceid FROM invoice
			WHERE customerid = (
				SELECT customerid FROM customer
					where customerid = 32));

-- SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
CREATE OR REPLACE FUNCTION ct()
RETURNS TIME AS $$
	BEGIN
		RETURN CURRENT_TIME;
	END;
$$ LANGUAGE plpgsql;

SELECT ct();
-- Task – create a function that returns the length of a mediatype from the mediatype table
CREATE OR REPLACE FUNCTION media_length(name VARCHAR)
RETURNS INTEGER AS $$
	BEGIN
		RETURN LENGTH(name);
	END;
$$ LANGUAGE plpgsql;

SELECT media_length(name) from mediatype;
-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
DROP FUNCTION av();

CREATE OR REPLACE FUNCTION av()
RETURNS NUMERIC AS $$
	BEGIN
		RETURN AVG(total) from invoice;
	END;
$$ LANGUAGE plpgsql;

SELECT av();
-- Task – Create a function that returns the most expensive track
CREATE OR REPLACE FUNCTION expensive_track()
RETURNS VARCHAR AS $$
	BEGIN
		RETURN MAX(unitprice) from track;
	END;
$$ LANGUAGE plpgsql;

SELECT expensive_track();
-- 3.3 User Defined Scalar Functions
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION av_invoice_line()
RETURNS NUMERIC AS $$
	BEGIN
		RETURN AVG(unitprice) from invoiceline;
	END;
$$ LANGUAGE plpgsql;

SELECT av_invoice_line();
-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
CREATE OR REPLACE FUNCTION younglings()
RETURNS VARCHAR AS $$
DECLARE
	cur refcursor;
BEGIN
	OPEN cur for SELECT * FROM employee WHERE birthdate > '1968-12-31';
		RETURN cur;
END;
$$ LANGUAGE plpgsql;

SELECT younglings();
FETCH ALL IN "<unnamed portal 1>";
-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.
CREATE OR REPLACE FUNCTION employee_name()
RETURNS VARCHAR AS $$
DECLARE
	cur refcursor;
BEGIN
	OPEN cur for SELECT firstname, lastname FROM employee;
		RETURN cur;
END;
$$ LANGUAGE plpgsql;

SELECT employee_name();
FETCH ALL IN "<unnamed portal 1>";
-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.
CREATE OR REPLACE FUNCTION employee_update(u_id INTEGER, home VARCHAR(70), town VARCHAR(40), st VARCHAR(40),
	cnt VARCHAR(40), post VARCHAR(10), pho VARCHAR(24), fx VARCHAR(24), mail VARCHAR(60))
RETURNS void AS $$
BEGIN
	UPDATE employee SET address = home, city = town, state = st, country = cnt, 
		postalcode = post, phone = pho, fax = fx, email = mail WHERE employeeid = u_id;
END;
$$ LANGUAGE plpgsql;	
-- Task – Create a stored procedure that returns the managers of an employee.
CREATE OR REPLACE FUNCTION employee_manager(uid INTEGER)
RETURNS refcursor AS $$
DECLARE cur refcursor;
BEGIN

	OPEN cur for SELECT firstname, lastname, title FROM employee 
		   WHERE employeeid = (SELECT reportsto FROM employee
								WHERE employeeid = uid);
	RETURN cur;

END;
$$ LANGUAGE plpgsql;

SELECT employee_manager(4);
FETCH ALL IN "<unnamed portal 1>";
-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
CREATE OR REPLACE FUNCTION find_customer(cid INTEGER)
RETURNS refcursor AS $$
DECLARE cur refcursor;
BEGIN
	OPEN cur for  SELECT firstname, lastname, company FROM customer
		WHERE customerid = cid;
	RETURN cur;
END
$$ LANGUAGE plpgsql;

SELECT find_customer(5);
FETCH ALL IN "<unnamed portal 1>";
-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
CREATE OR REPLACE FUNCTION invoice_remove(iv_id INTEGER)
RETURNS void AS $space$
BEGIN
	DELETE FROM invoiceline 
	WHERE invoiceid IN (
		SELECT invoiceid FROM invoice
			WHERE invoiceid = iv_id);
END;
$space$ LANGUAGE plpgsql;

SELECT invoice_remove(1);
-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
CREATE OR REPLACE FUNCTION new_customer
(ugh INTEGER, fn VARCHAR (30) ,lan varchar(30), cm varchar(30), em VARCHAR(30))
RETURNS void AS $space$
BEGIN
	INSERT INTO customerVALUES (ugh, fn, lan, cm, em);
END;
$space$ LANGUAGE plpgsql;

-- to run
SELECT new_customer(471,'sheep', 'tamer', '.co', 'forever');
SELECT * FROM customer;
-- 6.0 Triggers
-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
-- 6.1 AFTER/FOR
-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
CREATE TRIGGER employee_update
AFTER INSERT ON employee
EXECUTE PROCEDURE suppress_redundant_updates_trigger();
-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table
CREATE TRIGGER new_album
AFTER UPDATE ON album
EXECUTE PROCEDURE suppress_redundant_updates_trigger();
-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
CREATE TRIGGER another_on_bites_the_dust
AFTER DELETE ON comstumer
EXECUTE PROCEDURE suppress_redundant_updates_trigger();
-- 6.2 INSTEAD OF
-- Task – Create an instead of trigger that restricts the deletion of any invoice that is priced over 50 dollars.
CREATE TRIGGER stop_delete
BEFORE DELETE ON invoice
EXECUTE PROCEDURE suppress_redundant_updates_trigger();
-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
SELECT firstname, lastname, invoiceid FROM customer
	INNER JOIN invoice ON (customer.customerid = invoice.customerid);
-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
SELECT customer.customerid, firstname, lastname, invoiceid, total FROM customer
	FULL JOIN invoice ON (customer.customerid = invoice.customerid);
-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
SELECT name, title FROM album
	RIGHT JOIN ARTIST ON (album.artistid = artist.artistid);
-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
SELECT * FROM artist
	CROSS JOIN album ORDER BY name;
-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.
SELECT A.firstname AS emp1, B.firstname AS mang
	FROM employee A, employee B WHERE A.reportsto = B.employeeid;