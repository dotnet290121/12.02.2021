drop function sp_populate_grades2;
CREATE OR REPLACE FUNCTION sp_populate_grades2(num_classes int, num_students_max int) returns integer
language plpgsql AS
    $$
        declare
            total int := 1;
            num_for_class int := 0;
        begin
            -- num_students = random number between 5 and num_students_max
            FOR i IN 1..num_classes
            loop
                -- for (int i = 1; i <= num_classes; i++)
                num_for_class := random() * num_students_max;
                FOR j IN 1..num_for_class
                loop
                    INSERT INTO grades2(class_id, student_id, grade)
                        values(i, total, random() * 99 + 1);
                    total := total + 1;
                end loop;
            end loop;
            -- return (random() * (_max-1) + 1);
            return total - 1;
        end;
    $$;

select * from
(select *,
       row_number() over (partition by class_id order by grade desc) row_num
       from grades ) c
    where c.row_num between 1 AND 5;

-- find the class where the 2nd max grade is the lowest
select * from -- select grade from ...
(select *,
       row_number() over (partition by class_id order by grade desc) row_num
       from grades ) c
    where c.row_num = 2
order by c.grade
limit 1;

-- find how many grades are duplicated
select * from -- select grade from ...
(select *,
       row_number() over (partition by grade order by grade desc) row_num
       from grades ) c
    where c.row_num = 2;

-- create players table (see on the right side of the screen)
insert into players(name) values ('danny');
insert into players(name) values ('moshe');
insert into players(name) values ('danny');
insert into players(name) values ('danny');
insert into players(name) values ('pazit');
select name from
(select *,
       row_number() over (partition by name order by name) row_num
       from players ) c
    where c.row_num   = 2;
-- insert few players with same name (also with different names)
-- find how many players names are duplicated
select count(*) from
(select *,
       row_number() over (partition by name order by name) row_num
       from players ) c
    where c.row_num   = 2;

select class_id, avg(grade), count(student_id) from grades2
group by class_id;

select *, (grade - class_avg) diff_avg from (
select id, class_id, student_id, grade,
       avg(grade) over (partition by class_id) class_avg,
       count(*) over (partition by class_id) total_in_class,
       row_number() over (partition by class_id order by grade desc) rank_in_class
       from grades2 ) c
       
-- display min grade in each row
-- display diff between current grade and min grade in each row
-- how many students passed the average grade? [new query]

create table routes
(
    id       bigserial not null
        constraint routes_pk
            primary key,
    train_id bigint    not null
        constraint routes_trains_id_fk
            references trains,
    route_id bigint    not null,
    date     date      not null
);

create table trains
(
    id                  bigserial         not null
        constraint trains_pk
            primary key,
    model               varchar           not null,
    max_speed           integer default 0 not null,
    first_class_places  integer default 0 not null,
    second_class_places integer default 0 not null
);

insert into trains(model, max_speed, first_class_places, second_class_places)
values ('InterCity 100', 160, 30, 230);
insert into trains(model, max_speed, first_class_places, second_class_places)
values ('InterCity 100', 160, 40, 210);
insert into trains(model, max_speed, first_class_places, second_class_places)
values ('InterCity 125', 200, 40, 180);
insert into trains(model, max_speed, first_class_places, second_class_places)
values ('Pendolino 390', 224, 45, 150);
insert into trains(model, max_speed, first_class_places, second_class_places)
values ('Pendolino ETR310', 224, 50, 250);
insert into trains(model, max_speed, first_class_places, second_class_places)
values ('Pendolino 390', 224, 60, 250);

select * from trains;
update trains
set max_speed = 225
where max_speed = 224;

insert into routes(train_id, route_id, date)
values (1, 1, '2021-02-11');
insert into routes(train_id, route_id, date)
values (1, 2, '2021-02-11');
insert into routes(train_id, route_id, date)
values (1, 3, '2021-02-11');
insert into routes(train_id, route_id, date)
values (1, 4, '2021-02-11');
insert into routes(train_id, route_id, date)
values (2, 2, '2021-02-11');
insert into routes(train_id, route_id, date)
values (2, 3, '2021-02-11');
insert into routes(train_id, route_id, date)
values (2, 4, '2021-02-11');
insert into routes(train_id, route_id, date)
values (2, 5, '2021-02-11');
insert into routes(train_id, route_id, date)
values (3, 3, '2021-02-11');
insert into routes(train_id, route_id, date)
values (3, 5, '2021-02-11');
values (4, 2, '2021-02-11');
insert into routes(train_id, route_id, date)
values (4, 4, '2021-02-11');
insert into routes(train_id, route_id, date)
values (4, 6, '2021-02-11');
insert into routes(train_id, route_id, date)
values (4, 7, '2021-02-11');

select *,
       count(*) over (partition by route_id order by route_id) total_on_same_route,
       max(max_speed) over (partition by route_id  order by route_id) max_speed_in_route
       from routes
join trains t on routes.train_id = t.id
order by route_id;


