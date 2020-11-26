-- 176. 第二高的薪水
-- 考察点:
-- 1. ifnull(exp1,exp2) 防止出现null
-- 2. distinct 去重
-- 3. limit x offset y 跳过y个,读取x个
--    limit x,y 跳过x个,读取y个
--    注意区分上面两个
select ifnull(
    (select distinct salary 
    from Employee
    order by salary desc
    limit 1 offset 1
    ),null
) as SecondHighestSalary

-- 177. 第N高的薪水
-- 1. limit中不能使用表达式,所以需要在外面进行(N-1)
-- 2. set 对已经赋值的变量赋值.
-- 可以用set N=N-1或者 set N := N-1
-- 其区别在于使用set命令对用户变量进行赋值时，两种方式都可以使用；
-- 当使用select语句对用户变量进行赋值时，只能使用":="方式，因为在select语句中，"="号被看作是比较操作符
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
    set N = N-1;
  RETURN (
      # Write your MySQL query statement below.
      select ifnull(
          (select distinct Salary
          from Employee
          order by Salary desc
          limit 1 offset N),null
      ) as getNthHighestSalary
  );
END

-- 181. 超过经理收入的员工
-- 1.子查询效率很低 
-- 执行用时：777 ms, 在所有 MySQL 提交中击败了11.53%的用户
-- 内存消耗：0 B, 在所有 MySQL 提交中击败了100.00%的用户
select a.Name as Employee
from Employee a
where a.Salary > (
    select b.Salary
    from Employee b
    where a.ManagerId = b.Id
)

-- 方法二,内联结,笛卡尔积
-- 从两个表里使用 Select 语句可能会导致产生 笛卡尔乘积 。在这种情况下，输出会产生 4*4=16 个记录。
-- 这两种方法其实是一样的.
-- on比where更快,因为
-- 1. on条件是在生成临时表时使用的条件，它不管on中的条件是否为真，都会返回左边表中的记录。
-- 2. where条件是在临时表生成好后，再对临时表进行过滤的条件
select a.Name as Employee
from Employee as a,Employee as b
where a.Salary > b.Salary and b.Id = a.ManagerId

select a.Name as Employee
from Employee as a
join Employee as b
where a.Salary > b.Salary and b.Id = a.ManagerId