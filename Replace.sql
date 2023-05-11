/*
SQL - Replace

Simple SQL code to replace items in SQL.

*/

SELECT column
  ,REPLACE(column, 'A', '_') as replace_A_with_underscore
  ,REPLACE(column, 'B', ' ') as replace_B_with_space
  ,REPLACE(column, 'C', '*') as replace_C_with_star
FROM #Table
  
