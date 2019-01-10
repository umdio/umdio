/* This file should generally not be run, except from the correct Ruby code */

CREATE TABLE IF NOT EXISTS courses (
    id SERIAL PRIMARY KEY,
    course_id text,
    semester int,
    name text,
    dept_id text,
    department text,
    credits text,
    description text,
    relationships json,
    UNIQUE(course_id, semester)
);

CREATE TABLE IF NOT EXISTS courses_grading_method (
    id int REFERENCES courses(id),
    grading_method text,
    UNIQUE(id, grading_method)
);

CREATE TABLE IF NOT EXISTS courses_core (
    id int REFERENCES courses(id),
    core_code text,
    UNIQUE(id, core_code)
);

CREATE TABLE IF NOT EXISTS courses_gen_ed (
    id int REFERENCES courses(id),
    gen_ed_code text,
    UNIQUE(id, gen_ed_code)
);

DROP TABLE sections;
CREATE TABLE IF NOT EXISTS sections (
    id SERIAL PRIMARY KEY,
    section_id text,
    course_id text,
    semester int,
    number text,
    seats text,
    semester text,
    meetings json,
    open_seats text,
    waitlist text,
    UNIQUE(id, section_id, course_id)
);

CREATE TABLE IF NOT EXISTS section_professors (
    id SERIAL PRIMARY KEY,
    professor_id int REFERENCES professors(id),
    section int REFERENCES sections(id),
    UNIQUE(professor_id, section)
);

CREATE TABLE IF NOT EXISTS professors (
    id SERIAL PRIMARY KEY,
    name text,
);

PREPARE insert_courses (text, int, text, text, text, text, text, json) as
    INSERT INTO courses(
        id, course_id, semester, name, dept_id, department, credits, description, relationships
    ) VALUES (DEFAULT, $1, $2, $3, $4, $5, $6, $7, $8)
    ON CONFLICT (course_id, semester) DO UPDATE SET
        course_id = $1,
        semester = $2,
        name = $3,
        dept_id = $4,
        department = $5,
        credits = $6,
        description = $7,
        relationships = $8 RETURNING id;

PREPARE insert_courses_grading_method (int, text) as
    INSERT INTO courses_grading_method(id, grading_method) VALUES($1, $2)
    ON CONFLICT DO NOTHING;

PREPARE insert_courses_core (int, text) as
    INSERT INTO courses_core(id, core_code) VALUES($1, $2)
    ON CONFLICT DO NOTHING;

PREPARE insert_courses_gen_ed (int, text) as
    INSERT INTO courses_gen_ed(id, gen_ed_code) VALUES($1, $2)
    ON CONFLICT DO NOTHING;

PREPARE insert_section (text, text, int, text, text, text, json, text, text) as
    INSERT INTO sections (
      section_id, course_id, number, seats, semester, meetings, open_seats, waitlist
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    ON CONFLICT (section_id) DO UPDATE SET
        section_id = $1,
        course_id = $2,
        number = $3,
        instructors = $4,
        seats = $5,
        semester = $6,
        meetings = $7,
        open_seats = $8,
        waitlist = $9
    RETURNING id;