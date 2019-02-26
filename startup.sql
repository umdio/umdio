CREATE OR REPLACE VIEW professor_view AS SELECT
    professors.name as name,
    sections.semester as semester,
    array_agg(DISTINCT courses.course_id) as courses,
    array_agg(DISTINCT courses.dept_id) as departments
FROM professors
    JOIN section_professors ON professors.id=section_professors.professor_id
    JOIN sections ON section_professors.section = sections.id
    JOIN courses ON sections.course_id = courses.course_id AND sections.semester = courses.semester GROUP BY professors.name, sections.semester