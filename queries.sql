/* 1.	Can a user appear in the activity table more than once? */
Select uid, COUNT(uid) AS count_user
FROM activity
GROUP BY uid
Having COUNT(uid) > 1
  
/* 2.	What type of join should we use to join the users table to the activity table?*/
SELECT ac.uid, ac.dt, ac.device, ac.spent, us.country,  us.gender
FROM activity AS ac
INNER JOIN users AS us
ON us.id = ac.uid
  
/* 3.	What are the start and end dates of the experiment?*/
SELECT MIN(join_dt), MAX(join_dt)
FROM groups
  
/* 4.	How many total users were in the experiment?*/
SELECT COUNT(DISTINCT(uid)) AS toal_users
FROM groups
  
/* 5.	How many users were in the control and treatment groups?*/
SELECT groups.group, COUNT(DISTINCT(uid)) AS toal_users
FROM groups
GROUP BY groups.group  
  
/* 6.	What was the conversion rate of all users?*/
WITH temp_tab AS(
SELECT COUNT(DISTINCT(us.id)) AS total_users,
COUNT(DISTINCT(ac.uid)) AS converted,
(COUNT(DISTINCT(us.id))
COUNT(DISTINCT(ac.uid))) AS Not_converted
FROM users AS us
FULL JOIN activity AS ac ON ac.uid = us.id)
SELECT converted, Not_converted,
(CAST(converted AS FLOAT) /CAST(total_users As FLOAT))*100.0 AS convertion_rate,
(CAST(Not_converted AS FLOAT) /CAST(total_users As FLOAT))*100.0 AS
not_convert ion_rate
FROM temp_tab
  
/* 7.	What is the user conversion rate for the control and treatment groups?*/
WITH temp_tab AS(
SELECT gr.group AS group_name,COUNT(DISTINCT(us.id)) AS total_users,
COU NT(DISTINCT(ac.uid)) AS converted,
(COUNT(DISTINCT(us.id))
COUNT(DISTINCT(ac.uid))) AS Not_converted
FROM users AS us
FULL JOIN activity AS ac ON ac.uid = us.id
FULL join groups AS gr on gr.uid = us.id
GROUP BY gr.group)
SELECT group_name,converted, Not_converted, (CAST(converted AS FLOAT)
/CAST(total_users As FLOAT))*100.0 AS convertion_
(CAST(Not_converted AS FLOAT) /CAST(total_users As FLOAT))*100.0 AS
not_convertion_rate
FROM temp_tab
GROUP BY total_users,group_name, converted, Not_converted
  
/* 8.	What is the average amount spent per user for the control and treatment groups, including users who did not convert? */
SELECT gr.group, SUM(ac.spent)/COUNT(DISTINCT(us.id)) AS spent_per_user
FROM users AS us
FULL JOIN activity AS ac ON ac.uid = us.id
FULL join groups AS gr on gr.uid = us.id
GROUP BY gr.group


/*EXTRACTION fFOR HYPOTHESIS TESTING*/
SELECT us.id, us.country, us.gender, ac.device, gr.group, SUM(COALESCE(ac.spent,0)) AS spent,
CASE WHEN SUM(ac.spent) = 0 OR SUM(ac.spent) IS NULL THEN 'Not converted'
WHEN SUM(ac.spent) > 0 THEN 'Converted'
ELSE 'Error'
END AS user_convertion
FROM users as us
LEFT JOIN activity as ac
ON us.id = ac.uid
FULL JOIN groups as gr
ON us.id = gr.uid
GROUP BY us.id, ac.device, gr.group
