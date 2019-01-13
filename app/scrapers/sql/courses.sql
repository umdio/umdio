/* Drops tables (for debug purposes)
 * TODO: Remove before release
 */
DROP TABLE IF EXISTS courses_grading_method;
DROP TABLE IF EXISTS courses_gen_ed;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS section_professors;
DROP TABLE IF EXISTS professors;
DROP TABLE IF EXISTS sections;

CREATE TABLE IF NOT EXISTS courses (
    id SERIAL PRIMARY KEY,
    course_id text NOT NULL,
    semester int NOT NULL,
    name text NOT NULL,
    dept_id text NOT NULL,
    department text NOT NULL,
    credits text NOT NULL,
    description text,
    relationships jsonb,
    UNIQUE(course_id, semester)
);
CREATE INDEX on courses(semester);

CREATE TABLE IF NOT EXISTS courses_grading_method (
    id int REFERENCES courses(id),
    grading_method text,
    UNIQUE(id, grading_method)
);

CREATE TABLE IF NOT EXISTS courses_gen_ed (
    id int REFERENCES courses(id),
    gen_ed_code text,
    UNIQUE(id, gen_ed_code)
);

CREATE TABLE IF NOT EXISTS sections (
    id SERIAL PRIMARY KEY,
    section_id text NOT NULL,
    course_id text NOT NULL,
    semester int NOT NULL,
    number text NOT NULL,
    seats text NOT NULL,
    meetings jsonb NOT NULL,
    open_seats text NOT NULL,
    waitlist text,
    UNIQUE(id, section_id, course_id)
);
CREATE INDEX on sections(semester);

CREATE TABLE IF NOT EXISTS professors (
    id SERIAL PRIMARY KEY,
    name text NOT NULL
);

CREATE TABLE IF NOT EXISTS section_professors (
    id SERIAL PRIMARY KEY,
    professor_id int REFERENCES professors(id),
    section int REFERENCES sections(id),
    UNIQUE(professor_id, section)
);

PREPARE insert_courses (text, int, text, text, text, text, text, jsonb) as
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
        relationships = $8;

PREPARE insert_courses_grading_method (int, text) as
    INSERT INTO courses_grading_method(id, grading_method) VALUES($1, $2)
    ON CONFLICT DO NOTHING;

PREPARE insert_courses_gen_ed (int, text) as
    INSERT INTO courses_gen_ed(id, gen_ed_code) VALUES($1, $2)
    ON CONFLICT DO NOTHING;

PREPARE insert_section (text, text, int, text, text, jsonb, text, text) as
    INSERT INTO sections (
      section_id, course_id, semester, number, seats, meetings, open_seats, waitlist
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    ON CONFLICT (section_id) DO UPDATE SET
        section_id = $1,
        course_id = $2,
        semester = $3,
        number = $4,
        seats = $5,
        meetings = $6,
        open_seats = $7,
        waitlist = $8
    RETURNING id;