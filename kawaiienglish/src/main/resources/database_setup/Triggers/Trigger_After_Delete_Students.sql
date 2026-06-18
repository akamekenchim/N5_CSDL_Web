drop trigger if exists trg_after_del_stu;
delimiter //

create trigger trg_after_del_stu
after delete on students
for each ROW
begin
    if old.class_id is not null then 
        update classes
        set classes.`No_of_Students` = classes.`No_of_Students` - 1
        where classes.`Class_ID` = old.class_id;
    end if;
end //

delimiter;