const express = require('express');
const app = new express();
const _ = require('underscore');
const pool = require('./db');
const PORT = process.env.PORT || 5000;

app.use(express.json());

app.get('/getEmployeeByID/:id', async (req, res) => {
     try {
          console.log('req: ', req.params);

          let result = await pool.query(`select emp.employeeid,emp.firstname,emp.lastname,emp.emailid,emp.organizationname,emp.departmentid 
            from employee emp join department dep on emp.departmentid = dep.departmentid where emp.employeeid = ($1) and emp.active = true; `, [req.params.id]);

          if (_.isEmpty(result)) {
               return res.json({
                    success: false,
                    message: 'User does not exist.',
                    data: {}
               }).status(400)
          }

          return res.json({
               success: true,
               message: 'User fetch successfully',
               data: result.rows,
          })
     } catch (err) {
          console.log('err: ', err);
          return res.json({
               success: false,
               message: 'Something went wrong.',
               data: {}
          }).status(400)
     }
});

app.get('/getEmployeeData/:DateOfJoining/:DepName', async (req, res) => {
     try {
          console.log('DateOfJoining: ', req.params.DateOfJoining);
          console.log('DepName: ', req.params.DepName);

          let {DateOfJoining, DepName} = req.params

          let result = await pool.query(`select * from getEmployeeData(($1),($2))`, [DateOfJoining, DepName]);

          if (_.isEmpty(result)) {
               return res.json({
                    success: false,
                    message: 'User does not exist.',
                    data: {}
               }).status(400)
          }

          return res.json({
               success: true,
               message: 'User fetch successfully',
               data: result.rows,
          })
     } catch (err) {
          console.log('err: ', err);
          return res.json({
               success: false,
               message: 'Something went wrong.',
               data: {}
          }).status(400)
     }
});

app.listen(PORT, () => {
     console.log(`Listening on port ${PORT}`)
})