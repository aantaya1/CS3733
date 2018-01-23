/*
	user states: This table is used to determine whether a user has been deleted or not
	@Param id: This is the users ID (aka the primary key)
	@Param state: Not sure what this is... Will be talking to the professor *****************
	@Param created_at: timestamp
	@Param updated_at: timestamp
	@Param deleted: Whether or not the user has been deleted (virtual deletion)
*/
CREATE TABLE user_states
(
	id serial PRIMARY KEY,
	state varchar(255) NOT NULL,
	created_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	updated_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	deleted boolean NOT NULL DEFAULT(FALSE),
	unique(state, deleted)
);



/*
	Users: This will be the "master" table that holds all of the basic information about users.
			Other tables related to users will probably reference this table. When an admin creates a user,
			the information will go directly into this table.
	@Param id: This is the users ID (aka the primary key)
	@Param user_name: A unique username for a user
	@Param first_name: First name of the user
	@Param last_name: Last name of the user
	@Param email: Email of the user
	@Param phone_num: Phone number of the user
	@Param secondary_email: (Optional) prefered email of the user
	@Param encrypted_password: Password for the user
	@Param salt: Used for the password encryption integrity
	@Param user_role: Whether or not they are an admin
	@Param user_state_id: Not sure... Will ask professor*************
	@Param created_at: timestamp
	@Param updated_at: timestamp
	Note:
		-Added line starting with "user_role", not sure if correct
*/
CREATE TABLE users
(
	id serial PRIMARY KEY,
	user_name varchar(255) UNIQUE NOT NULL,
	first_name varchar(255) NOT NULL,
	last_name varchar(255) NOT NULL,
	email varchar(255) UNIQUE NOT NULL,
	phone_num bigint UNIQUE,
	secondary_email varchar(255) UNIQUE,
	encrypted_password varchar(255) NOT NULL,
	salt varchar(255) UNIQUE NOT NULL,
	user_role integer NOT NULL REFERENCES user_roles(id),
	user_state_id integer NOT NULL REFERENCES user_states(id),
	created_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	updated_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP)
);



/*
	instructors: This will be the table that holds all of the information directly related to instructors
	@Param instructor_id: This is the instructor ID, which will uniquely identify every instructor (aka the primary key)
	@Param user_id: This will be "taken/referenced" from the parent table of users
	@Param req_courses: The amount of credits that they need to teach a year
*/
CREATE TABLE instructors
(
	instructor_id serial PRIMARY KEY,
	user_id integer UNIQUE NOT NULL REFERENCES users(id), --Use this as a reference
	req_courses float NOT NULL
);



/*
	course_information: This a "master" table that will hold all of the information about a course. Other tables
			about courses will probably reference this table. When an admin creates a course, the information will go
			directly into this table.
	@Param id: This is the users ID (aka the primary key)
	@Param course_num: Course number
	@Param course_name: Course name
	@Param term: The taerm the course is taught
	@Param expected_pop: Expected population of class (How many seats will be offered)
	@Param type: The type of class (Lecture, Lab, Conference, etc.)
	@Param level: The level of the course (Undergraduate=TRUE, Graduate=FALSE)
	@Param dept: What department the course is taught in (CS, MA, RBE, etc.)
	@Param num_sections: The number of sections that are offered for the course
*/
CREATE TABLE course_information
(
	id serial PRIMARY KEY,
	course_num varchar(255) UNIQUE NOT NULL,
	course_name varchar(255) UNIQUE NOT NULL,
	term varchar(255) NOT NULL,
	expected_pop integer NOT NULL,
	type varchar(255) NOT NULL,
	level boolean NOT NULL,
	dept varchar(255) NOT NULL,
	num_sections integer NOT NULL
);



/*
	course_sections: This is the "Child" table of the course_information table. This will hold the
			information specifically related to the course sections.
	@Param id: Primary key
	@Param course_num: The couse number that is "Taken/referenced" from the parent table.
	@Param section_num: The specific section number (Each row will have a unique section number in its given course and term). The number of sections will be taken form the parent table.
	@Param term: The term the course is offered in. (Thi will also be used to create a unique section number: A01, B03, etc.)
	@Param created_at: timestamp
	@Param updated_at: timestamp
*/
CREATE TABLE course_sections
(
	id serial PRIMARY KEY,
	course_num varchar(255) NOT NULL, --HAS TO REFERENCE
	section_num integer NOT NULL, --HAS TO REFERENCE
	term varchar(255) NOT NULL, --HAS TO REFERENCE
	created_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	updated_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP)
);



/*
	course_schedule: This will hold the information about the course meeting times. Each course section and lecture type will have
			it's own row.
			EXAMPLE: MA 2621, Taught in C-Term. This will represent the lecture meeting times per week.
			course_id=2621C01,
			type=lecture,
			m=TRUE,
			t=TRUE,
			w=FALSE,
			r=TRUE,
			f=TRUE,
			time_start=0900,
			time_end=1000,
	@Param id: This is the course ID (aka the primary key)
	@param type: This is the type of class. (Lecture, Lab, Conference, etc.). This will be taken from the parent table (course_information).
	@Param m: Monday (Meets on this day=True, Does NOT meet on this day=False)
	@Param t: Tuesday (Meets on this day=True, Does NOT meet on this day=False)
	@Param w: Wednesday (Meets on this day=True, Does NOT meet on this day=False)
	@Param r: Thursday (Meets on this day=True, Does NOT meet on this day=False)
	@Param f: Friday (Meets on this day=True, Does NOT meet on this day=False)
	@Param time_start: When the specific course, course section and lecture type starts (24-Hour format).
	@Param time_end: When the specific course, course section and lecture type ends (24-Hour format).
	@Param created_at: timestamp
	@Param updated_at: timestamp
*/
--make sure time works as is or if it needs to be changed
CREATE TABLE course_schedule
(
	id serial PRIMARY KEY,
	course_id integer NOT NULL, --HAS TO REFERENCE course_sections in some way
	type varchar(255) NOT NULL,
	m boolean NOT NULL,
	t boolean NOT NULL,
	w boolean NOT NULL,
	r boolean NOT NULL,
	f boolean NOT NULL,
	time_start integer NOT NULL,
	time_end integer NOT NULL,
	created_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	updated_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP)
)



