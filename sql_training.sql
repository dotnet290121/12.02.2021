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
-- find how many grades are duplicated
-- create players table (see on the right side of the screen)
-- insert few players with same name (also with different names)
-- find how many players names are duplicated

delete from grades2
where id >= 0;
select * from sp_populate_grades2(3, 30);
