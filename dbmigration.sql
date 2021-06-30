
create database employees_data;

CREATE TABLE IF NOT EXISTS employee (
    EmployeeId serial PRIMARY KEY NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    EmailId VARCHAR(100) NOT NULL UNIQUE,
    OrganizationName VARCHAR(100) NOT null,
    DepartmentId INT NOT NULL,
    DateOfJoin DATE DEFAULT CURRENT_DATE,
    CreateDate TIMESTAMP NOT NULL,
    UpdateDate TIMESTAMP NOT NULL,
    Active Boolean NOT NULL
)

CREATE TABLE IF NOT EXISTS department (
    DepartmentId serial PRIMARY KEY NOT NULL,
    DepartmentName VARCHAR(200) NOT NULL UNIQUE,
    CreateDate TIMESTAMP NOT NULL, 
    UpdateDate TIMESTAMP NOT NULL,
    Active Boolean NOT NULL
)

CREATE TABLE IF NOT EXISTS emp_dept_count (
    CountId serial PRIMARY KEY NOT NULL,
    DepartmentId INT NOT NULL,
    EmployeeCount INT NOT NULL,
    CreateDate TIMESTAMP NOT NULL, 
    UpdateDate TIMESTAMP NOT NULL,
    Active Boolean NOT null,
    FOREIGN KEY (DepartmentId)
      REFERENCES department (DepartmentId)
)

ALTER TABLE employee ADD CONSTRAINT deptfk FOREIGN KEY (DepartmentId) REFERENCES Department (DepartmentId);


CREATE OR REPLACE FUNCTION emp_count() RETURNS TRIGGER AS $emp_count$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            -- check if the departmentid exists or not in emp_dept_count table
            IF ((SELECT countid from emp_dept_count where departmentid = NEW.departmentid) > 0) THEN
               update emp_dept_count set employeecount = ((SELECT employeecount from emp_dept_count where departmentid = NEW.departmentid) + 1) where departmentid = NEW.departmentid;
               RETURN NEW;
            ELSE 
               insert into emp_dept_count(DepartmentId,EmployeeCount,CreateDate,UpdateDate,Active) values(NEW.departmentid, 1, Now(), Now(), true);
               RETURN NEW;
            END IF;
        END IF;
        RETURN NULL;
    END;
$emp_count$ LANGUAGE plpgsql;


CREATE TRIGGER emp_count AFTER INSERT ON employee FOR EACH ROW EXECUTE PROCEDURE emp_count();

   
create or replace function getEmployeeData(DOJ date, DN VARCHAR(200))
  returns table (document json)
 as
 $body$
   select row_to_json(t) from (
    	select emp.employeeid,emp.firstname,emp.lastname,emp.emailid,emp.organizationname,dep.departmentname,emp.dateofjoin
    	from employee emp 
  	    join department dep 
  	    on emp.departmentid = dep.departmentid
	    where  emp.DateOfJoin = DOJ and dep.departmentname = DN
   )t
 $body$
 language sql;


select * from getEmployeeData('2021-06-30','Technology')

select * from employee

select * from department 

select * from emp_dept_count



INSERT INTO employee (firstname,lastname,emailid,organizationname,departmentid,DateOfJoin,createdate,updatedate,active) VALUES 
('Shoeb','Patel','shoebpatel2106@gmail.ii','Servify',1,now(),now(),now(),true),
('Shoeb','Patel','shoeb.patel2106@gmail.com','Servify',1,now(),now(),now(),true),
('Shoeb','Patel','shoeb.patel@gmail.com','Servify',8,now(),now(),now(),true),
('Shoeb','Patel','shoeb.p@gmail.com','Servify',8,now(),now(),now(),true),
('Shoeb','Patel','shoebp@gmail.com','Servify',8,now(),now(),now(),true),
('Shoeb','Patel','shoebp@gmail.in','Servify',2,now(),now(),now(),true),
('Shoeb','Patel','shoebp@servify.in','Servify',3,now(),now(),now(),true),
('Shoeb','Patel','shoeb.p@servify.in','Servify',3,now(),now(),now(),true),
('Shoeb','Patel','shoeb.p@servify.com','Servify',2,now(),now(),now(),true),
('Shoeb','Patel','shoeb.p@servify.org','Servify',2,now(),now(),now(),true);

INSERT INTO department (departmentname,createdate,updatedate,active) VALUES 
('Technology',now(),now(),true),
('Accounts',now(),now(),true),
('Sales',now(),now(),true),
('IT',now(),now(),true),
('Human Resource',now(),now(),true),
('Admin',now(),now(),true),
('staff',now(),now(),true),
('others',now(),now(),true);