/*
	link_course: This will be he table that links (registers) a specific instructor to a
			specific couse section.
	@Param id: This is the users ID (aka the primary key)
	@Param instructor_id: The id of the instructor that registered for the course section. This will be taken from the instructors table.
	@Param course_num: Course number. This will be taken from the couse sections table.
	@Param section_num: Section number of the course. This will be taken from the couse sections table.
	@Param created_at: timestamp
	@Param updated_at: timestamp
*/
CREATE TABLE link_course
(
	id serial PRIMARY KEY,
	instructor_id integer NOT NULL, --HAS TO REFERENCE
	course_num varchar(255) NOT NULL, --HAS TO REFERENCE
	section_num varchar(255) NOT NULL --HAS TO REFERENCE
	created_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	updated_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP)
)

CREATE UNIQUE INDEX users_user_name ON users(user_name);



/*
users_history: This will keep record of a user's history.
	@Param id: This is the users ID (aka the primary key)
	@Param user_id: The primary key of the user in the "Master" table. This will be taken from the master table.
	@Param user_name: A unique username for a user
	@Param first_name: First name of the user
	@Param last_name: Last name of the user
	@Param email: Email of the user
	@Param encrypted_password: Password for the user
	@Param salt: Used for the password encryption integrity
	@Param user_state_id: Not sure... Will ask professor*************
	@Param created_at: timestamp
	--course num and term need to be inherited
*/
CREATE TABLE users_history
(
	id serial PRIMARY KEY,
	user_id integer NOT NULL REFERENCES users(id) ON DELETE CASCADE, --HAS TO REFERENCE
	user_name varchar(255) NOT NULL,
	first_name varchar(255) NOT NULL,
	last_name varchar(255) NOT NULL,
	email varchar(255) NOT NULL,
	encrypted_password varchar(255) NOT NULL,
	salt varchar(255) NOT NULL,
	user_state_id integer NOT NULL REFERENCES user_states(id),
	created_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP)
);



/*
	user_roles: What the user's role in the system is. Will determine their privileges.
	@Param id: This is the users ID (aka the primary key)
	@Param is_instructor: Whetherof not the user is an instructor (TRUE=instructor, FALSE=Admin)
	@Param created_at: timestamp
	@Param updated_at: timestamp
	@Param :
	--course num and term need to be inherited
*/
CREATE TABLE user_roles
(
	id serial PRIMARY KEY,
	is_instructor boolean NOT NULL,
	created_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	updated_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	deleted boolean NOT NULL DEFAULT(FALSE),
);



/*
	users_roles_links: This is the table that will link a specif user to a specific role.
	@Param id: Primary key
	@Param user_id: The primary key of the user in the "Master" table. This will be taken from the master table.
	@Param role_id: The role that they have. Taken from the user_role table.
	@Param created_at: timestamp
	@Param updated_at: timestamp
	@Param deleted: Whether or not the user has been virtually deleted from the system.
	--course num and term need to be inherited
*/
CREATE TABLE users_roles_links
(
	id serial PRIMARY KEY,
	user_id integer NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	role_id integer NOT NULL REFERENCES user_roles(id) ON DELETE CASCADE,
	created_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	updated_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	deleted boolean NOT NULL DEFAULT(FALSE),
	UNIQUE(user_id, role_id, deleted)
);



/*
	admin_inbox: This is the table that will work as the [shared] inbox for all admins in the system.
	@Param id: Primary key.
	@Param sender: Who sent (made the entry into the table).
	@Param subject_line: The subject line of the message. This will be automatically generated. The user will not be able to modify this.
	@Param content: Contents of the message.
	@Param status: Whether or not the admin has accepted or rejected the request (could also be deleted or unread).
	@Param created_at: timestamp
	@Param updated_at: timestamp
	--course num and term need to be inherited
*/
CREATE TABLE admin_inbox
(
	id serial PRIMARY KEY,
	sender integer NOT NULL,
	subject_line varchar(255) NOT NULL,
	content varchar(1027) NOT NULL,
	status boolean,
	created_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP),
	updated_at timestamp with time zone NOT NULL DEFAULT(CURRENT_TIMESTAMP)
);

CREATE FUNCTION insert_users_history() RETURNS TRIGGER AS
$BODY$
BEGIN
INSERT INTO users_history(user_id, user_name, first_name, last_name, email, encrypted_password, salt, user_state_id)
VALUES(OLD.id, OLD.user_name, OLD.first_name, OLD.last_name, OLD.email, OLD.encrypted_password, OLD.salt, OLD.user_state_id);
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;


CREATE TRIGGER update_users
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE insert_users_history();

----------------------------------------------------------------------------------------------------------------------

/*
DROP TRIGGER update_users ON users;
DROP FUNCTION insert_users_history();

DROP TABLE users_roles_links;
DROP TABLE user_roles;
DROP TABLE users_history;
DROP TABLE users;
DROP TABLE user_states;
*/
