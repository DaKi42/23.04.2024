use [Academy];
go

-- Вывести номера корпусов, если суммарный фонд финансирования расположенных в них кафедр превышает 100000.
SELECT Building
FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 100000;

-- Вывести названия групп 5-го курса кафедры “Software Development”, которые имеют более 10 пар в первую неделю.
SELECT Groups.Name
FROM Groups
JOIN Departments ON Groups.DepartmentId = Departments.Id
JOIN Faculties ON Departments.FacultyId = Faculties.Id
WHERE Faculties.Name = 'Software Development' 
AND Groups.Year = 5
AND EXISTS (
    SELECT 1
    FROM Lectures
    WHERE Lectures.GroupId = Groups.Id
    AND DATEPART(WEEKDAY, Lectures.Date) = 2 
    GROUP BY Lectures.GroupId
    HAVING COUNT(*) > 10
);

-- Вывести названия групп, имеющих рейтинг (средний рейтинг всех студентов группы) больше, чем рейтинг группы “D221”.
SELECT Groups.Name
FROM Groups
JOIN (
    SELECT AVG(Rating) AS AvgRating
    FROM Students
    GROUP BY GroupId
) AS GroupRatings ON Groups.Id = GroupRatings.GroupId
WHERE GroupRatings.AvgRating > (
    SELECT AVG(Rating)
    FROM Students
    WHERE GroupId = (
        SELECT Id
        FROM Groups
        WHERE Name = 'D221'
    )
);

-- Вывести фамилии и имена преподавателей, ставка которых выше средней ставки профессоров.
SELECT Name, Surname
FROM Teachers
WHERE Salary > (
    SELECT AVG(Salary)
    FROM Teachers
    WHERE IsProfessor = 1
);

-- Вывести названия групп, у которых больше одного куратора.
SELECT Groups.Name
FROM Groups
JOIN (
    SELECT GroupId
    FROM GroupsCurators
    GROUP BY GroupId
    HAVING COUNT(*) > 1
) AS GroupsWithMultipleCurators ON Groups.Id = GroupsWithMultipleCurators.GroupId;

-- Вывести названия групп, имеющих рейтинг (средний рейтинг всех студентов группы) меньше, чем минимальный рейтинг групп 5-го курса.
SELECT Groups.Name
FROM Groups
JOIN (
    SELECT MIN(AvgRating) AS MinRating
    FROM (
        SELECT AVG(Rating) AS AvgRating
        FROM Students
        JOIN Groups ON Students.GroupId = Groups.Id
        WHERE Groups.Year = 5
        GROUP BY Students.GroupId
    ) AS GroupRatings
) AS MinGroupRating ON AVG(Rating) < MinGroupRating.MinRating;

-- Вывести названия факультетов, суммарный фонд финансирования кафедр которых больше суммарного фонда финансирования кафедр факультета “Computer Science”.
SELECT Faculties.Name
FROM Faculties
JOIN (
    SELECT FacultyId, SUM(Financing) AS TotalFinancing
    FROM Departments
    GROUP BY FacultyId
) AS FacultyFinancing ON Faculties.Id = FacultyFinancing.FacultyId
JOIN (
    SELECT SUM(Financing) AS TotalFinancing
    FROM Departments
    JOIN Faculties ON Departments.FacultyId = Faculties.Id
    WHERE Faculties.Name = 'Computer Science'
) AS ComputerScienceFinancing ON FacultyFinancing.TotalFinancing > ComputerScienceFinancing.TotalFinancing;

-- Вывести названия дисциплин и полные имена преподавателей, читающих наибольшее количество лекций по ним.
SELECT Subjects.Name AS SubjectName, Teachers.Name AS TeacherName, Teachers.Surname AS TeacherSurname
FROM (
    SELECT LectureId, COUNT(*) AS LectureCount
    FROM GroupsLectures
    GROUP BY LectureId
) AS LectureCounts
JOIN Lectures ON Lectures.Id = LectureCounts.LectureId
JOIN Subjects ON Lectures.SubjectId = Subjects.Id
JOIN Teachers ON Lectures.TeacherId = Teachers.Id
WHERE LectureCounts.LectureCount = (
    SELECT MAX(LectureCount)
    FROM (
        SELECT LectureId, COUNT(*) AS LectureCount
        FROM GroupsLectures
        GROUP BY LectureId
    ) AS MaxLectureCount
);

--Вывести название дисциплины, по которому читается меньше всего лекций.
SELECT Subjects.Name
FROM (
    SELECT SubjectId, COUNT(*) AS LectureCount
    FROM Lectures
    GROUP BY SubjectId
) AS SubjectLectureCounts
JOIN Subjects ON SubjectLectureCounts.SubjectId = Subjects.Id
WHERE LectureCount = (
    SELECT MIN(LectureCount)
    FROM (
        SELECT SubjectId, COUNT(*) AS LectureCount
        FROM Lectures
        GROUP BY SubjectId
    ) AS MinLectureCount
);

--Вывести количество студентов и читаемых дисциплин накафедре “Software Development”.
SELECT COUNT(*) AS StudentCount, COUNT(DISTINCT SubjectId) AS UniqueSubjects
FROM Students
JOIN Groups ON Students.GroupId = Groups.Id
JOIN Departments ON Groups.DepartmentId = Departments.Id
JOIN Faculties ON Departments.FacultyId = Faculties.Id
WHERE Faculties.Name = 'Software Development';