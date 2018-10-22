/* This file should generally not be run, except from the correct Ruby code */

CREATE TABLE IF NOT EXISTS courses (
    course_id text PRIMARY KEY,
    name text,
    dept_id text,
    department text,
    semester text,
    credits text,
    grading_method text,
    core text[],
    gen_ed text[],
    description text,
    relationships json
);

CREATE TABLE IF NOT EXISTS sections (
    section_id text PRIMARY KEY,
    course_id text,
    number text,
    instructors text[],
    seats text,
    semester text[],
    meetings json[],
    open_seats text,
    waitlist text
);

CREATE TABLE IF NOT EXISTS professors (
    name text,
    semester text[],
    courses text[],
    departments text[]
);