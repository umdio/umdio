CREATE TABLE IF NOT EXISTS courses (
    id SERIAL PRIMARY KEY,
    course_id text NOT NULL,
    semester int NOT NULL,
    name text NOT NULL,
    dept_id text NOT NULL,
    department text NOT NULL,
    credits text NOT NULL,
    description text,
    grading_method text[],
    gen_ed text[],
    core text[],
    relationships jsonb,
    UNIQUE(course_id, semester)
);
CREATE INDEX on courses(semester);

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
    instructors text[],
    UNIQUE(section_id, course_id, semester)
);
CREATE INDEX on sections(semester);

CREATE TABLE IF NOT EXISTS professors (
    id SERIAL PRIMARY KEY,
    name text NOT NULL,
    UNIQUE(name)
);

CREATE TABLE IF NOT EXISTS section_professors (
    id SERIAL PRIMARY KEY,
    professor_id int REFERENCES professors(id) NOT NULL,
    section int REFERENCES sections(id) NOT NULL,
    UNIQUE(professor_id, section)
);

PREPARE insert_courses (text, int, text, text, text, text, text, text[], text[], text[], jsonb) as
    INSERT INTO courses(
        id, course_id, semester, name, dept_id, department, credits, description, grading_method, gen_ed, core, relationships
    ) VALUES (DEFAULT, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    ON CONFLICT (course_id, semester) DO UPDATE SET
        course_id = $1,
        semester = $2,
        name = $3,
        dept_id = $4,
        department = $5,
        credits = $6,
        description = $7,
        grading_method = $8,
        gen_ed = $9,
        core = $10,
        relationships = $11;

PREPARE insert_section (text, text, int, text, text, jsonb, text, text, text[]) as
    INSERT INTO sections (
      id, section_id, course_id, semester, number, seats, meetings, open_seats, waitlist, instructors
    ) VALUES (DEFAULT, $1, $2, $3, $4, $5, $6, $7, $8, $9)
    ON CONFLICT (section_id, course_id, semester) DO UPDATE SET
        section_id = $1,
        course_id = $2,
        semester = $3,
        number = $4,
        seats = $5,
        meetings = $6,
        open_seats = $7,
        waitlist = $8,
        instructors = $9
    RETURNING id;

PREPARE insert_professor (text) as
    INSERT INTO professors(id, name) VALUES (DEFAULT, $1) ON CONFLICT(name) DO UPDATE SET name = $1  RETURNING id;

PREPARE insert_section_professors(int, int) as
    INSERT INTO section_professors(professor_id, section) VALUES ($1, $2) ON CONFLICT(professor_id, section) DO NOTHING;