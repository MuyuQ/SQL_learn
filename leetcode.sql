


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

——————————————————————————————————————


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

——————————————————————————————————————


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

——————————————————————————————————————


-- 182. 查找重复的电子邮箱
-- count()函数的使用
-- group by的使用方法. 指定字段内容相同的合并为一条,这个过程中存在一个中间临时表.
-- 具体过程可以看这篇文章
-- https://blog.csdn.net/qq_41059320/article/details/89281125
select Email
from(
    select Email,count(Email)as num
    from Person
    group by Email
)as tmp
where num > 1

-- 方法二,因为where无法和group by一起使用.
-- 所以可以使用having count组合使用
select Email
from Person
group by Email
having count(Email)>1

——————————————————————————————————————

-- 183. 从不订购的客户
-- 使用临时表查询
select Name as Customers
from (select c.Name as Name,o.Id as o_Id
    from Customers as c 
    left join Orders as o
    on c.id = o.CustomerId
)as tmp
where o_Id is null
-- 直接使用左联结进行查询. 之所以一开始没有使用,是对o.Id理解不足
select c.Name as Customers
from Customers as c 
left join Orders as o
on c.id = o.CustomerId
where o.Id is null

——————————————————————————————————————


-- 627. 变更性别
-- if语句. if(exp1,true_vale,false_vale)
update salary
set sex = if(sex='m','f','m')
-- case when语句
update salary
set sex = case sex
    when 'm' then 'f'
    else 'm'
    end

——————————————————————————————————————


-- 595.大的国家
-- 直接使用where or
-- 缺点是开销太大. 如果是单列的话,or并没有问题.
-- 但如果or涉及到多列查询,每次select只会选取一个index,比如说选取area后,population会进行一次全表扫描
-- 导致开销飙升
select name,population,area
from world
where area>3000000 or population>25000000

-- 为了解决开销太大的问题,可以使用union.
-- union可以合并多个查询结果.
-- 同时注意区分union和union all的区别,前者默认去重,后者暂时全部结果(避免因为重名导致的数据丢失)
select name,population,area
from world
where area>3000000
union
select name,population,area
from world
where population>25000000

——————————————————————————————————————


