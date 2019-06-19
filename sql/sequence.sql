/* 多行注释 */
-- 单行注释



/* PostgreSQL 序列（SEQUENCE）*/
-- 参考：https://www.cnblogs.com/mchina/archive/2013/04/10/3012493.html



/* 一、简介 */
--	序列对象（也叫序列生成器）就是用CREATE SEQUENCE 创建的 "特殊的单行表" 。一个序列对象通常用于: 为 行 或者 表 生成唯一的标识符。



/* 二、创建序列 */
--	方法一：直接在表中指定字段类型为 serial 类型。
create table table_sequence (id serial, name text);

--	NOTICE:  CREATE TABLE will create implicit sequence "table_sequence_id_seq" for serial column "table_sequence.id" 
--           会因为 id（serial类型）字段，而隐式创建序列 "table_sequence_id_seq"



--	方法二：先创建序列，然后在新建的表中 指定列的属性中 指定序列 就可以了，且该列必须需int 类型。
create sequence table_sequence_2_id_seq increment by 1 minvalue 1 no maxvalue start with 1; 
create table table_sequence_2 (id int4 not null default nextval('table_sequence_2_id_seq'), name text);



/* 三、查看序列 */

select * from table_sequence_2_id_seq;



/* 四、序列应用 */

--	4.1 在 INSERT 命令中使用序列
insert into table_sequence values (nextval('table_sequence_id_seq'), 'David');      
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Sandy');

select * from table_sequence;




--	4.2 数据迁移后更新序列
truncate table_sequence;	-- 截断（删除表里所有的数据）

insert into table_sequence values (nextval('table_sequence_id_seq'), 'Sandy');
insert into table_sequence values (nextval('table_sequence_id_seq'), 'David');
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Eagle');
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Miles');
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Simon');
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Rock'); 
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Peter');
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Sally');
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Nicole');
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Monica');
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Renee'); 

select * from table_sequence;	-- 发现 id 是从上一次的id值往下加

copy table_sequence to '/Users/admin/Desktop/table_sequence.sql';	-- 将表里的数据拷贝到文件里

truncate table_sequence;	-- 再次清空表数据

alter sequence table_sequence_id_seq restart with 100;
select * from table_sequence_id_seq;	-- 发现现在序列初始值从 100 开始；last_value = 100

select currval('table_sequence_id_seq');	-- 14 截断前 id 的最大值

select nextval('table_sequence_id_seq');	-- 100
select nextval('table_sequence_id_seq');	-- 101
select nextval('table_sequence_id_seq');	-- 102

begin;
copy table_sequence from '/Users/admin/Desktop/table_sequence.sql';		-- 拷贝数据
select * from table_sequence;

select setval('table_sequence_id_seq', max(id)) from table_sequence;	-- 返回 table_sequence 表中序列的最大值；14
end;	-- COMMIT

insert into table_sequence values (nextval('table_sequence_id_seq'), 'Flash');	-- 15
select * from table_sequence;

select nextval('table_sequence_id_seq');	-- 16
select nextval('table_sequence_id_seq');	-- 17
select nextval('table_sequence_id_seq');	-- 18

insert into table_sequence values (nextval('table_sequence_id_seq'), 'Flasher');	-- 19
select * from table_sequence;






/*
五、序列函数

序列函数：为我们从序列对象中获取最新的 序列值，提供了简单和并发读取安全的方法。

--	函数					返回类型		描述		(regclass 为序列名)

--	nextval(regclass)	bigint		递增序列对象到它的下一个数值并且返回该值。
--	这个动作是自动完成的。即使多个会话并发运行nextval，每个进程也会安全地收到一个唯一的序列值。


--	currval(regclass)	bigint		在当前会话中返回最近一次 nextval 抓到的该序列的数值。
--	(如果在本会话中从未在该序列上调用过 nextval，那么会报告一个错误。)
--	请注意因为此函数返回一个会话范围的数值，而且也能给出一个可预计的结果，因此可以用于判断其它会话是否执行过 nextval。


--	lastval()			bigint		返回当前会话里最近一次 nextval 返回的数值。
--	这个函数等效于currval，只是它不用序列名为参数，它抓取当前会话里面最近一次 nextval 使用的序列。
--	如果当前会话还没有调用过 nextval，那么调用 lastval 将会报错。


--	setval(regclass, bigint)	bigint		重置序列对象的计数器数值。
--	设置序列的 last_value 字段为指定数值 并且 将其 is_called 字段设置为 true，表示下一次 nextval 将在返回数值之前递增该序列。


--	setval(regclass, bigint, boolean)	bigint		重置序列对象的计数器数值。
--	功能等同于上面的setval函数，只是 is_called 可以设置为 true 或 false。
--	如果将其设置为 false，那么下一次 nextval 将返回该数值，随后的nextval才开始递增该序列。
 
*/

select * from table_sequence_id_seq;


select currval('table_sequence_id_seq');	-- current value	id=19

select lastval();	-- last value	id=19

select setval('table_sequence_id_seq', 120);	-- set value
select lastval();	-- last value	id=120, is_called=true

select setval('table_sequence_id_seq', 130, false);	-- set value
select lastval();	-- last value	id=120, is_called=false  这里id还是 120
select nextval('table_sequence_id_seq');	-- id=130 这里id就变成 130



-- 5.3 重置序列

-- 方法一.a
truncate table_sequence;
select setval('table_sequence_id_seq', 1);
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Sandy');                  
insert into table_sequence values (nextval('table_sequence_id_seq'), 'David');     
select * from table_sequence;
/*
 id | name  
----+-------
  2 | Sandy
  3 | David
*/

select currval('table_sequence_id_seq');	-- 3
select nextval('table_sequence_id_seq');	-- 4


-- 方法一.b
truncate table_sequence;
select setval('table_sequence_id_seq', 1, false);
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Sandy');
insert into table_sequence values (nextval('table_sequence_id_seq'), 'David');
select * from table_sequence;
/*
 id | name  
----+-------
  1 | Sandy
  2 | David
(2 rows)
*/



-- 方法二：修改序列


truncate table_sequence;
alter sequence table_sequence_id_seq restart with 1;	-- 最小从1开始（不能设为0）
insert into table_sequence values (nextval('table_sequence_id_seq'), 'David');
insert into table_sequence values (nextval('table_sequence_id_seq'), 'Sandy');
select * from table_sequence;
/*
 id | name  
----+-------
  1 | David
  2 | Sandy
(2 rows)
*/
select nextval('table_sequence_id_seq');	-- 3



/* 六、删除序列 */
--	语法：DROP SEQUENCE [ IF EXISTS ] name [, ...] [ CASCADE | RESTRICT ]
--	当有 表 的字段使用到该序列时，不能直接删除，应先删除该表 or 该表用到该序列的字段。
--	对于序列是由建表时指定serial 创建的，删除该表的同时，对应的序列也会被删除。

drop table table_sequence_2;
drop sequence table_sequence_2_id_seq;















